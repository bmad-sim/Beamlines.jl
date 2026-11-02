# Custom show
param_repr(thing) = repr("text/plain", thing)
param_repr(thing::Enum) = "$(nameof(parentmodule(typeof(thing)))).$(repr(thing; context=:compact=>true))"
param_repr(thing::Symbol) = String(thing)
param_repr(thing::AbstractVector{<:Type}) = "[" * join(string.(thing), ", ") * "]"

# Properties doc
function PROPSDOC(::Type{T}) where {T}
  doc = IOBuffer()
  for (k,v) in PROPS(T)
    println(doc, "- `$k`: $v")
  end
  return String(take!(doc))
end

struct GetError
  msg::String
end