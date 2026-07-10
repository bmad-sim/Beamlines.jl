"""
    Context{T}

A "scope" of variables that can be used when evaluating `DefExpr`s. Contexts serve as a
single structure that stores all (control) variables associated with beamline parameters.
Contexts essentially act as structures with arbitrary field names. The type parameter `T` 
can be specified as the variables' return type, or `Union` of return types, to improve 
performance.

If a "get" is made of a variable not included in a given `Context`, then the "get" will 
fall-back to the global stack of contexts `GLOBAL_CONTEXTS`. The first instance from the 
top of the `GLOBAL_CONTEXTS` stack of the variable will be used as the variable value. This 
makes it easy to "push" and "pop" parameter settings one may be testing in an interactive 
environment.

## Examples
```jldoctest
julia> c1 = Context(a = 1, b = 2, c = 3);

julia> push!(GLOBAL_CONTEXTS, c1);

julia> c2 = Context(a = 4);

julia> d = DefExpr(c -> c.a + c.b);

julia> d() # Uses c1.a and c1.b from the GLOBAL_CONTEXTS
3

julia> d(c2) # Uses c2.a, but falls-back to c1.b from GLOBAL_CONTEXTS
6

julia> push!(GLOBAL_CONTEXTS, c2);

julia> d() # Now uses c2.a and c1.b both from GLOBAL_CONTEXTS
6

julia> pop!(GLOBAL_CONTEXTS);

julia> d() 
3
```

`Beamline`s also store a context, which is passed to all `DefExpr`s when getting parameters 
from `LineElement`s that are in a beamline:
```jldoctest
julia> c1 = Context(Kn1=0.36);

julia> qf = Quadrupole(Kn1=DefExpr(c -> c.Kn1), L=0.5);

julia> bl = Beamline([qf], context=c1);

julia> bl[qf][1].Kn1
0.36
```
"""
mutable struct Context{T}
  d::Dict{Symbol,T}
  Context(; args...) = new{Any}(Dict{Symbol,Any}(args))
  Context{T}(; args...) where {T} = new{T}(Dict{Symbol,T}(args))
  Context{T}(d::Dict{Symbol,T}) where {T} = new{T}(d)
end

uniontypes(T::Type)  = (T,)
uniontypes(U::Union) = (U.a, uniontypes(U.b)...)

@generated function coerce(::Type{T}, x) where {T}
  members = T isa Union ? collect(uniontypes(T)) : [T]
  good = filter(S -> promote_type(x, S) === S, members)
  isempty(good) && return :(throw(ArgumentError(string(typeof(x), " cannot be stored in ", $T))))
  # narrowest qualifying member
  S = reduce((a, b) -> promote_type(a, b) === a ? b : a, good)
  return :(convert($S, x))
end

Base.setproperty!(c::Context{T}, name::Symbol, value) where {T} = (getfield(c, :d)[name] = coerce(T, value))

function Base.getproperty(c::Context{T}, name::Symbol) where {T}
  d = getfield(c, :d)
  if haskey(d, name)
    return d[name]::T
  end
  for gc in GLOBAL_CONTEXTS
    gd = getfield(gc, :d)
    haskey(gd, name) && return coerce(T, gd[name])::T
  end
  error("Variable $name is not defined in the local Context nor in GLOBAL_CONTEXTS")
end

function Base.propertynames(c::Context)
  vars = collect(keys(getfield(c, :d)))
  for gc in GLOBAL_CONTEXTS
    if gc === c
      continue
    end
    vars = vcat(vars, collect(keys(getfield(gc, :d))))
  end
  return unique(vars)
end

Base.copy(c::Context{T}) where {T} = Context{T}(copy(getfield(c, :d)))

const NULL_CONTEXT = Context()
const GLOBAL_CONTEXTS = Stack{Context}()

