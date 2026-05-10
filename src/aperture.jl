# TODO: Docs for ApertureShape, ApertureAt, ApertureParams, and PROPS(::Type{ApertureParams})
"""
    @enumx ApertureShape::UInt8 Elliptical Rectangular

Defines the shape of the aperture
"""
@enumx ApertureShape::UInt8 Elliptical Rectangular

"""
    @enumx ApertureAt::UInt8 Entrance Exit BothEnds
  
Defines at which ends of the element the aperture should be applied
"""
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

PROPS(::Type{ApertureParams}) = OrderedDict{String,String}(
  "x1_limit" => "Left x-axis aperture edge [m]",
  "x2_limit" => "Right x-axis aperture edge [m]",
  "y1_limit" => "Lower y-axis aperture edge [m]",
  "y2_limit" => "Upper y-axis aperture edge [m]",
  "aperture_shape" => "Shape of the aperture, see `ApertureShape`",
  "aperture_at" => "Longitudinal aperture location(s), see `ApertureAt`",
  "aperture_shifts_with_body" => "`true` if the aperture position moves with element alignment, `false` otherwise. Default is `true`",
  "aperture_active" => "`true` if particles are collimated by aperture, `false` otherwise. Default is `true`",
)

"""
    ApertureParams

Describe a mechanical aperture.

## Properties
$(PROPSDOC(ApertureParams))
"""
ApertureParams

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
