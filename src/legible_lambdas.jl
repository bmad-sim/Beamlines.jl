# Legible lambdas: anonymous functions that remember their source and print it,
# instead of an uninformative gensym like `#12 (generic function with 1 method)`.
#
# Adapted from LegibleLambdas.jl (https://github.com/MasonProtter/LegibleLambdas.jl,
# MIT License, Copyright (c) 2018 Mason Protter). This file uses only Base, so it can
# be moved to another package as is. Differences from the original:
#
#  - Keyword arguments print after a `;`. The original printed `(x; y=1) -> x + y` as
#    `(x, y = 1) -> x + y`, which is a different function (LegibleLambdas.jl issue #5).
#  - A single argument with a default or a type keeps its parentheses, so the output
#    parses back to the same lambda: `(x = 1) -> x`, not `x = 1 -> x`.
#  - Keyword arguments are forwarded when calling a `LegibleLambda`.
#  - A captured variable that is reassigned after capture (held in a `Core.Box`) prints
#    by name, since its value can still change. Other captured variables print by value.
#  - A keyword name in a call inside the body is not mistaken for a captured variable.
#  - Printing does not depend on slicing the `repr` of a quoted expression.

"""
    LegibleLambda(ex::Expr, λ::Function)

An anonymous function `λ` that also stores its source expression `ex`, so that it
displays legibly. Normally constructed with `@λ`.
"""
struct LegibleLambda{F<:Function} <: Function
  ex::Expr
  λ::F
end

(f::LegibleLambda)(args...; kwargs...) = f.λ(args...; kwargs...)

"""
    @λ args -> body
    @lambda args -> body

Create an anonymous function that displays as its source, with the values of any
captured local variables substituted in.

## Examples
```jldoctest
julia> f = @λ x -> x + 1
(x -> x + 1)

julia> f(2)
3

julia> D(f, ϵ=1e-10) = @λ(x -> (f(x + ϵ) - f(x)) / ϵ);

julia> D(sin, 0.01)
(x -> ((sin)(x + 0.01) - (sin)(x)) / 0.01)
```
"""
macro λ(ex)
  Meta.isexpr(ex, :->) ||
    throw(ArgumentError("@λ must be applied to an anonymous function `args -> body`"))
  return :(LegibleLambda($(QuoteNode(ex)), $(esc(ex))))
end

@doc (@doc @λ)
const var"@lambda" = var"@λ"

"""
    legible_expr(f::LegibleLambda) -> Expr

The source expression of `f` with line numbers removed and the captured local
variables replaced by their values.
"""
function legible_expr(f::LegibleLambda)
  ex = strip_lines(f.ex)
  captured = Dict{Symbol,Any}()
  for name in propertynames(f.λ)  # a closure's fields are its captured variables
    val = getfield(f.λ, name)
    val isa Core.Box || (captured[name] = val)
  end
  return isempty(captured) ? ex : substitute_symbols(ex, captured)
end

"""
    lambda_string(ex::Expr) -> String

Format the anonymous function expression `ex` (head `:->`) on a single line when the
body is a single expression.
"""
function lambda_string(ex::Expr)
  args, body = ex.args
  return string(lambda_args_string(args), " -> ", unquoted_string(body))
end

Base.show(io::IO, f::LegibleLambda) = print(io, "(", lambda_string(legible_expr(f)), ")")
Base.show(io::IO, ::MIME"text/plain", f::LegibleLambda) = show(io, f)

#------------------------------------------------------------------------------------

# Remove line number nodes and unwrap blocks holding a single expression.
function strip_lines(ex)
  ex isa Expr || return ex
  if ex.head === :macrocall  # a macro call needs its line number slot
    return Expr(:macrocall, ex.args[1], nothing, (strip_lines(a) for a in ex.args[3:end])...)
  end
  args = [strip_lines(a) for a in ex.args if !(a isa LineNumberNode)]
  ex.head === :block && length(args) == 1 && return args[1]
  return Expr(ex.head, args...)
end

# Replace every variable reference `sym` in `ex` by `vals[sym]`.
function substitute_symbols(ex, vals::AbstractDict{Symbol})
  if ex isa Symbol
    return haskey(vals, ex) ? vals[ex] : ex
  elseif ex isa Expr
    if ex.head === :kw  # `name` in `f(x; name=val)` is not a variable reference
      return Expr(:kw, ex.args[1], substitute_symbols(ex.args[2], vals))
    end
    return Expr(ex.head, (substitute_symbols(a, vals) for a in ex.args)...)
  else
    return ex
  end
end

# Does the variable `sym` appear anywhere in `ex`?
mentions_symbol(ex, sym::Symbol) = ex === sym ||
  (ex isa Expr && any(a -> mentions_symbol(a, sym), ex.args))

unquoted_string(x) = x isa Union{Expr,Symbol} ? string(x) : repr(x)

function lambda_args_string(args)
  args isa Symbol && return string(args)
  if Meta.isexpr(args, :tuple)
    items = args.args
  elseif Meta.isexpr(args, :block)
    # `(x; y=1) -> ...` parses its arguments as a block: the positional argument first,
    # then the keyword arguments. See LegibleLambdas.jl issue #5.
    items = Any[Expr(:parameters, args.args[2:end]...), args.args[1]]
  else
    items = Any[args]  # a single argument with a type or default, `(x::T)` or `(x = 1)`
  end
  positional = [lambda_arg_string(a) for a in items if !Meta.isexpr(a, :parameters)]
  keyword = [lambda_arg_string(k) for p in items if Meta.isexpr(p, :parameters) for k in p.args]
  s = join(positional, ", ")
  isempty(keyword) || (s *= "; " * join(keyword, ", "))
  return "(" * s * ")"
end

lambda_arg_string(a) = Meta.isexpr(a, :kw) ? string(Expr(:(=), a.args...)) : unquoted_string(a)
