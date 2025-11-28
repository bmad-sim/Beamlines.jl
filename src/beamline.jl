abstract type Branch end # Only subtype is Beamline

struct _Lattice{T<:Branch}
  beamlines::Vector{T}
  function _Lattice{T}(beamlines::Vector{T}) where {T}
    lat = new(beamlines)
    for i in eachindex(beamlines)
      bl = beamlines[i]
      if getfield(bl, :lattice_index) != -1
        error("Beamline $i is already in another Lattice!")
      end
      setfield!(bl, :lattice, lat)
      setfield!(bl, :lattice_index, i)
    end 
    return lat
  end
end

# The Beamline type is essentially an "expanded" lattice, as
# in there are no PreExpansionDirectives here anymore.
@kwdef mutable struct Beamline <: Branch
  const line::ReadOnlyVector{LineElement, Vector{LineElement}}
  const species_ref::Species
  const ref_is_relative::Bool
  lattice::_Lattice{Beamline} # This should be HARD to change, not allowed easily
  lattice_index::Int          # This should be HARD to change, not allowed easily
  ref # Will be nothing if not specified

  # If ref_is_relative = true, means R_ref here is previous 
  # Beamline R_ref (in lattice) + this R_ref. If this is true 
  # and Beamline is NOT in a Lattice, then an error will be 
  # thrown when attempting to get R_ref


  # Beamlines can be very long, so realistically only 
  # Base.Vector should be allowed.
  function Beamline(
    line;
    species_ref=Species(),  
    R_ref=nothing, 
    E_ref=nothing, 
    pc_ref=nothing,
    dR_ref=nothing, 
    dE_ref=nothing, 
    dpc_ref=nothing,
  )
    c = count(t->!isnothing(t), (R_ref, E_ref, pc_ref, dR_ref, dE_ref, dpc_ref)) <= 1 || error("Only one of R_ref, E_ref, pc_ref, dR_ref, dE_ref, and dpc_ref can be specified")
    ref_is_relative = false
    ref = nothing
    if !isnothing(E_ref)
      if isnullspecies(species_ref)
        error("If E_ref is specified, then a species_ref must also be specified")
      end
      ref = E_to_R(species_ref, E_ref)
    elseif !isnothing(dE_ref)
      if isnullspecies(species_ref)
        error("If dE_ref is specified, then a species_ref must also be specified")
      end
      ref = E_to_R(species_ref, dE_ref)
      ref_is_relative = true
    elseif !isnothing(pc_ref)
      if isnullspecies(species_ref)
        error("If pc_ref is specified, then a species_ref must also be specified")
      end
      ref = pc_to_R(species_ref, pc_ref)
    elseif !isnothing(dpc_ref)
      if isnullspecies(species_ref)
        error("If dpc_ref is specified, then a species_ref must also be specified")
      end
      ref = pc_to_R(species_ref, dpc_ref)
      ref_is_relative = true
    elseif !isnothing(dR_ref)
      ref = dR_ref
      ref_is_relative = true
    elseif !isnothing(R_ref) 
      if !isnullspecies(species_ref) && sign(chargeof(species_ref)) != sign(R_ref)
        println("Setting R_ref to $(sign(chargeof(species_ref))*R_ref) to match sign of species_ref charge")
        ref = sign(chargeof(species_ref))*R_ref
      else
        ref = R_ref
      end
    end

    ibp = length(line) > 0 && haskey(getfield(first(line), :pdict), InitialBeamlineParams) ? getfield(first(line), :pdict)[InitialBeamlineParams] : nothing
    if !isnothing(ibp)
      if isnothing(ref)
        ref_is_relative = ibp.ref_meaning in (:dE_ref, :dR_ref, :dpc_ref) ? true : false
      end
      if isnullspecies(species_ref)
        species_ref = ibp.species_ref
      end
    end
    bl = new(ReadOnlyVector(vec(line)), species_ref, ref_is_relative, NULL_LATTICE, -1, ref)
    if !isnothing(ibp)
      setproperty!(bl, ibp.ref_meaning, ibp.ref)
      delete!(getfield(bl.line[1], :pdict), InitialBeamlineParams)
    end

    # Check if any are in a Beamline already
    for i in eachindex(bl.line)
      if haskey(getfield(bl.line[i], :pdict), InitialBeamlineParams)
        reverse_bl_construction!(bl, i)
        error("Cannot construct Beamline: element $i contains an InitialBeamlineParams 
               which can only be placed in the first element of a Beamline. To include 
               reference energy/species changes in the middle of an accelerator, use the 
               Lattice constructor instead which will automatically construct separate 
               Beamlines for each InitialBeamlineParams.")
      end
      if haskey(getfield(bl.line[i], :pdict), BeamlineParams)
        if bl.line[i].beamline != bl # Different Beamline - need to error
          reverse_bl_construction!(bl, i)
          error("Cannot construct Beamline: element $i with name $(bl.line[i].name) is already in a Beamline")
        else # Duplicate element
          # .parent overrides ReadOnlyArray
          bl.line.parent[i] = LineElement(ParamDict(InheritParams=>InheritParams(bl.line[i])))
        end
      end
      # HARD put in because may need to override InheritParams
      getfield(bl.line[i], :pdict)[BeamlineParams] = BeamlineParams(bl, i)
    end

    return bl
  end
end

function reverse_bl_construction!(bl::Beamline, idx)
  for i in idx:-1:1
    ele = bl.line[i]
    if !isnothing(ele.BeamlineParams) && ele.BeamlineParams.beamline === bl
      ele.BeamlineParams = nothing
    end
  end
  return
end

const Lattice = _Lattice{Beamline}
const NULL_LATTICE = Lattice(Beamline[])

Base.propertynames(::Beamline) = (:line, :ref_is_relative, :ref, :lattice, :lattice_index, :R_ref, :E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref, :species_ref)

R_to_E(species_ref::Species, R) = @FastGTPSA sqrt((R*C_LIGHT*chargeof(species_ref))^2 + massof(species_ref)^2)
E_to_R(species_ref::Species, E) = @FastGTPSA massof(species_ref)*sinh(acosh(E/massof(species_ref)))/C_LIGHT/chargeof(species_ref)  # sqrt(E^2-massof(species_ref)^2)/C_LIGHT/chargeof(species_ref)
pc_to_R(species_ref::Species, pc) = @FastGTPSA pc/C_LIGHT/chargeof(species_ref)
R_to_pc(species_ref::Species, R) = @FastGTPSA R*chargeof(species_ref)*C_LIGHT
E_to_pc(species_ref::Species, E) = @FastGTPSA massof(species_ref)*sinh(acosh(E/massof(species_ref)))
pc_to_E(species_ref::Species, pc) = @FastGTPSA sqrt((pc)^2 + massof(species_ref)^2)

function Base.getproperty(b::Beamline, key::Symbol)
  if (key in (:R_ref, :E_ref, :pc_ref) && b.ref_is_relative)
    if getfield(b, :lattice_index) == -1
      error("Unable to get property $key: because this Beamline has ref_is_relative = true, 
             the property $key must be dependent on an upstream Beamline in a Lattice, but 
             the Beamline is not in a Lattice.")
    elseif getfield(b, :lattice_index) == 1
      # This assumes if relative, then initial energy is zero
      # Probably should include sign check here for consistency
      # e.g. negative energy, momenta is NOT allowed ever
      # For now won't worry about it, perhaps we can put a check here,
      # or in setproperty! for Beamline to check if first beamline
      # in a Lattice.
      if key == :R_ref
        return b.dR_ref
      elseif key == :E_ref
        return b.dE_ref
      else # :pc_ref
        return b.dpc_ref
      end
    else
      if key == :R_ref
        return b.dR_ref + getproperty(b.lattice.beamlines[b.lattice_index-1], :R_ref)
      elseif key == :E_ref
        return b.dE_ref + getproperty(b.lattice.beamlines[b.lattice_index-1], :E_ref)
      else # :pc_ref
        return b.dpc_ref + getproperty(b.lattice.beamlines[b.lattice_index-1], :pc_ref)
      end
    end
  elseif (key in (:dR_ref, :dE_ref, :dpc_ref) && !b.ref_is_relative)
    if getfield(b, :lattice_index) == -1
      # Maybe an error is not necessary here (i.e. could assume initial is zero)
      # but will leave it in for now
      error("Unable to get property $key: because this Beamline has ref_is_relative = false, 
             the property $key must be dependent on an upstream Beamline in a Lattice, but 
             the Beamline is not in a Lattice.")
    elseif getfield(b, :lattice_index) == 1
      if key == :dR_ref
        return b.R_ref
      elseif key == :dE_ref
        return b.E_ref
      else # :pc_ref
        return b.pc_ref
      end
    else
      if key == :dR_ref
        return b.R_ref - getproperty(b.lattice.beamlines[b.lattice_index-1], :R_ref)
      elseif key == :dE_ref
        return b.E_ref - getproperty(b.lattice.beamlines[b.lattice_index-1], :E_ref)
      else # :dpc_ref
        return b.pc_ref - getproperty(b.lattice.beamlines[b.lattice_index-1], :pc_ref)
      end
    end
    error("Unable to get property $key: Beamline has set ref_is_relative = $(b.ref_is_relative)")
  end
  if key in (:E_ref, :dE_ref)
    return R_to_E(b.species_ref, b.ref)
  elseif key in (:pc_ref, :dpc_ref)
    return R_to_pc(b.species_ref, b.ref)
  elseif key in (:R_ref, :dR_ref)
    return b.ref
  end
  field = deval(getfield(b, key))
  if key == :ref && isnothing(field)
    #@warn "R_ref has not been set: using default value of NaN"
    error("Unable to get $key: ref of the Beamline has not been set")
  elseif key == :species_ref && isnullspecies(field)
    error("Unable to get species_ref: species_ref of the Beamline has not been set")
  elseif key in (:lattice, :lattice_index) && (field == -1 || field === NULL_LATTICE)
    error("Unable to get $key: Beamline is not in a Lattice")
  end
  return field
end

function Base.setproperty!(b::Beamline, key::Symbol, value)
  if (key in (:R_ref, :E_ref, :pc_ref) && b.ref_is_relative) || (key in (:dR_ref, :dE_ref, :dpc_ref) && !b.ref_is_relative)
    error("Unable to set property $key: Beamline has set ref_is_relative = $(b.ref_is_relative)")
  end
  species_ref = getfield(b, :species_ref)
  if  key in (:pc_ref, :dpc_ref, :E_ref, :dE_ref) && isnullspecies(species_ref)
    error("Beamline must have a species_ref set to set $key")
  end
  if key in (:pc_ref, :dpc_ref)
    return b.ref = pc_to_R(species_ref, value)
  elseif key in (:E_ref, :dE_ref)
    return b.ref = E_to_R(species_ref, value)
  elseif key == :dR_ref
    return setfield!(b, :ref, value)
  elseif key == :R_ref
    if !isnullspecies(species_ref) && sign(chargeof(species_ref)) != sign(value)
      println("Setting R_ref to $(sign(chargeof(species_ref))*value) to match sign of species_ref charge")
      return setfield!(b, :ref, sign(chargeof(species_ref))*value)
    else
      return setfield!(b, :ref, value)
    end
  elseif key in (:lattice, :lattice_index)
    error("Unable to set property $key: this field is protected")
  else
    return setfield!(b, key, value)
  end
end

struct BeamlineParams <: AbstractParams
  beamline::Beamline
  beamline_index::Int
end

# Make E_ref and R_ref (in beamline) be properties
# Also make s a property of BeamlineParams
# Note that because BeamlineParams is immutable, not setting rn
Base.propertynames(::BeamlineParams) = (:beamline, :beamline_index, :s, :s_downstream, :R_ref, :E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref, :species_ref, :ref, :lattice, :lattice_index)

function Base.setproperty!(bp::BeamlineParams, key::Symbol, value)
  # only settable at first element
  if key in (:R_ref, :E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref)
    if bp.beamline_index == 1 && !any(t->haskey(getfield(t, :pdict), InheritParams) && getfield(t, :pdict)[InheritParams].parent === ele, bp.beamline.line)
      setproperty!(bp.beamline, key, value)
    else
      error("Property $key is a Beamline property, and therefore is only settable at 
            either the Beamline-level, or the first element in a Beamline (so long  
            as that element has no duplicates). Consider setting $key at the Beamline 
            level (e.g. beamline.$key = $value), or setting this parameter in an element 
            prior to Lattice construction to automatically generate a separate Beamline.")
    end
  else
    setproperty!(bp.beamline, key, value)
  end
end

# Because BeamlineParams contains an abstract type, "replacing" it 
# is just modifying the field and returning itself
function replace(bp::BeamlineParams, key::Symbol, value)
  #if key in (:R_ref, :E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref, :species_ref)
  setproperty!(bp, key, value)
  return bp
  #else
  #  error("BeamlineParams property $key cannot be modified")
  #end
end

function Base.getproperty(bp::BeamlineParams, key::Symbol)
  if key in (:R_ref, :E_ref, :pc_ref, :species_ref, :lattice, :lattice_index, :ref)
    return deval(getproperty(bp.beamline, key))
  elseif key in (:dR_ref, :dE_ref, :dpc_ref)
    if bp.beamline_index != 1
      return 0
    else
      return deval(getproperty(bp.beamline, key))
    end
  elseif key in (:s, :s_downstream)
    if key == :s
      n = bp.beamline_index - 1
      if n == 0
        return 0
      end
    else
      n = bp.beamline_index
    end
    # s is the sum of the lengths of all preceding elements
    line = bp.beamline.line
    return deval(sum(line[i].L for i in 1:n))
  else
    return getfield(bp, key)
  end
end


# InitialBeamlineParams which stores things before making a Beamline
# This allows the behavior of e.g. setting the first element's E_ref, etc
# This will then get destroyed when constructing a Beamline

# Tricky part here is if e.g. someone says E_ref = x BEFORE specifying a species
# In the Beamline, Species is a constant and cannot be changed, and so you either 
# have it or you don't (known from kwarg in ctor)

# With the LineElement the kwargs are evaluated in order. Therefore we have this problem

# How to remedy it? well there are a couple of ways
# 1 let anything be the independent variable at this stage
# 2 force people to give species first
# 3 could actually store the symbols for each set and then just take the last-set one

# we go with 3

# This must NOT be added to PARAMS_MAP, because users should not be able 
# to freely put this in, that could corrupt the state

# This is only put in by the virtual setters for :E_ref, :species_ref, :dR_ref, etc
# It is then removed upon Beamline construction.
@kwdef mutable struct InitialBeamlineParams <: AbstractParams
  species_ref::Species = Species()
  ref_meaning::Symbol  = :R_ref
  ref                  = nothing
end

function Base.setproperty!(ibp::InitialBeamlineParams, key::Symbol, value)
  if key in (:E_ref, :R_ref, :pc_ref, :dE_ref, :dR_ref, :dpc_ref)
     setfield!(ibp, :ref, value)
     setfield!(ibp, :ref_meaning, key)
  else
    setfield!(ibp, key, value)
  end
  return value
end

function Base.getproperty(ibp::InitialBeamlineParams, key::Symbol)
  if (key in (:dE_ref, :dR_ref, :dpc_ref) && !(ibp.ref_meaning in (:dE_ref, :dR_ref, :dpc_ref))) ||
    (key in (:E_ref, :R_ref, :pc_ref) && !(ibp.ref_meaning in (:E_ref, :R_ref, :pc_ref)))
    error("Unable to get property $key: InitialBeamlineParams has stored $(ibp.ref_meaning), and
            so property $key depends on an upstream Lattice which has not been constructed yet.")
  elseif key in (:E_ref, :dE_ref) && ibp.ref_meaning in (:E_ref, :dE_ref) ||
    key in (:R_ref, :dR_ref) && ibp.ref_meaning in (:R_ref, :dR_ref) ||
    key in (:pc_ref, :dpc_ref) && ibp.ref_meaning in (:pc_ref, :dpc_ref)
    return getfield(ibp, :ref)
  elseif key in (:E_ref, :R_ref, :pc_ref, :dE_ref, :dR_ref, :dpc_ref) # Conversion required
    species_ref = getfield(ibp, :species_ref)
    if isnullspecies(species_ref)
      error("Unable to get property $key: property depends on species_ref, but species_ref has not been set")
    end
    ref = ibp.ref
    if key in (:E_ref, :dE_ref)
      if ibp.ref_meaning in (:R_ref, :dR_ref)
        return R_to_E(species_ref, ref)
      else
        return pc_to_E(species_ref, ref)
      end
    elseif key in (:R_ref, :dR_ref)
      if ibp.ref_meaning in (:E_ref, :dE_ref)
        return E_to_R(species_ref, ref)
      else
        return pc_to_R(species_ref, ref)
      end
    else
      if ibp.ref_meaning in (:R_ref, :dR_ref)
        return R_to_pc(species_ref, ref)
      else
        return E_to_pc(species_ref, ref)
      end
    end
  elseif key == :species_ref
    species_ref = getfield(ibp, :species_ref)
    if isnullspecies(species_ref)
      error("Unable to get species_ref: species_ref of the InitialBeamlineParams has not been set")
    end
    return species_ref 
  else
    return getfield(ibp, key)
  end
end