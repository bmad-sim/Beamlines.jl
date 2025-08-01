abstract type AbstractParams end
isactive(::AbstractParams) = true
isactive(::Nothing) = false

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

# Equality of ParamDict does NOT consider BeamlineParams
# following is copied from Base abstractdict.jl with modification
# to ignore BeamlineParams if present
function Base.isapprox(l::ParamDict, r::ParamDict)

end

struct LineElement
  pdict::ParamDict
  function LineElement(pdict=ParamDict(UniversalParams => UniversalParams()); kwargs...)
    ele = new(pdict)
    if :L in keys(kwargs) # this is for Python compatibility which reorders the arguments.
      setproperty!(ele, :L, kwargs[:L])
    end
    for (k, v) in kwargs
      if k == :L
        continue
      end
      setproperty!(ele, k, v)
    end

    return ele
  end
end

function flattened_pdict(ele::LineElement, p=ParamDict())
  curpdict = getfield(ele, :pdict)
  if !haskey(curpdict, InheritParams)
    return curpdict
  end
  # First go through the element and get the 
  for (k,v) in curpdict
    # Do not add InheritParams or parameters already present
    if !(v isa InheritParams) && !haskey(p, k)
      p[k] = v
    end
  end
  if haskey(curpdict, InheritParams)
    p = flattened_pdict(get_parent(curpdict), p)
  end
  return p
end

function Base.isapprox(a::LineElement, b::LineElement)
  l = flattened_pdict(a)
  r = flattened_pdict(b)
  L_l = length(l) - (haskey(l, BeamlineParams) ? 1 : 0)
  L_r = length(r) - (haskey(r, BeamlineParams) ? 1 : 0)
  L_l != L_r && return false
  anymissing = false
  for pair in l
      if pair[1] == BeamlineParams
        continue
      end

      isin = in(pair, r, ≈)
      if ismissing(isin)
          anymissing = true
      elseif !isin
          return false
      end
  end
  return anymissing ? missing : true
end

# Common class choices
Solenoid(; kwargs...)   = LineElement(; class="Solenoid", kwargs...)
SBend(; kwargs...)      = LineElement(; class="SBend", kwargs...)
Quadrupole(; kwargs...) = LineElement(; class="Quadrupole", kwargs...)
Sextupole(; kwargs...)  = LineElement(; class="Sextupole", kwargs...)
Drift(; kwargs...)      = LineElement(; class="Drift", kwargs...)
Octupole(; kwargs...)   = LineElement(; class="Octupole", kwargs...)
Multipole(; kwargs...)  = LineElement(; class="Multipole", kwargs...)
Marker(; kwargs...)     = LineElement(; class="Marker", kwargs...)
Kicker(; kwargs...)     = LineElement(; class="Kicker", kwargs...)
HKicker(; kwargs...)    = LineElement(; class="HKicker", kwargs...)
VKicker(; kwargs...)    = LineElement(; class="VKicker", kwargs...)
RFCavity(; kwargs...)   = LineElement(; class="RFCavity", kwargs...)
Patch(; kwargs...)      = LineElement(; class="Patch", kwargs...)


# Default tracking method:
struct SciBmadStandard end

@kwdef mutable struct UniversalParams <: AbstractParams
  tracking_method = SciBmadStandard()
  L               = Float32(0.0)
  class           = ""
  name            = ""
end

Base.getproperty(a::UniversalParams, key::Symbol) = deval(getfield(a, key))

function Base.isapprox(a::UniversalParams, b::UniversalParams)
  return a.tracking_method == b.tracking_method &&
         a.L               ≈  b.L
         # Only compare things that affect the physics
         #a.class           == b.class &&
         #a.name            
end

struct InheritParams <: AbstractParams
  parent::LineElement
end

@inline get_parent(pdict::ParamDict) = (pdict[InheritParams]::InheritParams).parent::LineElement

# For parameter groups, both read and write are not allowed
# For properties, write is not allowed
struct ProtectParams <: AbstractParams
  protected_properties::Vector{Symbol}
end

@inline function is_protected(pdict::ParamDict, key::Symbol) 
  return haskey(pdict, ProtectParams) && key in (pdict[ProtectParams]::ProtectParams).protected_properties
end

@inline unsafe_getparams(ele::LineElement, param::Symbol) = getfield(ele, :pdict)[PARAMS_MAP[param]]

# Use Accessors here for default bc super convenient for replacing entire (even mutable) type
# For more complex params (e.g. BMultipoleParams) we will need custom override
replace(p::AbstractParams, key::Symbol, value) = set(p, opcompose(PropertyLens(key)), value)

function Base.getproperty(ele::LineElement, key::Symbol)
  pdict = getfield(ele, :pdict)
  if key == :pdict 
    error("Reading/writing directly to an element's parameter dictionary is not allowed. To get/set a parameter group use the syntax `<ele>.<parameter group name> = <parameter group>`. E.g. `ele.BMultipoleParams = BMultipoleParams()`")
    #ret = getfield(ele, :pdict)
  elseif haskey(PARAMS_MAP, key)
    if is_protected(pdict, key)
      error("Cannot get $(PARAMS_MAP[key]): parameter group is protected by ProtectParams. This can be unsafely-overridden using `unsafe_getparams`")
    elseif haskey(pdict, PARAMS_MAP[key]) # To get parameters struct
      return getindex(pdict, PARAMS_MAP[key])
    elseif haskey(pdict, InheritParams)
      return getproperty(get_parent(pdict), key)
    else
      return nothing
    end
  elseif haskey(VIRTUAL_GETTER_MAP, key) # Virtual properties override regular properties
    # Virtual properties access the element by properties or parameter structs, so this should
    # also not worry about InheritParams
    return VIRTUAL_GETTER_MAP[key](ele, key)
  elseif haskey(PROPERTIES_MAP, key)
    if haskey(pdict, PROPERTIES_MAP[key])  # To get a property in a parameter struct
      # If there is the parameter group, then the property 100% exists, don't worry about InheritParams
      return getproperty(getindex(pdict, PROPERTIES_MAP[key]), key)
    elseif haskey(pdict, InheritParams)
        return getproperty(get_parent(pdict), key)
    end
  end

  if haskey(VIRTUAL_SETTER_MAP, key)
    error("LineElement property $key is write-only")
  else
    error("Type LineElement has no property $key")
  end
end
#=
qf = Quadrupole(K1=0.36, L=0.5)
bl = Beamline([qf, qf])

qf.K1 = 0.3 # sets both
qf.K2 = 0.4 # both should get a K2 honestly
qf.BMultipoleParams = ... # Both should get it too
qf.BMultipoleParams = nothing # remove both

qf2 = bl.line[2]
qf2.K1 = 0.2 # set both?
qf2.UniversalParams = .... # set both

=#
function Base.setproperty!(ele::LineElement, key::Symbol, value)
  pdict = getfield(ele, :pdict)
  if haskey(PARAMS_MAP, key) # Setting whole parameter struct
    if is_protected(pdict, key)
      error("Cannot set $(PARAMS_MAP[key]): parameter group is protected by ProtectParams. This can be unsafely-overridden using `unsafe_getparams`")
    elseif haskey(pdict, InheritParams) && !haskey(pdict, PARAMS_MAP[key])
      setproperty!(get_parent(pdict), key, value)
    else
      if isnothing(value) # setting parameter struct to nothing removes it
        delete!(pdict, PARAMS_MAP[key])
      else
        setindex!(pdict, value, PARAMS_MAP[key])
      end
    end
  elseif is_protected(pdict, key)
    error("Cannot set $key: property is protected by ProtectParams")
  elseif haskey(VIRTUAL_SETTER_MAP, key) # Virtual properties override regular properties
    return VIRTUAL_SETTER_MAP[key](ele, key, value)
  elseif haskey(PROPERTIES_MAP, key)
    if !haskey(pdict, PROPERTIES_MAP[key])
      if haskey(pdict, InheritParams)
        return setproperty!(get_parent(pdict), key, value)
      end
      # If the parameter struct associated with this symbol does not exist, create it
      # This could be optimized in the future with a `place` function
      # That is similar to `replace` but just has the type
      # Though adding fields is not done very often so is fine
      setindex!(pdict, PROPERTIES_MAP[key](), PROPERTIES_MAP[key])
    end
    p = getindex(pdict, PROPERTIES_MAP[key])
    # Function barrier for speed
    @noinline _setproperty!(pdict, p, key, value)
  else
    if haskey(VIRTUAL_GETTER_MAP, key)
      error("LineElement property $key is read-only")
    else
      error("Type LineElement has no property $key")
    end
  end
end

function _setproperty!(pdict::ParamDict, p::AbstractParams, key::Symbol, value)
  if hasproperty(p, key) # Check if we can put this value in current struct
    T = typeof(getproperty(p, key))
    if promote_type(typeof(value), T) == T
      return setproperty!(p, key, value)
    end
  end
  return pdict[PROPERTIES_MAP[key]] = replace(p, key, value)
end

function deepcopy_no_beamline(ele::LineElement)
  newele = LineElement()
  pdict = getfield(ele, :pdict)
  for (key, p) in pdict
    if key != BeamlineParams
      setindex!(getfield(newele, :pdict), deepcopy(p), key)
    end
  end
  return newele
end

#Base.fieldnames(::Type{LineElement}) = tuple(:pdict, keys(PROPERTIES_MAP)..., keys(PARAMS_MAP)...)
#Base.fieldnames(::LineElement) = tuple(:pdict, keys(PROPERTIES_MAP)..., keys(PARAMS_MAP)...)
#Base.propertynames(::Type{LineElement}) = tuple(:pdict, keys(PROPERTIES_MAP)..., keys(PARAMS_MAP)...)
function Base.propertynames(::LineElement)
  virt = union(keys(VIRTUAL_GETTER_MAP),keys(VIRTUAL_SETTER_MAP))
  prop = keys(PROPERTIES_MAP)
  param = keys(PARAMS_MAP)
  syms = [:pdict, Symbol.(param)..., virt..., prop...]
  return syms
end
