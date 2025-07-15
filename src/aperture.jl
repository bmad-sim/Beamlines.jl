@enumx ApertureShape Elliptical Rectangular
@enumx ApertureAt Entrance Exit BothEnds

@kwdef mutable struct ApertureParams{T} <: AbstractParams
  x1_limit::T                     = Float32(0)                     
  x2_limit::T                     = Float32(0)
  y1_limit::T                     = Float32(0)
  y2_limit::T                     = Float32(0) 
  aperture_shape::ApertureShape.T = ApertureShape.Elliptical
  aperture_at::ApertureAt.T       = ApertureAt.Entrance
  aperture_shifts_with_body::Bool = true
  function ApertureParams(x1_limit, x2_limit, y1_limit, y2_limit, aperture_shape, aperture_at, aperture_shifts_with_body)
    return new{promote_type(typeof(x1_limit),typeof(x2_limit),typeof(y1_limit),typeof(y2_limit))}(x1_limit, x2_limit, y1_limit, y2_limit, aperture_shape, aperture_at, aperture_shifts_with_body)
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
         a.aperture_shifts_with_body ==  b.aperture_shifts_with_body
end
Base.getproperty(a::ApertureParams, key::Symbol) = deval(getfield(a, key))

# Note that here the reference energy is really needed to compute anything
# other than the above so there is no more work to do here. Must define 
# virtual properties for the rest of them.
