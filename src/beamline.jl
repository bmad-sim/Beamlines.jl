@kwdef mutable struct Beamline
  const line::Vector{LineElement}
  rigidity # Will be NaN if not specified

  # Beamlines can be very long, so realistically only 
  # Base.Vector should be allowed.
  function Beamline(line; rigidity=NaN)
    bl = new(vec(line), rigidity)
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


function Base.getproperty(b::Beamline, key::Symbol)
  field = deval(getfield(b, key))
  if key == :rigidity && isnan(field)
    #@warn "rigidity has not been set: using default value of NaN"
    error("Unable to get magnetic rigidity: rigidity of the Beamline has not been set")
  end
  return field
end

struct BeamlineParams <: AbstractParams
  beamline::Beamline
  beamline_index::Int
end

# Make E_ref and rigidity (in beamline) be properties
# Also make s a property of BeamlineParams
# Note that because BeamlineParams is immutable, not setting rn
Base.propertynames(::BeamlineParams) = (:beamline, :beamline_index, :rigidity, :s, :s_downstream)

function Base.setproperty!(bp::BeamlineParams, key::Symbol, value)
  setproperty!(bp.beamline, key, value)
end

# Because BeamlineParams contains an abstract type, "replacing" it 
# is just modifying the field and returning itself
function replace(bp::BeamlineParams, key::Symbol, value)
  if key == :rigidity
    setproperty!(bp, key, value)
    return bp
  else
    error("BeamlineParams property $key cannot be modified")
  end
end

function Base.getproperty(bp::BeamlineParams, key::Symbol)
  if key == :rigidity
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
