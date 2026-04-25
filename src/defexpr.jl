
"""
    DefExpr{T}
  
A lazily-evaluated deferred expression returning type `T`. Deferred expressions 
are lambda functions that "close" over a variable in the current scope.

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
"""
struct DefExpr{T}
  f::FunctionWrapper{T,Tuple{}}
  DefExpr{T}(f::FunctionWrapper{T,Tuple{}}) where {T} = new{T}(f)
end

# In Julia we don't need to do any conversion, just static asserts
defconvert(::Type{T}, f) where {T} = f::T

# Calling DefExpr
(d::DefExpr{T})() where {T} = defconvert(T, d.f())

# Construct for Function -> DefExpr{FunctionWrapper}
function DefExpr{T}(f) where {T}
  return DefExpr{T}(FunctionWrapper{T,Tuple{}}(f))
end

# Conversion of types to DefExpr
DefExpr{T}(a::Number) where {T} = DefExpr{T}(()->convert(T,a))
DefExpr{T}(a::DefExpr) where {T} = DefExpr{T}(()->convert(T,a()))

# Make these apply via convert
Base.convert(::Type{D}, a) where {D<:DefExpr} = D(a)

# Now simple constructor for convenience
function DefExpr(f)
  T = Base.promote_op(f)
  return DefExpr{T}(f)
end

deval(d::DefExpr) = d()
deval(d) = d

Base.:+(da::DefExpr) = da
Base.:-(da::DefExpr) = DefExpr(()->-da())
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
  :csch, :acsc, :acsch, :sec, :sech, :asec, :asech, :conj, :log10, :isnan, :sign,
  :zero, :one)
@eval begin
Base.$t(d::DefExpr) = DefExpr(()-> ($t)(d()))
end
end

Base.promote_rule(::Type{DefExpr{T}}, ::Type{U}) where {T,U<:Number} = DefExpr{promote_type(T,U)}
Base.promote_rule(::Type{DefExpr{T}}, ::Type{DefExpr{U}}) where {T,U<:Number} = DefExpr{promote_type(T,U)}

Base.broadcastable(o::DefExpr) = Ref(o)