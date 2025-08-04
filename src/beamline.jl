@kwdef mutable struct Beamline
  const line::Vector{LineElement}
  const species::Species
  R_ref # Will be NaN if not specified


  # Beamlines can be very long, so realistically only 
  # Base.Vector should be allowed.
  function Beamline(line; R_ref=NaN, species=Species(), E_ref=NaN, pc_ref=NaN)
    count(!isnan, (R_ref, E_ref, pc_ref)) <= 1 || error("Only one of R_ref, E_ref, and pc_ref can be specified")
    if !isnan(E_ref)
      if isnullspecies(species)
        error("If E_ref is specified, then a particle species must also be specified")
      end
      R_ref = E_to_R(species, E_ref)
    elseif !isnan(pc_ref)
      if isnullspecies(species)
        error("If E_ref is specified, then a particle species must also be specified")
      end
      R_ref = pc_to_R(species, pc_ref)
    end
    bl = new(vec(line), species, R_ref)
    # Check if any are in a Beamline already
    for i in eachindex(bl.line)
      if haskey(getfield(bl.line[i], :pdict), BeamlineParams)
        if bl.line[i].beamline != bl # Different Beamline - need to error
          error("Cannot construct Beamline: element $i with name $(bl.line[i].name) is already in a Beamline")
        else # Duplicate element
          bl.line[i] = LineElement(ParamDict(InheritParams=>InheritParams(bl.line[i])))
        end
      end
      # HARD put in because may need to override InheritParams
      getfield(bl.line[i], :pdict)[BeamlineParams] = BeamlineParams(bl, i)
    end

    return bl
  end
end

R_to_E(species::Species, R) = @FastGTPSA sqrt((R*C_LIGHT*chargeof(species))^2 + massof(species)^2)
E_to_R(species::Species, E) = @FastGTPSA massof(species)*sinh(acosh(E/massof(species)))/C_LIGHT/chargeof(species)  # sqrt(E^2-massof(species)^2)/C_LIGHT/chargeof(species)
pc_to_R(species::Species, pc) = @FastGTPSA pc/C_LIGHT/chargeof(species)
R_to_pc(species::Species, R) = @FastGTPSA R*chargeof(species)*C_LIGHT

function Base.getproperty(b::Beamline, key::Symbol)
  if key == :E_ref
    return R_to_E(b.species, b.R_ref)
  elseif key == :pc_ref
    return R_to_pc(b.species, b.R_ref)
  end
  field = deval(getfield(b, key))
  if key == :R_ref && isnan(field)
    #@warn "R_ref has not been set: using default value of NaN"
    error("Unable to get magnetic rigidity: R_ref of the Beamline has not been set")
  elseif key == :species && isnullspecies(field)
    error("Unable to get species: species of the Beamline has not been set")
  end
  return field
end

function Base.setproperty!(b::Beamline, key::Symbol, value)
  if key == :pc_ref
    return b.R_ref = pc_to_R(b.species, value)
  elseif key == :E_ref
    return b.R_ref = E_to_R(b.species, value)
  else
    return setfield!(key, key, value)
  end
end

struct BeamlineParams <: AbstractParams
  beamline::Beamline
  beamline_index::Int
end

# Make E_ref and R_ref (in beamline) be properties
# Also make s a property of BeamlineParams
# Note that because BeamlineParams is immutable, not setting rn
Base.propertynames(::BeamlineParams) = (:beamline, :beamline_index, :R_ref, :E_ref, :pc_ref, :species, :s, :s_downstream)

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
  if key == :R_ref || key == :pc_ref || key == :E_ref
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
