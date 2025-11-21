@kwdef mutable struct Beamline
  const line::ReadOnlyVector{LineElement, Vector{LineElement}}
  const species_ref::Species
  R_ref # Will be nothing if not specified


  # Beamlines can be very long, so realistically only 
  # Base.Vector should be allowed.
  function Beamline(line; R_ref=nothing, species_ref=Species(), E_ref=nothing, pc_ref=nothing)
    count(t->!isnothing(t), (R_ref, E_ref, pc_ref)) <= 1 || error("Only one of R_ref, E_ref, and pc_ref can be specified")
    if !isnothing(E_ref)
      if isnullspecies(species_ref)
        error("If E_ref is specified, then a species_ref must also be specified")
      end
      R_ref = E_to_R(species_ref, E_ref)
    elseif !isnothing(pc_ref)
      if isnullspecies(species_ref)
        error("If pc_ref is specified, then a species_ref must also be specified")
      end
      R_ref = pc_to_R(species_ref, pc_ref)
    elseif !isnothing(R_ref) && !isnullspecies(species_ref)
      if sign(species_ref.charge) != sign(R_ref)
        println("Setting R_ref to $(sign(species_ref.charge)*R_ref) to match sign of species_ref charge")
        R_ref = sign(species_ref.charge)*R_ref
      end
    end
    bl = new(ReadOnlyVector(vec(line)), species_ref, R_ref)
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

R_to_E(species_ref::Species, R) = @FastGTPSA sqrt((R*C_LIGHT*chargeof(species_ref))^2 + massof(species_ref)^2)
E_to_R(species_ref::Species, E) = @FastGTPSA massof(species_ref)*sinh(acosh(E/massof(species_ref)))/C_LIGHT/chargeof(species_ref)  # sqrt(E^2-massof(species_ref)^2)/C_LIGHT/chargeof(species_ref)
pc_to_R(species_ref::Species, pc) = @FastGTPSA pc/C_LIGHT/chargeof(species_ref)
R_to_pc(species_ref::Species, R) = @FastGTPSA R*chargeof(species_ref)*C_LIGHT

function Base.getproperty(b::Beamline, key::Symbol)
  if key == :E_ref
    return R_to_E(b.species_ref, b.R_ref)
  elseif key == :pc_ref
    return R_to_pc(b.species_ref, b.R_ref)
  end
  field = deval(getfield(b, key))
  if key == :R_ref && isnothing(field)
    #@warn "R_ref has not been set: using default value of NaN"
    error("Unable to get R_ref: R_ref of the Beamline has not been set")
  elseif key == :species_ref && isnullspecies(field)
    error("Unable to get species_ref: species_ref of the Beamline has not been set")
  end
  return field
end

function Base.setproperty!(b::Beamline, key::Symbol, value)
  if key == :pc_ref
    if isnullspecies(b.species_ref)
      error("Beamline must have a species_ref set before setting pc_ref")
    end
    return b.R_ref = pc_to_R(b.species_ref, value)
  elseif key == :E_ref
    if isnullspecies(b.species_ref)
      error("Beamline must have a species_ref set before setting E_ref")
    end
    return b.R_ref = E_to_R(b.species_ref, value)
  elseif key == :R_ref && !isnullspecies(getfield(b, :species_ref)) && sign(getfield(b, :species_ref).charge) != sign(value)
    println("Setting R_ref to $(sign(b.species_ref.charge)*value) to match sign of species_ref charge")
    return setfield!(b, key, sign(b.species_ref.charge)*value)
  #=
  elseif key == :species_ref && !isnothing(getfield(b, :R_ref))
    if sign(value.charge) != sign(b.R_ref)
      println("Setting R_ref to $(sign(value.charge)*getfield(b, :R_ref)) to match sign of new species_ref charge")
      b.R_ref = sign(value.charge)*b.R_ref
    end
    return setfield!(b, key, value)
  =#
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
Base.propertynames(::BeamlineParams) = (:beamline, :beamline_index, :R_ref, :E_ref, :pc_ref, :species_ref, :s, :s_downstream)

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
