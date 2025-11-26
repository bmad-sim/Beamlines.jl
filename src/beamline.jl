@kwdef mutable struct Beamline
  const line::ReadOnlyVector{LineElement, Vector{LineElement}}
  const species_ref::Species
  const ref_is_relative::Bool
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
    bl = new(ReadOnlyVector(vec(line)), species_ref, ref_is_relative, ref)
    # Check if any are in a Beamline already
    for i in eachindex(bl.line)
      if haskey(getfield(bl.line[i], :pdict), BeamlineParams)
        if bl.line[i].beamline != bl # Different Beamline - need to error
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

Base.propertynames(::Beamline) = (:line, :ref_is_relative, :ref, :R_ref, :E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref, :species_ref)

R_to_E(species_ref::Species, R) = @FastGTPSA sqrt((R*C_LIGHT*chargeof(species_ref))^2 + massof(species_ref)^2)
E_to_R(species_ref::Species, E) = @FastGTPSA massof(species_ref)*sinh(acosh(E/massof(species_ref)))/C_LIGHT/chargeof(species_ref)  # sqrt(E^2-massof(species_ref)^2)/C_LIGHT/chargeof(species_ref)
pc_to_R(species_ref::Species, pc) = @FastGTPSA pc/C_LIGHT/chargeof(species_ref)
R_to_pc(species_ref::Species, R) = @FastGTPSA R*chargeof(species_ref)*C_LIGHT

function Base.getproperty(b::Beamline, key::Symbol)
  if (key in (:R_ref, :E_ref, :pc_ref) && b.ref_is_relative) || (key in (:dR_ref, :dE_ref, :dpc_ref) && !b.ref_is_relative)
    error("Unable to get key $key: Beamline has set ref_is_relative = $(b.ref_is_relative)")
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
  end
  return field
end

function Base.setproperty!(b::Beamline, key::Symbol, value)
  if (key in (:R_ref, :E_ref, :pc_ref) && b.ref_is_relative) || (key in (:dR_ref, :dE_ref, :dpc_ref) && !b.ref_is_relative)
    error("Unable to set key $key: Beamline has set ref_is_relative = $(b.ref_is_relative)")
  end
  species_ref = getfield(b, :species_ref)
  if key in (:pc_ref, :dpc_ref)
    if isnullspecies(species_ref)
      error("Beamline must have a species_ref set to set pc_ref")
    end
    return b.ref = pc_to_R(species_ref, value)
  elseif key in (:E_ref, :dE_ref)
    if isnullspecies(species_ref)
      error("Beamline must have a species_ref set to set E_ref")
    end
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
Base.propertynames(::BeamlineParams) = (:beamline, :beamline_index, :s, :s_downstream, :R_ref, :E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref, :species_ref)

function Base.setproperty!(bp::BeamlineParams, key::Symbol, value)
  setproperty!(bp.beamline, key, value)
end

# Because BeamlineParams contains an abstract type, "replacing" it 
# is just modifying the field and returning itself
function replace(bp::BeamlineParams, key::Symbol, value)
  if key == :R_ref || key == :pc_ref || key == :E_ref
    setproperty!(bp, key, value)
    return bp
  else
    error("BeamlineParams property $key cannot be modified")
  end
end

function Base.getproperty(bp::BeamlineParams, key::Symbol)
  if key in (:R_ref, :E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref, :species_ref)
    return deval(getproperty(bp.beamline, key))
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


# We could overload getproperty to disallow accessing line
# directly so elements cannot be removed, but I will deal 
# with that later.
