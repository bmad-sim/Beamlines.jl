@kwdef mutable struct BendParams{T} <: AbstractParams
  g_ref::T        = Float32(0.0) # Coordinate system curvature
  tilt_ref::T     = Float32(0.0)
  e1::T           = Float32(0.0) # Edge 1 angle as SBend from g_ref (e.g. e1 = 0.0 for SBend)
  e2::T           = Float32(0.0) # Edge 2 angle as SBend from g_ref (e.g. e2 = 0.0 for SBend)
  function BendParams(g_ref, tilt_ref, e1, e2)
    return new{promote_type(typeof(g_ref),typeof(tilt_ref),typeof(e1),typeof(e2))}(g_ref, tilt_ref, e1, e2)
  end
end

Base.eltype(::BendParams{T}) where {T} = T
Base.eltype(::Type{BendParams{T}}) where {T} = T

Base.isapprox(a::BendParams, b::BendParams) = a.g_ref ≈ b.g_ref && a.tilt_ref ≈ b.tilt_ref && a.e1 ≈ b.e1 && a.e2 ≈ b.e2
Base.getproperty(a::BendParams, key::Symbol) = deval(getfield(a, key))

# Note that here the reference energy is really needed to compute anything
# other than the above so there is no more work to do here. Must define 
# virtual properties for the rest of them.
