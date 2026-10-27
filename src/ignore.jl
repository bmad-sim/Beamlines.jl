@kwdef mutable struct IgnoreParams <: AbstractParams
  ignore_params::Vector{Type{<:AbstractParams}} = Type{<:AbstractParams}[]
end

PROPS(::Type{IgnoreParams}) = OrderedDict{String,String}(
  "ignore_params" => "List of parameter groups of the element to be ignored, e.g. `[BMultipoleParams]`",
)

"""
    IgnoreParams

Holds a list of parameter groups of a `LineElement` to be ignored, which allows parameter
groups to be switched off without removing them from the element. Beamlines itself only
stores the list: what ignoring a parameter group means is up to downstream code, such as
tracking.

```julia
ele = Quadrupole(L=0.5, Kn1=0.3, x_offset=1e-3)
ele.ignore_params = [AlignmentParams]                   # Ignore the AlignmentParams
ele.ignore_params = [AlignmentParams, BMultipoleParams] # Also ignore the BMultipoleParams
ele.ignore_params = []                                  # Ignore nothing
```

`ignore_params` can also be set as a keyword argument, e.g.
`Quadrupole(L=0.5, Kn1=0.3, ignore_params=[BMultipoleParams])`. The value must be a vector,
even for a single parameter group, e.g. `ele.ignore_params = [AlignmentParams]`.


## Properties
$(PROPSDOC(IgnoreParams))
"""
IgnoreParams

# The order of the list does not matter
Base.isapprox(a::IgnoreParams, b::IgnoreParams) = issetequal(a.ignore_params, b.ignore_params)
