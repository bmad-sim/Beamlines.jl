@kwdef mutable struct IgnoreParams <: AbstractParams
  ignore_params::Vector{Type{<:AbstractParams}} = Type{<:AbstractParams}[]
end

PROPS(::Type{IgnoreParams}) = OrderedDict{String,String}(
  "ignore_params" => "List of the parameter groups of the element to not use in tracking, e.g. `[BMultipoleParams]`",
)

"""
    IgnoreParams

Holds the list of parameter groups of a `LineElement` that are ignored in tracking. Any
parameter group in the list is ignored without having to remove it from the element, which
makes it easy to switch parameter groups on and off:

```julia
ele = Quadrupole(L=0.5, Kn1=0.3, x_offset=1e-3)
ele.ignore_params = [AlignmentParams]  # Track as if the quadrupole were not misaligned
ele.ignore_params = [AlignmentParams, BMultipoleParams] # Also ignore the multipoles
ele.ignore_params = []                 # Use all parameter groups again
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

# Parameter groups that are always needed and so cannot be ignored
const NOT_IGNORABLE_PARAMS = (BeamlineParams, InitialBeamlineParams, IgnoreParams)

"""
    check_ignore_params(ignore_params)

Throws an error if any entry in `ignore_params` is not a parameter group type in `PARAMS_MAP`,
or is one of the parameter groups that are always needed (`BeamlineParams`,
`InitialBeamlineParams`, and `IgnoreParams`). Otherwise returns `ignore_params`.
"""
function check_ignore_params(ignore_params)
  for pg in ignore_params
    if !any(==(pg), values(PARAMS_MAP)) || any(==(pg), NOT_IGNORABLE_PARAMS)
      valid = sort!([string(v) for v in values(PARAMS_MAP) if !any(==(v), NOT_IGNORABLE_PARAMS)])
      error("Invalid entry $(repr(pg)) in `ignore_params`. Valid entries are the parameter " *
            "group types: " * join(valid, ", "))
    end
  end
  return ignore_params
end
