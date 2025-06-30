@kwdef mutable struct Beamline
  const line::Vector{LineElement}
  Brho_ref::Number # Will be NaN if not specified

  # Beamlines can be very long, so realistically only 
  # Base.Vector should be allowed.
  function Beamline(line::Vector{LineElement}; Brho_ref::Number=NaN)
    bl = new(line, Brho_ref)

    # Check if any are in a Beamline already
    for i in eachindex(line)
      if haskey(line[i].pdict, BeamlineParams)
        if line[i].beamline != bl # Different Beamline - need to error
          error("Cannot construct Beamline: element $i with name $(ele.name) is already in a Beamline")
        else # Duplicate element
          line[i] = LineElement(ParamDict(InheritParams=>InheritParams(line[i])))
        end
      end
      # HARD put in because may need to override InheritParams
      line[i].pdict[BeamlineParams] = BeamlineParams(bl, i)
    end

    return bl
  end
end


function Base.getproperty(b::Beamline, key::Symbol)
  field = getfield(b, key)
  if key == :Brho_ref && isnan(field)
    #@warn "Brho_ref has not been set: using default value of NaN"
    error("Unable to get magnetic rigidity: Brho_ref of the Beamline has not been set")
  end
  return field
end

struct BeamlineParams <: AbstractParams
  beamline::Beamline
  beamline_index::Int
end

# Make E_ref and Brho_ref (in beamline) be properties
# Also make s a property of BeamlineParams
# Note that because BeamlineParams is immutable, not setting rn
Base.propertynames(::BeamlineParams) = (:beamline, :beamline_index, :Brho_ref, :s, :s_downstream)

function Base.setproperty!(bp::BeamlineParams, key::Symbol, value)
  setproperty!(bp.beamline, key, value)
end

# Because BeamlineParams contains an abstract type, "replacing" it 
# is just modifying the field and returning itself
function replace(bp::BeamlineParams, key::Symbol, value)
  if key == :Brho_ref
    setproperty!(bp, key, value)
    return bp
  else
    error("BeamlineParams property $key cannot be modified")
  end
end

function Base.getproperty(bp::BeamlineParams, key::Symbol)
  if key == :Brho_ref
    return getproperty(bp.beamline, key) 
  elseif key in (:s, :s_downstream)
    if key == :s
      n = bp.beamline_index - 1
      if n == 0
        return 0.0
      end
    else
      n = bp.beamline_index
    end
    # s is the sum of the lengths of all preceding elements
    line = bp.beamline.line
    return sum(line[i].L for i in 1:n)
  else
    return getfield(bp, key)
  end
end


# We could overload getproperty to disallow accessing line
# directly so elements cannot be removed, but I will deal 
# with that later.
