@kwdef mutable struct BendParams{T} <: AbstractParams
  g_ref::T        = Float32(0.0)   # Coordinate system curvature
  tilt_ref::T     = Float32(0.0)
  e1::T           = Float32(0.0)   # Edge 1 angle as SBend from g_ref (e.g. e1 = 0.0 for SBend)
  e2::T           = Float32(0.0)   # Edge 2 angle as SBend from g_ref (e.g. e2 = 0.0 for SBend)
  edge_int1::T    = Float32(0.0)   # Edge 1 integral. Equal to fint * hgap in Bmad
  edge_int2::T    = Float32(0.0)   # Edge 2 integral. Equal to fint * hgap in Bmad
  function BendParams(g_ref, tilt_ref, e1, e2, edge_int1, edge_int2)
    return new{promote_type(typeof(g_ref),typeof(tilt_ref),typeof(e1),typeof(e2))}(g_ref, tilt_ref, e1, e2, edge_int1, edge_int2)
  end
end

Base.eltype(::BendParams{T}) where {T} = T
Base.eltype(::Type{BendParams{T}}) where {T} = T

function Base.isapprox(a::BendParams, b::BendParams)
  return a.g_ref ≈ b.g_ref && 
         a.tilt_ref ≈ b.tilt_ref && 
         a.e1 ≈ b.e1 && 
         a.e2 ≈ b.e2 && 
         a.edge_int1 ≈ b.edge_int1 && 
         a.edge_int2 ≈ b.edge_int2
end

function deval(a::BendParams{<:DefExpr})
  return BendParams(
    deval(a.g_ref),  
    deval(a.tilt_ref),
    deval(a.e1),     
    deval(a.e2),       
    deval(a.edge_int1),     
    deval(a.edge_int2),       
  )
end


# Note that here the reference energy is really needed to compute anything
# other than the above so there is no more work to do here. Must define 
# virtual properties for the rest of them.
