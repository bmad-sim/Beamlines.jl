@kwdef mutable struct AlignmentParams{T} <: AbstractParams
  
  x_offset::T = Float32(0.0)
  y_offset::T = Float32(0.0)
  z_offset::T = Float32(0.0)
  x_rot::T    = Float32(0.0)
  y_rot::T    = Float32(0.0)
  tilt::T     = Float32(0.0)
  function AlignmentParams(args...)
    return new{promote_type(typeof.(args)...)}(args...)
  end
end

PROPS(::Type{AlignmentParams}) = OrderedDict{String,String}(
  "x_offset" => "Offset along x-axis [m]",
  "y_offset" => "Offset along y-axis [m]",
  "z_offset" => "Offset along z-axis [m]",
  "x_rot"    => "Rotation around the x-axis [rad]",
  "y_rot"    => "Rotation around the y-axis [rad]",
  "tilt"    => "Rotation around the z-axis [rad]",
)

"""
    AlignmentParams

Describe the alignment of the element with respect to the nominal position. 
Rotations are applied in order: `tilt`, `x_rot`, `y_rot`.

## Properties
$(PROPSDOC(AlignmentParams))
"""
AlignmentParams

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