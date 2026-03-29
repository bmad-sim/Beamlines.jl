@kwdef mutable struct MapParams{F<:Function, P} <: AbstractParams
  transport_map::F = (v, q, p=nothing) -> (v, q)
  transport_map_params::P = nothing
end

function Base.isapprox(a::MapParams, b::MapParams)
  if xor(isnothing(a.transport_map_params), isnothing(b.transport_map_params))
    return false
  elseif isnothing(a.transport_map_params) && isnothing(b.transport_map_params)
    return a.transport_map == b.transport_map
  else
    return a.transport_map == b.transport_map && 
          all(a.transport_map_params .≈ b.transport_map_params)
  end
end


# === THIS BLOCK WAS PARTIALLY WRITTEN BY CLAUDE ===
# Generated function for arbitrary-length tuples
@generated function deval(mp::MapParams{F,P}) where {F,P<:Tuple}
    N = length(P.parameters)
    # Use getfield with literal integer arguments
    exprs = [:(deval(Base.getfield(mp.transport_map_params, $i))) for i in 1:N]
    return :(MapParams(mp.transport_map, tuple($(exprs...))))
end
# === END CLAUDE ===

@kwdef mutable struct FourPotentialParams{F<:Function, P} <: AbstractParams
  four_potential::F = (x, y, s, t, p=nothing) -> ((0, 0, 0, 0), (0, 0, 0, 0,
                                                                 0, 0, 0, 0,
                                                                 0, 0, 0, 0,
                                                                 0, 0, 0, 0)) 
  # Returns ((ϕ, Ax, Ay, As), (∂ϕ/∂x,  ∂ϕ/∂y,  ∂ϕ/∂s,  ∂ϕ/∂t,
  #                            ∂Ax/∂x, ∂Ax/∂y, ∂Ax/∂s, ∂Ax/∂t,
  #                            ∂Ay/∂x, ∂Ay/∂y, ∂Ay/∂s, ∂Ay/∂t,
  #                            ∂As/∂x, ∂As/∂y, ∂As/∂s, ∂As/∂t).
  # If four_potential[2] is nothing, the derivatives are computed by 
  # automatic differentiation during tracking, which is probably slower.
  four_potential_params::P = nothing
  four_potential_normalized::Bool = false 
  # true means the potential/derivatives are p_over_q_ref * four_potential;
  # false means the potential/derivatives are four_potential.
end

function Base.isapprox(a::FourPotentialParams, b::FourPotentialParams)
  if xor(isnothing(a.four_potential_params), isnothing(b.four_potential_params))
    return false
  elseif isnothing(a.four_potential_params) && isnothing(b.four_potential_params)
    return (a.four_potential == b.four_potential && 
           a.four_potential_normalized == b.four_potential_normalized)
  else
    return (a.four_potential == b.four_potential && 
            a.four_potential_normalized == b.four_potential_normalized &&
            all(a.four_potential_params .≈ b.four_potential_params))
  end
end

@kwdef mutable struct MetaParams <: AbstractParams
  alias::String = ""
  label::String = ""
  description::String = ""
end

# isapprox ignores MetaParams
Base.isapprox(a::MetaParams, b::MetaParams) = true
