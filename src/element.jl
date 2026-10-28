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
  # Show the parameter groups the element effectively has, i.e. with any inherited parameter
  # groups flattened in. InheritParams itself is shown compactly (see below).
  own_pdict = getfield(ele, :pdict)
  pdict = copy(flattened_pdict(ele))
  if haskey(own_pdict, InheritParams)
    pdict[InheritParams] = own_pdict[InheritParams]
  end
  # Parameter groups not in the element itself are marked as inherited
  inherited = [v for (k,v) in pdict if !haskey(own_pdict, k)]
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
    if v isa IgnoreParams && isempty(v.ignore_params)
      continue # An empty IgnoreParams has no effect, and may have been created just by reading
    end
    if !(v in pgs)
      pgs[idx] = v
      idx += 1
    end
  end

  # Print to a buffer first so trailing newlines can be stripped. Otherwise there are extra
  # blank lines before the next REPL prompt.
  buf = IOBuffer()
  pretty_table(IOContext(IOContext(buf, io), :displaysize => displaysize(io)), permutedims(pgs);
    show_column_labels=false,
    line_breaks=true,
    alignment=:l,
    fit_table_in_display_horizontally=get(io, :limit, false),
    fit_table_in_display_vertically=get(io, :limit, false),
    table_format = TextTableFormat(borders = text_table_borders__borderless),
    new_line_at_end=false,
    formatters=[(v, i, j)-> format_param_group(v, inherited)]
  )
  print(io, rstrip(String(take!(buf))))

  return
end

# Parameter group string for the element show table. Inherited groups get a marked header line.
function format_param_group(v, inherited)
  isnothing(v) && return ""
  str = sprint(show, v)
  if any(x -> x === v, inherited)
    str = replace(str, "\n" => " (inherited)\n"; count=1)
  end
  return str
end

function flattened_pdict(ele::LineElement, p=nothing)
  curpdict = getfield(ele, :pdict)
  if !haskey(curpdict, InheritParams) && isnothing(p)
    return curpdict
  end
  isnothing(p) && (p = ParamDict())
  # Add the element's parameter groups, giving precedence to those already present (from children)
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

Base.isapprox(a::LineElement, b::LineElement) = isapprox_ignoring(a, b)

"""
    isapprox_ignoring(a::LineElement, b::LineElement, ignore::Type{<:AbstractParams}...)

Same as `isapprox(a, b)` except that the parameter groups `ignore` are also not compared. 
`BeamlineParams` and `MetaParams` are never compared, and an `IgnoreParams` with an empty 
list is treated as no `IgnoreParams`. 

This only affects the comparison: it is unrelated to the `ignore_params` list of 
`IgnoreParams`.
"""
function isapprox_ignoring(a::LineElement, b::LineElement, ignore::Type{<:AbstractParams}...)
  l = flattened_pdict(a)
  r = flattened_pdict(b)
  # BeamlineParams and MetaParams do not affect the physics, and an IgnoreParams with an empty
  # list is the same as no IgnoreParams
  skip(k, v) = k == BeamlineParams || k == MetaParams || k in ignore || 
               (v isa IgnoreParams && isempty(v.ignore_params))
  L_l = count(pair -> !skip(pair...), l)
  L_r = count(pair -> !skip(pair...), r)
  L_l != L_r && return false
  anymissing = false
  for pair in l
      if skip(pair...)
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
              :Marker, :Kicker, :HKicker, :VKicker, :RFCavity, :Patch, :BPM
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

# Only print a short description of the parent to avoid recursively printing the whole parent.
function Base.show(io::IO, a::InheritParams)
  parent = a.parent
  println(io, nameof(typeof(a)))
  if isnothing(parent.UniversalParams) # name and kind would just be the defaults
    println(io, " parent = LineElement with no UniversalParams")
  else
    println(io, " parent = LineElement(name = ", repr(parent.name), ", kind = ", repr(parent.kind), ")")
  end
  return
end

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
  context = haskey(pdict, BeamlineParams) ? ((pdict[BeamlineParams]::BeamlineParams).beamline.context) : (NULL_CONTEXT)
  return @inline _getproperty(ele, key, context)
end

function _getproperty(ele::LineElement, key::Symbol, context::Context)
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
      return _getproperty(get_parent(pdict), key, context)
    else
      return nothing
    end
  elseif haskey(VIRTUAL_GETTER_MAP, key) # Virtual properties override regular properties
    # Virtual properties access the element by properties or parameter structs, so this should
    # also not worry about InheritParams
    return deval(VIRTUAL_GETTER_MAP[key](ele, key, context), context)
  elseif haskey(PROPERTIES_MAP, key)
    if haskey(pdict, PROPERTIES_MAP[key])  # To get a property in a parameter struct
      # If there is the parameter group, then the property 100% exists, don't worry about InheritParams
      return deval(getproperty(getindex(pdict, PROPERTIES_MAP[key]), key), context)
    elseif haskey(pdict, InheritParams)
      return _getproperty(get_parent(pdict), key, context)
    else
      # DEFAULT VALUE!
      # Default value will be done by constructing the parameter group 
      # and then just extracting the particular property.
      # This ensures that if a default is changed elsewhere, it is handled properly
      if PROPERTIES_MAP[key] == IgnoreParams
        # Create IgnoreParams on first access, so that the list returned is stored in the
        # element and e.g. `push!(ele.ignore_params, BendParams)` works
        p = IgnoreParams()
        setindex!(pdict, p, IgnoreParams)
        return p.ignore_params
      elseif PROPERTIES_MAP[key] == BeamlineParams
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
  context = haskey(pdict, BeamlineParams) ? ((pdict[BeamlineParams]::BeamlineParams).beamline.context) : (NULL_CONTEXT)
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
    return VIRTUAL_SETTER_MAP[key](ele, key, context, value)
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

# This should also flatten any InheritParams
function deepcopy_no_beamline(ele::LineElement)
  newele = LineElement()
  for pg in keys(PARAMS_MAP)
    if pg == :BeamlineParams
      continue
    end
    elepg = getproperty(ele, pg)
    if !isnothing(elepg)
      setproperty!(newele, pg, deepcopy(elepg))
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
