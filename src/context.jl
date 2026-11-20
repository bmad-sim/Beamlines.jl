"""
    Context{T}

A "scope" of variables that can be used when evaluating `DefExpr`s. Contexts serve as a
single structure that stores all (control) variables associated with beamline parameters.
Contexts essentially act as structures with arbitrary field names. The type parameter `T`
can be specified as the variables' return type, or `Union` of return types, to improve
performance.

A `Beamline` stores a context, which is passed to all `DefExpr`s when getting parameters from
the `LatElement`s in it (a `Branch` or `Lattice` shares one context with all its `Beamline`s).
Elements that are not in a `Beamline` use `DEFAULT_CONTEXT`.

Values can be tried temporarily: `push!(c; name=value, ...)` sets the variables and remembers
their previous values, and `pop!(c)` restores them (a variable that `push!` added is removed
again). `withvalues(f, c; name=value, ...)` does the same around `f()`, also if it throws.

## Examples
```jldoctest
julia> qf = Quadrupole(Kn1=DefExpr(c -> c.k1), L=0.5);

julia> bl = Beamline([qf], context=Context(k1 = 0.36));

julia> bl.line[1].Kn1
0.36

julia> push!(bl.context; k1 = 0.4);

julia> bl.line[1].Kn1
0.4

julia> pop!(bl.context);

julia> bl.line[1].Kn1
0.36

julia> withvalues(bl.context; k1 = 0.5) do
         bl.line[1].Kn1
       end
0.5
```
"""
mutable struct Context{T}
  d::Dict{Symbol,T}
  saved::Vector{Vector{Pair{Symbol,Any}}} # the values replaced by each push!, restored by pop! (Any because may be _Undefined)
  Context(; args...) = new{Any}(Dict{Symbol,Any}(args), Vector{Pair{Symbol,Any}}[])
  Context{T}(; args...) where {T} = new{T}(Dict{Symbol,T}(args), Vector{Pair{Symbol,Any}}[])
  Context{T}(d::Dict{Symbol,T}) where {T} = new{T}(d, Vector{Pair{Symbol,Any}}[])
end

uniontypes(T::Type)  = (T,)
uniontypes(U::Union) = (U.a, uniontypes(U.b)...)

@generated function coerce(::Type{T}, x) where {T}
  members = T isa Union ? collect(uniontypes(T)) : [T]
  good = filter(S -> promote_type(x, S) === S, members)
  isempty(good) && return :(throw(InexactError(:coerce, T, x)))
  # narrowest qualifying member
  S = reduce((a, b) -> promote_type(a, b) === a ? b : a, good)
  return :(convert($S, x))
end

Base.setproperty!(c::Context{T}, name::Symbol, value) where {T} = (getfield(c, :d)[name] = coerce(T, value))

function Base.getproperty(c::Context{T}, name::Symbol) where {T}
  d = getfield(c, :d)
  haskey(d, name) && return d[name]::T
  default = (c === DEFAULT_CONTEXT)
  !default && haskey(getfield(DEFAULT_CONTEXT, :d), name) && return getfield(DEFAULT_CONTEXT, :d)[name]
  error("Variable $name is not defined in ", default ? " DEFAULT_CONTEXT" : "this Context nor the DEFAULT_CONTEXT")
end

Base.propertynames(c::Context) = collect(keys(getfield(c, :d)))

# (the previous value of a variable that push! added)
struct _Undefined end

"""
    push!(c::Context; name=value, ...)

Sets the variables of `c`, remembering their previous values, which `pop!(c)` restores.
"""
function Base.push!(c::Context{T}; kwargs...) where {T}
  values = Pair{Symbol,Any}[k => coerce(T, v) for (k, v) in kwargs] # (all checked first)
  d = getfield(c, :d)
  push!(getfield(c, :saved), Pair{Symbol,Any}[k => (haskey(d, k) ? d[k] : _Undefined()) for (k, _) in values])
  for (k, v) in values
    d[k] = v
  end
  return c
end

"""
    pop!(c::Context)

Restores the variables that the last `push!` on `c` set: their previous values, or, for a
variable it added, removes it.
"""
function Base.pop!(c::Context)
  saved = getfield(c, :saved)
  isempty(saved) && error("Nothing to pop: no push! on this Context")
  d = getfield(c, :d)
  for (k, v) in Iterators.reverse(pop!(saved))
    v isa _Undefined ? delete!(d, k) : (d[k] = v)
  end
  return c
end

"""
    withvalues(f, c::Context; name=value, ...)

Calls `f()` with the variables of `c` set to the given values, and restores them afterwards, also
if `f` throws (as `push!` and `pop!`). Returns what `f` returns.

## Examples
```julia
withvalues(ring.context; vrf = 0.0) do
  twiss(ring)
end
```
"""
function withvalues(f, c::Context; kwargs...)
  n = length(getfield(c, :saved))
  push!(c; kwargs...)
  try
    return f()
  finally
    _pop_to!(c, n)
  end
end

# Pops until n saved sets are left (also what f pushed and did not pop). A function of its own:
# Julia 1.13.3 crashes (segmentation fault) on a while loop in a finally block when the try block
# throws
function _pop_to!(c::Context, n)
  while length(getfield(c, :saved)) > n
    pop!(c)
  end
end

function Base.show(io::IO, c::Context{T}) where {T}
  d = getfield(c, :d)
  println(io, "Context{", T, "} with ", length(d), " variable", length(d) == 1 ? "" : "s", ":")
  isempty(d) && return
  vars = sort!(collect(keys(d)))
  width = maximum(length, String.(vars))
  for var in vars
    println(io, " ", rpad(String(var), width), " = ", param_repr(d[var]))
  end
  return
end

Base.copy(c::Context{T}) where {T} = Context{T}(copy(getfield(c, :d)))

"""
    merge(c::Context, cs::Context...)

Construct a new `Context` containing the variables of all of the given `Context`s. If a
variable is defined in more than one of the `Context`s, the value from the last one is
used. The type parameter of the returned `Context` is the `promote_type` of the type
parameters of the inputs, and each value is converted to it using `coerce`. For example, 
merging a `Context{Float32}` with a `Context{Float64}` gives a `Context{Float64}`. The values
saved by `push!` are not carried over: the new `Context` has nothing to `pop!`.

## Examples
```jldoctest
julia> c1 = Context(a = 1, b = 2);

julia> c2 = Context(c = 3, d = 4);

julia> c3 = merge(c1, c2);

julia> c3.a + c3.d
5

julia> c4 = merge(Context{Int}(a = 1), Context{Float64}(b = 2.0));

julia> typeof(c4)
Context{Float64}

julia> c4.a
1.0
```
"""
function Base.merge(c::Context, cs::Context...)
  ds = map(x -> getfield(x, :d), (c, cs...))
  T = promote_type(map(valtype, ds)...)
  d = Dict{Symbol,T}()
  for di in ds, (k, v) in di
    d[k] = coerce(T, v)
  end
  return Context{T}(d)
end

# (the empty Context stored by the Beamlines of a Branch, and the Branches of a Lattice, whose
# Context is that of the Branch or Lattice)
const NULL_CONTEXT = Context()

"""
    DEFAULT_CONTEXT

The `Context` used for `LatElement`s that are not in a `Beamline` (and for a `DefExpr` called
without a `Context`), e.g.
```julia
qf = Quadrupole(Kn1=DefExpr(c -> c.k1), L=0.5)
DEFAULT_CONTEXT.k1 = 0.36
qf.Kn1                        # 0.36
withvalues(DEFAULT_CONTEXT; k1 = 0.4) do
  qf.Kn1                      # 0.4
end
```
Elements in a `Beamline` use only the `Beamline`'s context.
"""
const DEFAULT_CONTEXT = Context()

