# If on arch or powerpc use Function only
# Ensure fully static
macro CCOMPAT()
  return :(@static(!occursin("arch", String(Sys.ARCH)) && !occursin("ppc", String(Sys.ARCH))))
end

struct DefExpr{F<:Union{Function,Base.CFunction},T}
  f::F
  DefExpr{F,T}(f::F) where {F<:Union{Function,Base.CFunction},T} = new{F,T}(f)
end

# Calling DefExpr
(d::DefExpr{Function,T})() where {T} = d.f()::T
# ccall doesn't like typevar so we use generated functions
@generated function (d::DefExpr{Base.CFunction,T})() where {T}
  return :( GC.@preserve d begin
    ccall(d.f.ptr, $T, ())
  end )
end

# Constructor for Function -> DefExpr{CFunction}
@generated function DefExpr{Base.CFunction,T}(f::Function) where {T}
  if @CCOMPAT
    return :(error("cfunction closures are not yet supported on your platform ($(Sys.ARCH))"))
  elseif !isconcretetype(T)
    return :(error("Cannot create a DefExpr{$(($F))} for non-concrete type $($T)"))
  end
  cfun = :($(Expr(:cfunction, Base.CFunction, :f, :($T), :(Core.svec()), :(:ccall))))
  return :(DefExpr{Base.CFunction, $T}($cfun))
end

# Conversion of types to DefExpr
DefExpr{F,T}(a) where {F,T} = DefExpr{F,T}(()->convert(T,a))
DefExpr{F,T}(a::DefExpr{F}) where {F,T} = DefExpr{F,T}(()->convert(T,a()))

# DefExpr{CFunction} -> DefExpr{Function}
DefExpr{Function,T}(a::DefExpr{Base.CFunction}) where {T} = DefExpr{Function,T}(()->convert(T,a.f.f))

# DefExpr{Function} -> DefExpr{CFunction}
DefExpr{Base.CFunction,T}(a::DefExpr{Function,U}) where {T,U} = DefExpr{Base.CFunction,T}(()->convert(T,a))

# Make these apply via convert
Base.convert(::Type{D}, a) where {D<:DefExpr} = D(a)

# Now simple constructor for convenience
function DefExpr(f::Function)
  T = Base.promote_op(f)
  if @CCOMPAT
    if isconcretetype(T)
      return DefExpr{Base.CFunction,T}(f)
    end
  else
    return DefExpr{Function,T}(f)
  end
end

deval(d::DefExpr) = d()
deval(d) = d

Base.:+(da::DefExpr, b)   = DefExpr(()-> da() + b   )
Base.:+(a,   db::DefExpr) = DefExpr(()-> a    + db())
Base.:+(da::DefExpr, db::DefExpr) = DefExpr(()-> da() + db())

Base.:-(da::DefExpr, b)   = DefExpr(()-> da() - b   )
Base.:-(a,   db::DefExpr) = DefExpr(()-> a    - db())
Base.:-(da::DefExpr, db::DefExpr) = DefExpr(()-> da() - db())

Base.:*(da::DefExpr, b)   = DefExpr(()-> da() * b   )
Base.:*(a,   db::DefExpr) = DefExpr(()-> a    * db())
Base.:*(da::DefExpr, db::DefExpr) = DefExpr(()-> da() * db())

Base.:/(da::DefExpr, b)   = DefExpr(()-> da() / b   )
Base.:/(a,   db::DefExpr) = DefExpr(()-> a    / db())
Base.:/(da::DefExpr, db::DefExpr) = DefExpr(()-> da() / db())

Base.:^(da::DefExpr, b)   = DefExpr(()-> da() ^ b   )
Base.:^(a,   db::DefExpr) = DefExpr(()-> a    ^ db())
Base.:^(da::DefExpr, db::DefExpr) = DefExpr(()-> da() ^ db())

for t = (:sqrt, :exp, :log, :sin, :cos, :tan, :cot, :sinh, :cosh, :tanh, :inv,
  :coth, :asin, :acos, :atan, :acot, :asinh, :acosh, :atanh, :acoth, :sinc, :csc, 
  :csch, :acsc, :acsch, :sec, :sech, :asec, :asech, :conj, :log10, :isnan)
@eval begin
Base.$t(d::DefExpr) = DefExpr(()-> ($t)(d()))
end
end

for t = (:unit, :sincu, :sinhc, :sinhcu, :asinc, :asincu, :asinhc, :asinhcu, :erf, 
         :erfc, :erfcx, :erfi, :wf, :rect)
@eval begin
GTPSA.$t(d::DefExpr) = DefExpr(()-> ($t)(d()))
end
end

Base.promote_rule(::Type{DefExpr{F,T}}, ::Type{U}) where {F,T,U} = DefExpr{F,promote_type(T,U)}
Base.promote_rule(::Type{DefExpr{Function,T}}, ::Type{DefExpr{Base.CFunction,U}}) where {T,U} = DefExpr{Function,promote_type(T,U)}

Base.broadcastable(o::DefExpr) = Ref(o)