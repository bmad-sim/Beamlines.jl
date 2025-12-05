"""
    @enumx PhaseReference::UInt8 Accelerating BelowTransition AboveTransition

Sets what zero `phi0` RF phase means
- `Accelerating`      Zero phase is the maximum accelerating phase.
- `BelowTransition`   Zero phase is at the stable zero crossing for particles below transition.
- `AboveTransition`   Zero phase is at the stable zero crossing for particles above transition.
"""
@enumx PhaseReference::UInt8 Accelerating BelowTransition AboveTransition

@kwdef mutable struct RFParams{T} <: AbstractParams
    rate::T               = Float32(0.0) # RF frequency in Hz or Harmonic number
    voltage::T            = Float32(0.0) # Voltage in V 
    phi0::T               = Float32(0.0) # Phase at reference energy
    const harmon_master::Bool = false    # false = frequency in Hz, true = harmonic number
    zero_phase::PhaseReference.T = PhaseReference.Accelerating   # Determines the RF phase at phi0 = 0
    traveling_wave::Bool = false         # Traveling wave or standing wave cavity?
    is_crabcavity::Bool = false          # Is this a crab cavity?
    function RFParams(args...)
      return new{promote_type(typeof.((args[1],args[2],args[3]))...)}(args...)
    end
end

Base.eltype(::RFParams{T}) where {T} = T
Base.eltype(::Type{RFParams{T}}) where {T} = T


function Base.isapprox(a::RFParams, b::RFParams) 
    return  a.rate           ≈  b.rate && 
            a.voltage        ≈  b.voltage && 
            a.phi0           ≈  b.phi0 &&
            a.harmon_master  == b.harmon_master &&
            a.zero_phase     == b.zero_phase &&
            a.traveling_wave == b.traveling_wave &&
            a.is_crabcavity  == b.is_crabcavity
end

function Base.hasproperty(c::RFParams, key::Symbol)
  if key in fieldnames(RFParams)
    return true
  elseif key in (:rf_frequency, :harmon)
    return (key == :harmon) == c.harmon_master
  else
    return false
  end
end

function deval(a::RFParams{<:DefExpr})
  return RFParams(
    deval(a.rate),
    deval(a.voltage),
    deval(a.phi0),
    deval(a.harmon_master),
    deval(a.zero_phase),
    deval(a.traveling_wave),
    deval(a.is_crabcavity),
  )
end

function Base.getproperty(c::RFParams, key::Symbol)
  if key in fieldnames(RFParams)
    return getfield(c, key)
  elseif key in (:rf_frequency, :harmon)
    if (key == :harmon) == c.harmon_master
      return c.rate
    else
      error("RFParams does not have property $key with harmon_master = $(c.harmon_master)")
    end
  end
  error("RFParams does not have property $key")
end

function Base.setproperty!(c::RFParams{T}, key::Symbol, value) where {T}
  if key in (:rate, :voltage, :phi0)
    return setfield!(c, key, T(value))
  elseif key in (:harmon_master, :zero_phase, :traveling_wave, :is_crabcavity)
    return setfield!(c, key, value)
  elseif key in (:rf_frequency, :harmon)
    if (key == :harmon) == c.harmon_master
      return setfield!(c, :rate, T(value))
    else
      error("Cannot set $key in RFParams with harmon_master = $(c.harmon_master); set $key at the element level instead")
    end
  end
  error("RFParams does not have property $key")
end

isactive(rf::RFParams) = !(rf.voltage == 0)


# Note that it is currently impossible to derive harmonic number from frequency
# or vice versa without knowing the particle species_ref, so the virtual getter
# function throws an error for the unspecified property.