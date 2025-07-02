# RF cavity type can be standing wave or traveling wave
@enum Cavity begin
    STANDING_WAVE = 0
    TRAVELING_WAVE = 1
end

@kwdef mutable struct RFParams{T<:Number} <: AbstractParams
    frequency::T = Float32(0.0)
    gradient::T = Float32(0.0)
    phase::T = Float32(0.0)
    cavity_type::Cavity = STANDING_WAVE # and traveling wave
    function RFParams(args...)
        return new{promote_type(typeof(args[1]), typeof(args[2]), typeof(args[3]))}(args...)
    end
end



Base.eltype(::RFParams{T}) where {T} = T
Base.eltype(::Type{RFParams{T}}) where {T} = T

function Base.isapprox(a::RFParams, b::RFParams)
    return a.frequency ≈ b.frequency &&
           a.gradient ≈ b.gradient &&
           a.phase ≈ b.phase &&
           a.cavity_type == b.cavity_type
end

# compute the voltage of the RF cavity, where voltage = L * gradient
function get_voltage(ele::LineElement, key::Symbol)
    return ele.L * ele.gradient
end

# setting voltage is done by setting the gradient, where gradient = voltage / length
function set_voltage!(ele::LineElement, key::Symbol, value)
    if ele.L == 0
        error("Cannot set voltage for an line element with zero length.")
    end
    gradient = value / ele.L
    ele.gradient = gradient
    return gradient
end
