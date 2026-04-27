abstract type AbstractParams end
isactive(::AbstractParams) = true
isactive(::Nothing) = false

@generated function deval(a::AbstractParams)
    apply = [
      begin
        # This is so deval never allocates another array unless is a DefExpr to deval
        if type <: AbstractArray && (eltype(type) <: DefExpr || isabstracttype(eltype(type)))
          :(deval.(getproperty(a, $(QuoteNode(name)))))
        else
          :(deval(getproperty(a, $(QuoteNode(name)))))
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

# Element show
function Base.show(io::IO, ele::LineElement)
  print(io, "LineElement:")
  pdict = getfield(ele, :pdict)
  ks = collect(keys(pdict))
  vs = collect(values(pdict))
  idxs = sortperm(String.(Symbol.(ks))) # Sort alphabetically

  # Put it all in a matrix
  ncols = 2 #displaysize(io)[2] < 100 ? 2 : 3
  nrows = div(length(vs), ncols, RoundUp)
  pgs = Matrix{Any}(nothing, ncols, nrows)

  idx = 1
  # However, always put UniversalParams and BeamlinesParams
  # first if they exist
  if UniversalParams in keys(pdict)
    pgs[idx] = pdict[UniversalParams]
    idx += 1
  end

  if BeamlineParams in keys(pdict)
    pgs[idx] = pdict[BeamlineParams]
    idx += 1
  end

  for v in vs[idxs]
    if !(v in pgs)
      pgs[idx] = v
      idx += 1
    end
  end

  pretty_table(io, permutedims(pgs);
    show_column_labels=false,
    line_breaks=true,
    alignment=:l,
    fit_table_in_display_horizontally=get(io, :limit, false),
    fit_table_in_display_vertically=get(io, :limit, false),
    table_format = TextTableFormat(borders = text_table_borders__borderless),
    new_line_at_end=false,
    formatters=[(v, i, j)-> isnothing(v) ? "" : v]
  )

  return
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
  L_l = length(l) - (haskey(l, BeamlineParams) ? 1 : 0) - (haskey(l, MetaParams) ? 1 : 0)
  L_r = length(r) - (haskey(r, BeamlineParams) ? 1 : 0) - (haskey(r, MetaParams) ? 1 : 0)
  L_l != L_r && return false
  anymissing = false
  for pair in l
      if pair[1] == BeamlineParams || pair[1] == MetaParams
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

# Common kind choices
# Copy docstring to all aliases
for kind in (:Solenoid, :SBend, :Quadrupole, :Sextupole, :Drift, :Octupole, :Multipole, 
              :Marker, :Kicker, :HKicker, :VKicker, :RFCavity, :Patch
  )
  @eval begin
    """
        $($kind)(; kwargs...) = LineElement(; kind="$($kind)", kwargs...)
    
    See the documentation for `LineElement`
    """
    $kind(; kwargs...) = LineElement(; kind="$($kind)", kwargs...)
  end
end

# Right now CrabCavity is treated differently
"""
    $CrabCavity(; kwargs...) = LineElement(; kind="CrabCavity", is_crabcavity = true, kwargs...)

See the documentation for `LineElement`
"""
CrabCavity(; kwargs...) = LineElement(; kind="CrabCavity", is_crabcavity = true, kwargs...)


# Default tracking method:
"""
    SciBmadStandard

Default tracking method that uses exact transport maps when solvable, else uses the 
symplectic integrator `Yoshida(order=4, num_steps=1)` which chooses an appropriate split 
for each element.

## Properties
- `radiation_damping_on`: `true` if the deterministic effect of synchrotron radiation 
    is included, `false` otherwise. Defaults to `false`
- `radiation_fluctuations_on`: `true` if the stochastic radiation kicks are included, 
    `false` otherwise. Defaults to `false`
- `ibs_damping_on`: true if the deterministic effect of intrabeam scattering (IBS) is 
    included, `false` otherwise. Defaults to `false`.
- `ibs_fluctuations_on`: true if the stochastic kicks of intrabeam scattering (IBS) is 
    included, `false` otherwise. Defaults to `false`.
"""
@kwdef struct SciBmadStandard
  radiation_damping_on::Bool = false
  radiation_fluctuations_on::Bool = false
  ibs_damping_on::Bool = false
  ibs_fluctuations_on::Bool = false
end

@kwdef mutable struct UniversalParams <: AbstractParams
  kind            = ""
  name            = ""
  L               = Float32(0.0)
  tracking_method = SciBmadStandard()
end

PROPS(::Type{UniversalParams}) = OrderedDict{String,String}(
  "kind" => "String specifing the \"kind\", of an element, e.g. \"Quadrupole\"",
  "name" => "The name of an element as a string",
  "L"    => "Length of the element [m]",
  "tracking_method" => "Tracking method for the element, defaults to `SciBmadStandard()`"
)

"""
    UniversalParams

Describes the kind, name, length, and tracking method for a `LineElement`.

## Properties
$(PROPSDOC(UniversalParams))
"""
UniversalParams

# For UniversalParams, print each tracking_method field:
function Base.show(io::IO, a::UniversalParams)
  fields = fieldnames(typeof(a))
  width = maximum(length, String.(fields))
  println(io, nameof(typeof(a)))
  for field in fields
    if field == :tracking_method
      tm = getproperty(a, field)
      println(io, " ", rpad(String(field), width), " = ", param_repr(typeof(tm)), "(")
      subfields = fieldnames(typeof(tm))
      subwidth = maximum(length, String.(subfields))
      for subfield in subfields
        println(io, "   ",  rpad(String(subfield), subwidth), " = ", param_repr(getproperty(tm, subfield)), ",")
      end
      println(io, " )")
    else
      println(io, " ", rpad(String(field), width), " = ", param_repr(getproperty(a, field)))
    end
  end
  return
end

function Base.isapprox(a::UniversalParams, b::UniversalParams)
  return a.tracking_method == b.tracking_method &&
         a.L               ≈  b.L
         # Only compare things that affect the physics
         #a.kind           == b.kind &&
         #a.name            
end

struct InheritParams <: AbstractParams
  parent::LineElement
end

PROPS(::Type{InheritParams}) = OrderedDict{String,String}(
  "parent" => "Parent `LineElement` to inherit parameter groups from for both reading and writing.",
)

"""
    InheritParams

Stores a parent `LineElement` through which any parameter groups NOT present in the "child" 
element containing the `InheritParams` would inherit. E.g., if the child element has its own
`BeamlineParams`, then any property from the `BeamlineParams` parameter group would be read/
write to the child's `BeamlineParams`.

## Properties:
$(PROPSDOC(InheritParams))
"""
InheritParams

@inline get_parent(pdict::ParamDict) = (pdict[InheritParams]::InheritParams).parent::LineElement

# For parameter groups, both read and write are not allowed
# For properties, write is not allowed
# Internal as of 0.9.0, however it does work.
struct ProtectParams <: AbstractParams
  protected_properties::Vector{Symbol}
end

@inline function is_protected(pdict::ParamDict, key::Symbol) 
  return haskey(pdict, ProtectParams) && key in (pdict[ProtectParams]::ProtectParams).protected_properties
end

@inline unsafe_getparams(ele::LineElement, param::Symbol) = getfield(ele, :pdict)[PARAMS_MAP[param]]

# Use Accessors here for default bc super convenient for replacing entire (even mutable) type
# For more complex params (e.g. BMultipoleParams) we will need custom override
param_replace(p::AbstractParams, key::Symbol, value) = set(p, opcompose(PropertyLens(key)), value)

function Base.getproperty(ele::LineElement, key::Symbol)
  pdict = getfield(ele, :pdict)
  if key == :pdict 
    error("Reading/writing directly to an element's parameter dictionary is not allowed. To get/set a parameter group use the syntax `<ele>.<parameter group name> = <parameter group>`. E.g. `ele.BMultipoleParams = BMultipoleParams()`")
    #ret = getfield(ele, :pdict)
  elseif haskey(PARAMS_MAP, key)
    if is_protected(pdict, key)
      error("Cannot get $(PARAMS_MAP[key]): parameter group is protected by ProtectParams. This can be unsafely-overridden using `unsafe_getparams`")
    elseif haskey(pdict, PARAMS_MAP[key]) # To get parameters struct
      return getindex(pdict, PARAMS_MAP[key]) # NO DEVAL HERE!
    elseif haskey(pdict, InheritParams)
      return getproperty(get_parent(pdict), key)
    else
      return nothing
    end
  elseif haskey(VIRTUAL_GETTER_MAP, key) # Virtual properties override regular properties
    # Virtual properties access the element by properties or parameter structs, so this should
    # also not worry about InheritParams
    return deval(VIRTUAL_GETTER_MAP[key](ele, key))
  elseif haskey(PROPERTIES_MAP, key)
    if haskey(pdict, PROPERTIES_MAP[key])  # To get a property in a parameter struct
      # If there is the parameter group, then the property 100% exists, don't worry about InheritParams
      return deval(getproperty(getindex(pdict, PROPERTIES_MAP[key]), key))
    elseif haskey(pdict, InheritParams)
      return getproperty(get_parent(pdict), key)
    else
      # DEFAULT VALUE!
      # Default value will be done by constructing the parameter group 
      # and then just extracting the particular property.
      # This ensures that if a default is changed elsewhere, it is handled properly
      if PROPERTIES_MAP[key] == BeamlineParams
        error("""
          Unable to get key $key from LineElement: element is not in a Beamline. 
          If you placed this element in a Beamline, use `findchildren` to find 
          the child instances of this element in a given Beamline.
        """)
      end
      return getproperty(PROPERTIES_MAP[key](), key)
    end
  end

  if haskey(VIRTUAL_SETTER_MAP, key)
    error("LineElement property $key is write-only")
  else
    error("Type LineElement has no property $key")
  end
end

function Base.setproperty!(ele::LineElement, key::Symbol, value)
  pdict = getfield(ele, :pdict)
  if haskey(PARAMS_MAP, key) # Setting whole parameter struct
    if is_protected(pdict, key)
      error("Cannot set $(PARAMS_MAP[key]): parameter group is protected by ProtectParams. This can be unsafely-overridden using `unsafe_getparams`")
    elseif haskey(pdict, InheritParams) && !haskey(pdict, PARAMS_MAP[key])
      setproperty!(get_parent(pdict), key, value)
    else
      if isnothing(value) # setting parameter struct to nothing removes it
        if key != :BeamlineParams
          delete!(pdict, PARAMS_MAP[key])
        else
          error("Cannot trivially remove BeamlineParams from a LineElement: consider using `empty!(::Beamline)` instead")
        end
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
      # That is similar to `param_replace` but just has the type
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
  return pdict[PROPERTIES_MAP[key]] = param_replace(p, key, value)
end

function Base.deepcopy_internal(ele::LineElement, stackdict::IdDict)
  return get!(()->deepcopy_no_beamline(ele), stackdict, ele)::LineElement
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
Base.propertynames(::LineElement) = _lineelement_properties()

function _lineelement_properties()
  virt = union(keys(VIRTUAL_GETTER_MAP),keys(VIRTUAL_SETTER_MAP))
  prop = keys(PROPERTIES_MAP)
  param = keys(PARAMS_MAP)
  syms = [:pdict, Symbol.(param)..., virt..., prop...]
  return syms
end
