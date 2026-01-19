@enumx ApertureShape::UInt8 Elliptical Rectangular
@enumx ApertureAt::UInt8 Entrance Exit BothEnds

@kwdef mutable struct ApertureParams{T} <: AbstractParams
  x1_limit::T                     = -Inf32
  x2_limit::T                     =  Inf32
  y1_limit::T                     = -Inf32
  y2_limit::T                     =  Inf32
  aperture_shape::ApertureShape.T = ApertureShape.Elliptical
  aperture_at::ApertureAt.T       = ApertureAt.Entrance
  aperture_shifts_with_body::Bool = true
  aperture_active::Bool           = true

  function ApertureParams(x1_limit, x2_limit, y1_limit, y2_limit, aperture_shape, aperture_at, aperture_shifts_with_body, aperture_active)
    return new{promote_type(typeof(x1_limit),typeof(x2_limit),typeof(y1_limit),typeof(y2_limit))}(x1_limit, x2_limit, y1_limit, y2_limit, aperture_shape, aperture_at, aperture_shifts_with_body, aperture_active)
  end
end

Base.eltype(::ApertureParams{T}) where {T} = T
Base.eltype(::Type{ApertureParams{T}}) where {T} = T

function Base.isapprox(a::ApertureParams, b::ApertureParams)
  return a.x1_limit                  ≈  b.x1_limit        &&
         a.x2_limit                  ≈  b.x2_limit        &&
         a.y1_limit                  ≈  b.y1_limit        &&
         a.y2_limit                  ≈  b.y2_limit        &&
         a.aperture_shape            ==  b.aperture_shape &&
         a.aperture_at               ==  b.aperture_at    &&
         a.aperture_shifts_with_body ==  b.aperture_shifts_with_body &&
         a.aperture_active           ==  b.aperture_active
end

isactive(ap::ApertureParams) = ap.aperture_active
