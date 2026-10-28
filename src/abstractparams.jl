abstract type AbstractParams end

"""
    isactive(p) -> Bool

Returns `true` if the parameter group `p` should be used in tracking. `isactive(nothing)`
is always `false`. By default a parameter group is active, however some parameter groups
define their own criteria, e.g. `RFParams` is only active if `voltage != 0`.

The `isactive` function does not check the `ignore_params` list.
"""
isactive(::AbstractParams) = true
isactive(::Nothing) = false

@generated function deval(a::AbstractParams, c::Context=NULL_CONTEXT)
    apply = [
      begin
        # This is so deval never allocates another array unless is a DefExpr to deval
        if type <: AbstractArray && (eltype(type) <: DefExpr || isabstracttype(eltype(type)))
          :(deval.(getproperty(a, $(QuoteNode(name))), (c,)))
        else
          :(deval(getproperty(a, $(QuoteNode(name))), c))
        end 
      end for (type,name) in zip(fieldtypes(a),fieldnames(a))
    ]
    base_type = Base.typename(a).wrapper
    return quote
        ($base_type)($(apply...))
    end
end

@generated function scalarize(a::AbstractParams)
  # scalarize may allocate array if override is provided that broadcasts
  # ReverseDiff has a type TrackArray so we do have to treat it separately
  # rather than acting on each element
  apply = [:(scalarize(getproperty(a, $(QuoteNode(name))))) for name in fieldnames(a)]
  base_type = Base.typename(a).wrapper
  return quote
      ($base_type)($(apply...))
  end
end

# Default parameter group show:
function Base.show(io::IO, a::AbstractParams)
  fields = fieldnames(typeof(a))
  width = maximum(length, String.(fields))
  println(io, nameof(typeof(a)))
  for field in fields
    println(io, " ", rpad(String(field), width), " = ", param_repr(getproperty(a, field)))
  end
  return
end

# By making the key the AbstractParams type name, we always have a consistent internal definition
const ParamDict = Dict{Type{<:AbstractParams}, AbstractParams}
Base.setindex!(h::ParamDict, v, key) = error("Incorrect key/value types for ParamDict")
Base.setindex!(h::ParamDict, v, key::Type{<:AbstractParams}) = error("Incorrect value for $key: !($v isa $key)")

function Base.setindex!(h::ParamDict, v::AbstractParams, key::Type{<:AbstractParams})
  # 208 ns and 3 allocations to check that we set correctly
  # Parameter groups rarely added so perfectly fine
  typeof(v) <: key || error("Key type $key does not match parameter group type $(typeof(v))")
  # The following is copy-pasted directly from Base dict.jl ==========
  index, sh = Base.ht_keyindex2_shorthash!(h, key)

  if index > 0
      h.age += 1
      @inbounds h.keys[index] = key
      @inbounds h.vals[index] = v
  else
      @inbounds Base._setindex!(h, v, key, -index, sh)
  end

  return h
  # ==================================================================
end