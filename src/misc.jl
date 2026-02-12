@kwdef mutable struct MapParams{F<:Function, P<:Tuple} <: AbstractParams
  transport_map::F = (v, q, p=nothing) -> (v, q)
  transport_map_params::P = ()
end

function Base.isapprox(a::MapParams, b::MapParams)
  return a.transport_map == b.transport_map && 
         a.transport_map_params ≈ b.transport_map_params
end

# === THIS BLOCK WAS WRITTEN BY CLAUDE ===
# Generated function for arbitrary-length tuples
@generated function deval(mp::MapParams{F,P}) where {F,P}
    N = length(P.parameters)
    if N == 0
        return :(())
    end
    # Use getfield with literal integer arguments
    exprs = [:(deval(Base.getfield(mp.transport_map_params, $i))) for i in 1:N]
    return :(MapParams(mp.transport_map, tuple($(exprs...))))
end
# === END CLAUDE ===

@kwdef struct FourPotentialParams{F<:Function} <: AbstractParams
  four_potential::F = (x, y, s, t) -> (0, 0, 0, 0) # Returns phi, Ax, Ay, Az
end

Base.isapprox(a::FourPotentialParams, b::FourPotentialParams) = a.four_potential == b.four_potential

@kwdef mutable struct MetaParams <: AbstractParams
  alias::String = ""
  label::String = ""
  description::String = ""
end

# isapprox ignores MetaParams
Base.isapprox(a::MetaParams, b::MetaParams) = true