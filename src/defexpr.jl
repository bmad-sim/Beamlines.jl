
"""
    DefExpr{T}
  

A lazily-evaluated deferred expression returning type `T`. Deferred expressions 
are lambda functions that "close" over a variable in the current scope. They can 
be used to specify inter-dependent parameters in an accelerator and guarantee that 
no parameter ever becomes "stale".

Also see `Context`.

## Examples
```jldoctest
julia> a = 0.36;

julia> qf = Quadrupole(Kn1L=DefExpr(()->a)); # captures variable a

julia> qf.Kn1L
0.36

julia> a = 0.7
0.7

julia> qf.Kn1L
0.7
```

Slightly better performance may be achieved by explicitly typing the captured variable:
```jldoctest
julia> b::Float64 = 0.2;

julia> qf = Quadrupole(Kn1L=DefExpr(()->b)); # captures variable b with known type

julia> qf.Kn1L
0.2

julia> b = 0.4
0.4

julia> qf.Kn1L
0.4
```

Deferred expressions can be treated and operated with as regular numbers, even outside 
the context of `Beamlines`, and can be evaluated by calling it like a function with no 
arguments (with `()`):
```jldoctest
julia> c = 64;

julia> cd = DefExpr(()->sin(c));

julia> c = pi;

julia> cd = DefExpr(()->sin(c));

julia> cd()
0.0

julia> c = pi/2;

julia> cd()
1.0

julia> dd = cd + 5;

julia> dd()
6.0
```

An optional `Context` argument can be provided:
```jldoctest
julia> d = DefExpr(c -> c.a + c.b);

julia> c1 = Context(a = 1, b = 2);

julia> d(c1)
3
```
"""
struct DefExpr{T}
  f::FunctionWrapper{T,Tuple{Context}}
  DefExpr{T}(f::FunctionWrapper{T,Tuple{Context}}) where {T} = new{T}(f)
end

# In Julia we don't need to do any conversion, just static asserts
defconvert(::Type{T}, f) where {T} = f::T

# Calling DefExpr
(d::DefExpr{T})(c=NULL_CONTEXT) where {T} = defconvert(T, d.f(c))

# Construct for Function -> DefExpr{FunctionWrapper}
function DefExpr{T}(f) where {T}
  if applicable(f)
    return DefExpr{T}(FunctionWrapper{T,Tuple{Context}}((c=NULL_CONTEXT)->f()))
  elseif applicable(f, NULL_CONTEXT)
    return DefExpr{T}(FunctionWrapper{T,Tuple{Context}}(f))
  else
    error("Invalid input argument for DefExpr: function must have no arguments or accept a `Beamlines.Context`")
  end
end

# Conversion of types to DefExpr
DefExpr{T}(a::Number) where {T} = DefExpr{T}((c=NULL_CONTEXT)->convert(T, a))
DefExpr{T}(a::DefExpr) where {T} = DefExpr{T}((c=NULL_CONTEXT)->convert(T, a(c)))

# Make these apply via convert
Base.convert(::Type{D}, a) where {D<:DefExpr} = D(a)

# Now simple constructor for convenience
function DefExpr(f)
  if applicable(f)
    T = Base.promote_op(f)
  elseif applicable(f, NULL_CONTEXT)
    T = Base.promote_op(f, Context)
  else
    T = Any
  end
  return DefExpr{T}(f)
end

deval(d::DefExpr, c::Context=NULL_CONTEXT) = d(c)
deval(d, c=NULL_CONTEXT) = d

Base.:+(da::DefExpr) = da
Base.:-(da::DefExpr) = DefExpr((c=NULL_CONTEXT)->-da(c))
Base.:+(da::DefExpr, b)   = DefExpr((c=NULL_CONTEXT)-> da(c) + b   )
Base.:+(a,   db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> a    + db(c))
Base.:+(da::DefExpr, db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> da(c) + db(c))

Base.:-(da::DefExpr, b)   = DefExpr((c=NULL_CONTEXT)-> da(c) - b   )
Base.:-(a,   db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> a    - db(c))
Base.:-(da::DefExpr, db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> da(c) - db(c))

Base.:*(da::DefExpr, b)   = DefExpr((c=NULL_CONTEXT)-> da(c) * b   )
Base.:*(a,   db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> a    * db(c))
Base.:*(da::DefExpr, db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> da(c) * db(c))

Base.:/(da::DefExpr, b)   = DefExpr((c=NULL_CONTEXT)-> da(c) / b   )
Base.:/(a,   db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> a    / db(c))
Base.:/(da::DefExpr, db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> da(c) / db(c))

Base.:^(da::DefExpr, b)   = DefExpr((c=NULL_CONTEXT)-> da(c) ^ b   )
Base.:^(a,   db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> a    ^ db(c))
Base.:^(da::DefExpr, db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> da(c) ^ db(c))

for t = (:sqrt, :exp, :log, :sin, :cos, :tan, :cot, :sinh, :cosh, :tanh, :inv,
  :coth, :asin, :acos, :atan, :acot, :asinh, :acosh, :atanh, :acoth, :sinc, :csc, 
  :csch, :acsc, :acsch, :sec, :sech, :asec, :asech, :conj, :log10, :isnan, :sign,
  :zero, :one)
@eval begin
Base.$t(d::DefExpr) = DefExpr((c=NULL_CONTEXT)-> ($t)(d()))
end
end

Base.promote_rule(::Type{DefExpr{T}}, ::Type{U}) where {T,U<:Number} = DefExpr{promote_type(T,U)}
Base.promote_rule(::Type{DefExpr{T}}, ::Type{DefExpr{U}}) where {T,U<:Number} = DefExpr{promote_type(T,U)}

Base.broadcastable(o::DefExpr) = Ref(o)