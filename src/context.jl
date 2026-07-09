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

struct _NullContextT end
const NULL_CONTEXT = Context{_NullContextT}()
const GLOBAL_CONTEXTS = Stack{Context}()

