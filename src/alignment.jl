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

#Base.getproperty(a::AlignmentParams, key::Symbol) = deval(getfield(a, key))

function deval(a::AlignmentParams{<:DefExpr})
  return AlignmentParams(
    deval(a.x_offset),
    deval(a.y_offset),
    deval(a.z_offset),
    deval(a.x_rot),
    deval(a.y_rot),
    deval(a.tilt),    
  )
end