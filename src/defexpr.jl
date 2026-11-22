
"""
    DefExpr{T}
  

A lazily-evaluated deferred expression returning type `T`. A deferred expression is a
function of a `Context` `c` that computes a value from the variables of the context, e.g.
`DefExpr(c -> -c.kq)`. It is evaluated every time the value is needed, with the current values
of the variables, so parameters that depend on each other never become "stale".

A parameter of an element in a `Beamline` is evaluated with the `Context` of the `Beamline`
(`bl.context`; a variable it does not have is taken from `DEFAULT_CONTEXT`). An element that is
not in a `Beamline` uses `DEFAULT_CONTEXT`.

Also see `Context`, `withvalues`, `rawget` and `deval`.

## Examples
```jldoctest
julia> qf = Quadrupole(L=0.5, Kn1=DefExpr(c -> c.kq));

julia> qd = Quadrupole(L=0.5, Kn1=DefExpr(c -> -c.kq));

julia> bl = Beamline([qf, Drift(L=1.0), qd], context=Context(kq=0.36));

julia> bl[qd].Kn1
-0.36

julia> bl.context.kq = 0.4;

julia> (bl[qf].Kn1, bl[qd].Kn1)
(0.4, -0.4)
```

Deferred expressions can be used in arithmetic like numbers: the result is a deferred
expression too. A deferred expression is evaluated in a `Context` by calling it with the
context, or with `deval`:
```jldoctest
julia> d = DefExpr(c -> c.a + c.b);

julia> c = Context(a=1.0, b=2.0);

julia> d(c)
3.0

julia> e = 2*d + 1;

julia> deval(e, c)
7.0
```
"""
struct DefExpr{T}
  f::FunctionWrapper{T,Tuple{Context}}
  DefExpr{T}(f::FunctionWrapper{T,Tuple{Context}}) where {T} = new{T}(f)
end

# In Julia we don't need to do any conversion, just static asserts
defconvert(::Type{T}, f) where {T} = f::T

# Calling DefExpr
(d::DefExpr{T})(c=DEFAULT_CONTEXT) where {T} = defconvert(T, d.f(c))

# Construct for Function -> DefExpr{FunctionWrapper}
#
# The Context-accepting branch is tested FIRST. The operators below build their
# results as `(c=NULL_CONTEXT)->...`, which is applicable both with and without
# an argument; taking the 0-argument branch for those would re-wrap them as
# `(c=NULL_CONTEXT)->f()` and silently discard the Context supplied at call
# time. Genuine 0-argument lambdas (`()->a`) are not applicable with a Context,
# so they still take the second branch.
function DefExpr{T}(f) where {T}
  if applicable(f, NULL_CONTEXT)
    return DefExpr{T}(FunctionWrapper{T,Tuple{Context}}(f))
  elseif applicable(f)
    return DefExpr{T}(FunctionWrapper{T,Tuple{Context}}((c=NULL_CONTEXT)->f()))
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
  if applicable(f, NULL_CONTEXT)
    T = Base.promote_op(f, Context)
  elseif applicable(f)
    T = Base.promote_op(f)
  else
    T = Any
  end
  return DefExpr{T}(f)
end

"""
    deval(d, c::Context=DEFAULT_CONTEXT)

Evaluates `d` in the `Context` `c` if it is a `DefExpr`, else returns `d`. E.g.
`deval(rawget(ele, :Kn1), c)` for an element in a `Beamline` with `Context` `c` is `ele.Kn1`.

For a parameter group, returns a new parameter group with every `DefExpr` evaluated, or the
parameter group itself if it contains no `DefExpr`.
"""
deval(d::DefExpr, c::Context=DEFAULT_CONTEXT) = d(c)
deval(d, c=DEFAULT_CONTEXT) = d

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
  :abs, :zero, :one)
@eval begin
Base.$t(d::DefExpr) = DefExpr((c=NULL_CONTEXT)-> ($t)(d(c)))
end
end

Base.promote_rule(::Type{DefExpr{T}}, ::Type{U}) where {T,U<:Number} = DefExpr{promote_type(T,U)}
Base.promote_rule(::Type{DefExpr{T}}, ::Type{DefExpr{U}}) where {T,U<:Number} = DefExpr{promote_type(T,U)}

Base.broadcastable(o::DefExpr) = Ref(o)