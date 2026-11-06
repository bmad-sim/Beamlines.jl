"""
    @enumx IBSModel::Int8 None Gaussian GaussianDampingOnly GaussianFluctuationsOnly

Which intra-beam scattering model should be used.
"""
@enumx IBSModel::Int8 None Gaussian GaussianDampingOnly GaussianFluctuationsOnly

@kwdef mutable struct IBSParams <: AbstractParams
  ibs_model::IBSModel.T = IBSModel.None
end

PROPS(::Type{IBSParams}) = OrderedDict{String,String}(
  "ibs_model" => "A `IBSModel` that specifies which intra-beam scattering model is used",
)

"""
    IBSParams

Defines intra-beam scattering modelling.

## Properties
$(PROPSDOC(IBSParams))
"""
IBSParams

function Base.isapprox(a::IBSParams, b::IBSParams)
  return a.ibs_model == b.ibs_model
end
