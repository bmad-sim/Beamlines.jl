mutable struct Context{T}
  d::Dict{Symbol,T}
  Context(; args...) = new{Any}(Dict{Symbol,Any}(args))
  Context{T}(; args...) where {T} = new{T}(Dict{Symbol,T}(args))
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

Base.setproperty!(c::Context{T}, name::Symbol, value) where {T} = getfield(c, :d)[name] = coerce(T, value)
Base.getproperty(c::Context, name::Symbol) = getfield(c, :d)[name]
Base.propertynames(c::Context) = collect(keys(getfield(c, :d)))