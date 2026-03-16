@kwdef mutable struct IBSParams{T} <: AbstractParams
  ibs_num_particles::T      = Int64(0)
  ibs_damping_on::Bool      = true # on by default because no IBS for 0 particles
  ibs_fluctuations_on::Bool = true
end

function Base.isapprox(a::IBSParams, b::IBSParams)
  return a.ibs_num_particles   ≈  b.ibs_num_particles &&
         a.ibs_damping_on      == b.ibs_damping_on &&
         a.ibs_fluctuations_on == b.ibs_fluctuations_on
end