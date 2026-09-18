
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

A deferred expression built from a legible lambda (made with `@λ`) displays as its
source, and so do the expressions built from it with operators. The display never shows
a value, since the value a deferred expression evaluates to depends on the `Context`:
```jldoctest
julia> d = DefExpr(@λ c -> c.a + c.b)
DefExpr{Any}(c -> c.a + c.b)

julia> 2d + 1
DefExpr{Any}(c -> 2 * (c.a + c.b) + 1)

julia> DefExpr(() -> 1.0) # no @λ, so the source is unknown
DefExpr{Float64}(…)
```

The source text of a deferred expression written in another language, e.g. from Python,
can be given as a second argument. It is shown as is:
```jldoctest
julia> DefExpr(c -> c.k1, "lambda c: c.k1")
DefExpr{Any}(lambda c: c.k1)
```
"""
# Source text of a deferred expression written in another language, e.g. `lambda c: c.k1`
# for one built from Python. It is shown as is and not combined with other sources.
struct SourceText
  text::String
end

Base.show(io::IO, s::SourceText) = print(io, s.text)

struct DefExpr{T}
  f::FunctionWrapper{T,Tuple{Context}}
  # Source used for display: a lambda expression with captured local variables substituted,
  # the source text of an expression written in another language, or `nothing` if unknown.
  ex::Union{Expr,SourceText,Nothing}
  DefExpr{T}(f::FunctionWrapper{T,Tuple{Context}}, ex=nothing) where {T} = new{T}(f, ex)
end

# In Julia we don't need to do any conversion, just static asserts
defconvert(::Type{T}, f) where {T} = f::T

# Calling DefExpr
(d::DefExpr{T})(c=NULL_CONTEXT) where {T} = defconvert(T, d.f(c))

# Construct for Function -> DefExpr{FunctionWrapper}
#
# The Context-accepting branch is tested FIRST. The operators below build their
# results as `(c=NULL_CONTEXT)->...`, which is applicable both with and without
# an argument; taking the 0-argument branch for those would re-wrap them as
# `(c=NULL_CONTEXT)->f()` and silently discard the Context supplied at call
# time. Genuine 0-argument lambdas (`()->a`) are not applicable with a Context,
# so they still take the second branch.
function DefExpr{T}(f, ex=nothing) where {T}
  ex isa AbstractString && (ex = SourceText(ex))
  if applicable(f, NULL_CONTEXT)
    return DefExpr{T}(FunctionWrapper{T,Tuple{Context}}(f), ex)
  elseif applicable(f)
    return DefExpr{T}(FunctionWrapper{T,Tuple{Context}}((c=NULL_CONTEXT)->f()), ex)
  else
    error("Invalid input argument for DefExpr: function must have no arguments or accept a `Beamlines.Context`")
  end
end

# A LegibleLambda forwards any arguments, so `applicable` cannot see which ones the
# underlying lambda accepts. Unwrap it, keeping its source for display.
DefExpr{T}(f::LegibleLambda) where {T} = DefExpr{T}(f.λ, legible_expr(f))

# Conversion of types to DefExpr
DefExpr{T}(a::Number) where {T} = DefExpr{T}((c=NULL_CONTEXT)->convert(T, a), Expr(:->, Expr(:tuple), a))
DefExpr{T}(a::DefExpr) where {T} = DefExpr{T}((c=NULL_CONTEXT)->convert(T, a(c)), a.ex)

# Make these apply via convert
Base.convert(::Type{D}, a) where {D<:DefExpr} = D(a)

# Now simple constructor for convenience
function defexpr_return_type(f)
  if applicable(f, NULL_CONTEXT)
    return Base.promote_op(f, Context)
  elseif applicable(f)
    return Base.promote_op(f)
  else
    return Any
  end
end

DefExpr(f, ex=nothing) = DefExpr{defexpr_return_type(f)}(f, ex)
DefExpr(f::LegibleLambda) = DefExpr{defexpr_return_type(f.λ)}(f)

function Base.show(io::IO, d::DefExpr{T}) where {T}
  print(io, "DefExpr{", T, "}(")
  ex = d.ex
  if isnothing(ex)
    print(io, "…")
  elseif ex isa SourceText
    print(io, ex)
  elseif ex.args[1] == Expr(:tuple) && !(ex.args[2] isa Union{Expr,Symbol})
    show(io, ex.args[2])  # a constant
  else
    print(io, lambda_string(ex))
  end
  print(io, ")")
end

# Name of the Context argument in the argument list of a lambda expression, or `nothing`.
defexpr_argname(args) = nothing
defexpr_argname(args::Symbol) = args
function defexpr_argname(args::Expr)
  if args.head === :tuple
    return length(args.args) == 1 ? defexpr_argname(args.args[1]) : nothing
  elseif args.head === :(::)  # `c::Context`, or the unnamed `::Context`
    return length(args.args) == 2 ? defexpr_argname(args.args[1]) : nothing
  elseif args.head in (:(=), :kw)  # `c = NULL_CONTEXT`
    return defexpr_argname(args.args[1])
  end
  return nothing
end

# Source of the DefExpr computing `op(operands...)`, where each operand is a DefExpr or a
# plain value. The operand bodies are combined under a single Context argument, renaming
# as needed: `(c -> c.a) + (x -> x.b)` gives `c -> c.a + c.b`.
function defexpr_call_expr(op::Symbol, operands...)
  name = nothing
  for x in operands
    if isnothing(name) && x isa DefExpr && x.ex isa Expr
      name = defexpr_argname(x.ex.args[1])
    end
  end
  bodies = map(operands) do x
    # A plain value, or a DefExpr whose source is unknown or not Julia, is shown as itself.
    (x isa DefExpr && x.ex isa Expr) || return x
    args, body = x.ex.args
    xname = defexpr_argname(args)
    (isnothing(xname) || xname === name) && return body
    # Renaming would capture another variable of the same name; show the operand whole.
    mentions_symbol(body, name) && return x
    return substitute_symbols(body, Dict(xname => name))
  end
  return Expr(:->, isnothing(name) ? Expr(:tuple) : name, Expr(:call, op, bodies...))
end

deval(d::DefExpr, c::Context=NULL_CONTEXT) = d(c)
deval(d, c=NULL_CONTEXT) = d

Base.:+(da::DefExpr) = da
Base.:-(da::DefExpr) = DefExpr((c=NULL_CONTEXT)->-da(c), defexpr_call_expr(:-, da))
Base.:+(da::DefExpr, b)   = DefExpr((c=NULL_CONTEXT)-> da(c) + b   , defexpr_call_expr(:+, da, b))
Base.:+(a,   db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> a    + db(c), defexpr_call_expr(:+, a, db))
Base.:+(da::DefExpr, db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> da(c) + db(c), defexpr_call_expr(:+, da, db))

Base.:-(da::DefExpr, b)   = DefExpr((c=NULL_CONTEXT)-> da(c) - b   , defexpr_call_expr(:-, da, b))
Base.:-(a,   db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> a    - db(c), defexpr_call_expr(:-, a, db))
Base.:-(da::DefExpr, db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> da(c) - db(c), defexpr_call_expr(:-, da, db))

Base.:*(da::DefExpr, b)   = DefExpr((c=NULL_CONTEXT)-> da(c) * b   , defexpr_call_expr(:*, da, b))
Base.:*(a,   db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> a    * db(c), defexpr_call_expr(:*, a, db))
Base.:*(da::DefExpr, db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> da(c) * db(c), defexpr_call_expr(:*, da, db))

Base.:/(da::DefExpr, b)   = DefExpr((c=NULL_CONTEXT)-> da(c) / b   , defexpr_call_expr(:/, da, b))
Base.:/(a,   db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> a    / db(c), defexpr_call_expr(:/, a, db))
Base.:/(da::DefExpr, db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> da(c) / db(c), defexpr_call_expr(:/, da, db))

Base.:^(da::DefExpr, b)   = DefExpr((c=NULL_CONTEXT)-> da(c) ^ b   , defexpr_call_expr(:^, da, b))
Base.:^(a,   db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> a    ^ db(c), defexpr_call_expr(:^, a, db))
Base.:^(da::DefExpr, db::DefExpr) = DefExpr((c=NULL_CONTEXT)-> da(c) ^ db(c), defexpr_call_expr(:^, da, db))

for t = (:sqrt, :exp, :log, :sin, :cos, :tan, :cot, :sinh, :cosh, :tanh, :inv,
  :coth, :asin, :acos, :atan, :acot, :asinh, :acosh, :atanh, :acoth, :sinc, :csc,
  :csch, :acsc, :acsch, :sec, :sech, :asec, :asech, :conj, :log10, :isnan, :sign,
  :abs, :zero, :one)
@eval begin
Base.$t(d::DefExpr) = DefExpr((c=NULL_CONTEXT)-> ($t)(d(c)), defexpr_call_expr($(QuoteNode(t)), d))
end
end

Base.promote_rule(::Type{DefExpr{T}}, ::Type{U}) where {T,U<:Number} = DefExpr{promote_type(T,U)}
Base.promote_rule(::Type{DefExpr{T}}, ::Type{DefExpr{U}}) where {T,U<:Number} = DefExpr{promote_type(T,U)}

Base.broadcastable(o::DefExpr) = Ref(o)
