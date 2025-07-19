@kwdef mutable struct RFParams{T<:Number} <: AbstractParams
    rate::T          = Float32(0.0) # RF frequency in Hz or Harmonic number
    voltage::T            = Float32(0.0) # Voltage in V 
    phi0::T               = Float32(0.0) # Phase at reference energy
    const harmon_master::Bool = false    # false = frequency in Hz, true = harmonic number

    function RFParams(args...)
      return new{promote_type(typeof.((args[1],args[2],args[3])))}(args...)
    end
end

Base.eltype(::RFParams{T}) where {T} = T
Base.eltype(::Type{RFParams{T}}) where {T} = T


function Base.isapprox(a::RFParams, b::RFParams) 
    return 
            a.harmon_master == b.harmon_master &&
            a.rate      ≈  b.rate && 
            a.voltage       ≈  b.voltage && 
            a.phi0          ≈  b.phi0         
end

# Frequency mapping system analogous to BMULTIPOLE_STRENGTH_MAP
const CAVITY_FREQUENCY_MAP = Dict{Symbol,Bool}(
  :rf_frequency    => false,  # harmon_master = false (frequency in Hz)
  :harmon => true,   # harmon_master = true (harmonic number)
)

const CAVITY_FREQUENCY_INVERSE_MAP = Dict(value => key for (key, value) in CAVITY_FREQUENCY_MAP)

function Base.hasproperty(c::RFParams, key::Symbol)
  if key in fieldnames(RFParams)
    return true
  elseif haskey(CAVITY_FREQUENCY_MAP, key)
    harmon_master = CAVITY_FREQUENCY_MAP[key]
    return harmon_master == c.harmon_master
  else
    return false
  end
end

function Base.getproperty(c::RFParams, key::Symbol)
  if key in fieldnames(RFParams)
    return getfield(c, key)
  elseif haskey(CAVITY_FREQUENCY_MAP, key)
    harmon_master = CAVITY_FREQUENCY_MAP[key]
    if harmon_master == c.harmon_master
      return c.rate
    else
      correctkey = CAVITY_FREQUENCY_INVERSE_MAP[c.harmon_master]
      error("Only $correctkey is currently set in RFParams, $key cannot be calculated without particle species information")
    end
  end
  error("RFParams does not have property $key")
end

function Base.setproperty!(c::RFParams{T}, key::Symbol, value) where {T}
  if key in (:rate, :voltage, :phi0)
    return setfield!(c, key, T(value))
  elseif key == :harmon_master
    error("Cannot set `harmon_master` in RFParams directly, set as element parameter instead")
  elseif haskey(CAVITY_FREQUENCY_MAP, key)
    harmon_master = CAVITY_FREQUENCY_MAP[key]
    if harmon_master == c.harmon_master
      return setfield!(c, :rate, T(value))
    else
      error("Cannot set $key in RFParams directly because `harmon_master` = $(c.harmon_master), set $key in element instead")
    end
  end
  error("RFParams does not have property $key")
end

function _setproperty!(pdict::ParamDict, p::RFParams, key::Symbol, value)
  if hasproperty(p, key) # Check if we can put this value in current struct
    T = typeof(getproperty(p, key))
    if promote_type(typeof(value), T) == T
      if key != :harmon_master # Check if we need to create a new struct
        return setproperty!(p, key, value)
      else
        return pdict[PROPERTIES_MAP[key]] = replace(p, key, value)
      end
    end
  end
  return pdict[PROPERTIES_MAP[key]] = replace(p, key, value)
end


function replace(c1::RFParams{S}, key::Symbol, value) where {S}
  T = promote_type(S, typeof(value))
  
  if haskey(CAVITY_FREQUENCY_MAP, key)
    harmon_master = CAVITY_FREQUENCY_MAP[key]
    # Create new RFParams with updated harmon_master and rate using inner constructor
    return RFParams(T(value), T(c1.voltage), T(c1.phi0), harmon_master)
  elseif key == :harmon_master
    # Handle direct harmon_master changes using inner constructor
    return RFParams(T(c1.rate), T(c1.voltage), T(c1.phi0), value)
  else
    # Use copy constructor and setproperty! for regular properties
    c1 = RFParams(T(c1.rate), T(c1.voltage), T(c1.phi0), c1.harmon_master)
    setproperty!(c1, key, T(value))
    return c1
  end
end

# Note that it is currently impossible to derive harmonic number from frequency
# or vice versa without knowing the particle species, so the virtual getter
# function throws an error for the unspecified property.