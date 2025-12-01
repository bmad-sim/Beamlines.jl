@kwdef struct MapParams{F<:Function} <: AbstractParams
  transport_map::F = (x, px, y, py, z, pz, q0, q1, q2, q3) -> (x, px, y, py, z, pz, q0, q1, q2, q3)
end

Base.isapprox(a::MapParams, b::MapParams) = a.transport_map == b.transport_map

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