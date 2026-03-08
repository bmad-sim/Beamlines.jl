"""
    @enumx PhaseReference::UInt8 Accelerating BelowTransition AboveTransition

Sets what zero `phi0` RF phase means
- `Accelerating`      Zero phase is the maximum accelerating phase.
- `BelowTransition`   Zero phase is at the stable zero crossing for particles below transition.
- `AboveTransition`   Zero phase is at the stable zero crossing for particles above transition.
"""
@enumx PhaseReference::UInt8 Accelerating BelowTransition AboveTransition

@enumx RateMeaning::Int8 RFFrequency=false Harmon=true Indeterminate=-1 

mutable struct RFParams{T} <: AbstractParams
  rate::T                           # RF frequency in Hz or Harmonic number
  voltage::T                        # Voltage in V 
  phi0::T                           # Phase at reference energy
  const rate_meaning::RateMeaning.T # false = frequency in Hz, true = harmonic number, -1 = Not set
  zero_phase::PhaseReference.T      # Determines the RF phase at phi0 = 0
  traveling_wave::Bool              # Traveling wave or standing wave cavity?
  is_crabcavity::Bool               # Is this a crab cavity?
  function RFParams(args...)
    if args[1] != 0 && args[4] == RateMeaning.Indeterminate
      error("Unable to construct RFParams with both nonzero rate and rate_meaning = RateMeaning.Indeterminate. 
              The meaning of rate must be known in order to have a nonzero rate field.")
    end
    return new{promote_type(typeof.((args[1],args[2],args[3]))...)}(args...)
  end
end

# Default kwarg ctors
# This instead of @kwdef to allow 
# harmon_master kwarg
function RFParams(; 
  rate = Float32(0.0), 
  voltage = Float32(0.0), 
  phi0 = Float32(0.0), 
  rate_meaning = RateMeaning.Indeterminate, 
  zero_phase = PhaseReference.Accelerating, 
  traveling_wave = false, 
  is_crabcavity = false,
  harmon_master::Union{Nothing,Bool} = nothing,
)
  if !isnothing(harmon_master)
    if rate_meaning != RateMeaning.Indeterminate
      error("You specified both a rate_meaning and harmon_master. Please specify only one of these.")
    end
    rate_meaning = harmon_master ? RateMeaning.Harmon : RateMeaning.RFFrequency
  end
  RFParams(rate, voltage, phi0, rate_meaning, zero_phase, traveling_wave, is_crabcavity)
end

function RFParams{T}(; 
  rate = Float32(0.0), 
  voltage = Float32(0.0), 
  phi0 = Float32(0.0), 
  rate_meaning = RateMeaning.Indeterminate, 
  zero_phase = PhaseReference.Accelerating, 
  traveling_wave = false, 
  is_crabcavity = false,
  harmon_master::Union{Nothing,Bool} = nothing,
) where T
  if !isnothing(harmon_master)
    if rate_meaning != RateMeaning.Indeterminate
      error("You specified both a rate_meaning and harmon_master. Please specify only one of these.")
    end
    rate_meaning = harmon_master ? RateMeaning.Harmon : RateMeaning.RFFrequency
  end
  RFParams{T}(rate, voltage, phi0, rate_meaning, zero_phase, traveling_wave, is_crabcavity)
end

Base.eltype(::RFParams{T}) where {T} = T
Base.eltype(::Type{RFParams{T}}) where {T} = T

function Base.isapprox(a::RFParams, b::RFParams) 
    return  a.rate           ≈  b.rate && 
            a.voltage        ≈  b.voltage && 
            a.phi0           ≈  b.phi0 &&
            a.rate_meaning   == b.rate_meaning &&
            a.zero_phase     == b.zero_phase &&
            a.traveling_wave == b.traveling_wave &&
            a.is_crabcavity  == b.is_crabcavity
end

# Error if writes to rate while rate_meaning is Indeterminate:
function Base.setproperty!(rfp::RFParams{T}, key::Symbol, value) where {T}
  if key == :harmon_master
    error("RFParams property harmon_master is get-only at the RFParams level. Try setting it at the LineElement level.")
  elseif key == :rate && rfp.rate_meaning == RateMeaning.Indeterminate
    error("Cannot set rate of RFParams with rate_meaning = RateMeaning.Indeterminate")
  elseif key in (:rate, :voltage, :phi0)
    setfield!(rfp, key, T(value))
  else
    setfield!(rfp, key, value)
  end
  return value
end

function Base.getproperty(rfp::RFParams, key::Symbol)
  if key == :harmon_master
    if rfp.rate_meaning == RateMeaning.Indeterminate
      error("Unable to get key harmon_master from RFParams: rate_meaning = RateMeaning.Indeterminate")
    end
    return Bool(rfp.rate_meaning)
  else
    return getfield(rfp, key)
  end
end

# Note that if rate = 0, rf_frequency = harmon = 0. So in 
# Note that in the case where voltage != 0 but rate = 0
isactive(rfp::RFParams) = (rfp.voltage != 0)