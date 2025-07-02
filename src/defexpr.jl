struct DefExpr{T}
  f::FunctionWrapper{T,Tuple{}}
end

# Calling DefExpr
(d::DefExpr{T})() where {T} = d.f()::T

# Construct for Function -> DefExpr{FunctionWrapper}
function DefExpr{T}(f::Function) where {T}
  return DefExpr{T}(FunctionWrapper{T,Tuple{}}(f))
end

# Conversion of types to DefExpr
DefExpr{T}(a) where {T} = DefExpr{T}(()->convert(T,a))
DefExpr{T}(a::DefExpr) where {T} = DefExpr{T}(()->convert(T,a()))

# Make these apply via convert
Base.convert(::Type{D}, a) where {D<:DefExpr} = D(a)

# Now simple constructor for convenience
function DefExpr(f::Function)
  T = Base.promote_op(f)
  return DefExpr{T}(f)
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

Base.promote_rule(::Type{DefExpr{T}}, ::Type{U}) where {T,U} = DefExpr{promote_type(T,U)}

Base.broadcastable(o::DefExpr) = Ref(o)