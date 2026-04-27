@kwdef mutable struct BendParams{T} <: AbstractParams
  "Coordinate system curvature [1 / m]"
  g_ref::T        = Float32(0.0) 
  "Tilt angle applied before the curvature, and undone after [rad]"
  tilt_ref::T     = Float32(0.0)
  "Edge angle of the entrance of the element w.r.t. the entering coordinate system [rad]"
  e1::T           = Float32(0.0)   # Edge 1 angle as SBend from g_ref (e.g. e1 = 0.0 for SBend)
  "Edge angle of the exit of the element w.r.t. the exit coordinate system [rad]"
  e2::T           = Float32(0.0)   # Edge 2 angle as SBend from g_ref (e.g. e2 = 0.0 for SBend)
  "Pole face field integral at the entrance [T * m]" 
  edge1_int::T    = Float32(0.0)   # Edge 1 integral. Equal to fint * hgap in Bmad
  "Pole face field integral at the exit [T * m]"
  edge2_int::T    = Float32(0.0)   # Edge 2 integral. Equal to fint * hgap in Bmad
  function BendParams(g_ref, tilt_ref, e1, e2, edge1_int, edge2_int)
    return new{promote_type(typeof(g_ref),typeof(tilt_ref),typeof(e1),typeof(e2),typeof(edge1_int),typeof(edge2_int))}(g_ref, tilt_ref, e1, e2, edge1_int, edge2_int)
  end
end


PROPS(::Type{BendParams}) = OrderedDict{String,String}(
  "g_ref"    => "Coordinate system curvature [1 / m]",
  "tilt_ref" => "Tilt angle applied before the curvature, and undone after [rad]",
  "e1" => "Edge angle of the entrance of the element w.r.t. the entering coordinate system [rad]",
  "e2" => "Edge angle of the exit of the element w.r.t. the exit coordinate system [rad]",
  "edge1_int" => "Pole face field integral at the entrance [T * m]",
  "edge2_int" => "Pole face field integral at the exit [T * m]",
)

"""
    BendParams

Defines a curvature in the reference coordinate system throught the element, 
as well as the edge angles of the element at the entrance and exit of the 
element. Does not specify any magnetic field.

## Properties
$(PROPSDOC(BendParams))
"""
BendParams

Base.eltype(::BendParams{T}) where {T} = T
Base.eltype(::Type{BendParams{T}}) where {T} = T

function Base.isapprox(a::BendParams, b::BendParams)
  return a.g_ref ≈ b.g_ref && 
         a.tilt_ref ≈ b.tilt_ref && 
         a.e1 ≈ b.e1 && 
         a.e2 ≈ b.e2 && 
         a.edge1_int ≈ b.edge1_int && 
         a.edge2_int ≈ b.edge2_int
end

# Note that here the reference energy is really needed to compute anything
# other than the above so there is no more work to do here. Must define 
# virtual properties for the rest of them.
