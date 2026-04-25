"""
    AlignmentParams

Describe the alignment of the element with respect to the nominal position. 

## Properties
$(FIELDS)
"""
@kwdef mutable struct AlignmentParams{T} <: AbstractParams
  "Offset along x-axis [m]"
  x_offset::T = Float32(0.0)
  "Offset along y-axis [m]"
  y_offset::T = Float32(0.0)
  "Offset along z-axis [m]"
  z_offset::T = Float32(0.0)
  "Rotation around x-axis [rad]"
  x_rot::T    = Float32(0.0)
  "Rotation around y-axis [rad]"
  y_rot::T    = Float32(0.0)
  "Rotation around z-axis [rad]"
  tilt::T     = Float32(0.0)
  function AlignmentParams(args...)
    return new{promote_type(typeof.(args)...)}(args...)
  end
end

Base.eltype(::AlignmentParams{T}) where {T} = T
Base.eltype(::Type{AlignmentParams{T}}) where {T} = T

function Base.isapprox(a::AlignmentParams, b::AlignmentParams)
  return a.x_offset ≈ b.x_offset &&
         a.y_offset ≈ b.y_offset &&
         a.z_offset ≈ b.z_offset &&
         a.x_rot    ≈ b.x_rot &&
         a.y_rot    ≈ b.y_rot &&
         a.tilt     ≈ b.tilt
end