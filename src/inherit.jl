@kwdef mutable struct InheritParams <: AbstractParams
  g::T      = Float32(0.0) # Coordinate system curvature
  e1::T     = Float32(0.0) # Edge 1 angle as SBend from g_ref (e.g. e1 = 0.0 for SBend)
  e2::T     = Float32(0.0) # Edge 2 angle as SBend from g_ref (e.g. e2 = 0.0 for SBend)
  function BendParams(g, e1, e2)
    return new{promote_type(typeof(g),typeof(e1),typeof(e2))}(g, e1, e2)
  end
end