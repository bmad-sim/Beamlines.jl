@kwdef mutable struct PatchParams{T<:Number} <: AbstractParams
  dt::T        = Float32(0.0)             # Time offset
  dx::T        = Float32(0.0)             # Local x coord offset
  dy::T        = Float32(0.0)             # Local y coord offset
  dz::T        = Float32(0.0)             # Local z coord offset
  dx_rot::T    = Float32(0.0)             # Pitch: rotation around flat radial
  dy_rot::T    = Float32(0.0)             # Yaw:   rotation around global vertical
  dz_rot::T    = Float32(0.0)             # Roll:  rotation around longitudinal
  function PatchParams(args...)
    return new{promote_type(map(x->typeof(x),args)...)}(args...)
  end
end

Base.eltype(::PatchParams{T}) where {T} = T
Base.eltype(::Type{PatchParams{T}}) where {T} = T

function Base.isapprox(a::PatchParams, b::PatchParams)
  return a.dt          ≈ b.dt &&
         a.dx          ≈ b.dx &&
         a.dy          ≈ b.dy &&
         a.dz          ≈ b.dz &&
         a.dx_rot      ≈ b.dx_rot &&
         a.dy_rot      ≈ b.dy_rot &&
         a.dz_rot      ≈ b.dz_rot
end
Base.getproperty(a::PatchParams, key::Symbol) = deval(getfield(a, key))

# May want to include reference energy changes
# In the future, would want to include "flexible" patches for global geometry connections.
#
# The rotations are expressed as Tait-Bryan angles.