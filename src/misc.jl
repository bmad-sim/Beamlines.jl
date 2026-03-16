@kwdef mutable struct MapParams{F<:Function, P} <: AbstractParams
  transport_map::F = (v, q, p=nothing) -> (v, q)
  transport_map_params::P = nothing
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