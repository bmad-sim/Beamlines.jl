# Default tracking method:
"""
    SciBmadStandard

Default tracking method that uses exact transport maps when solvable, else uses the 
symplectic integrator `Yoshida(order=4, num_steps=1)` which chooses an appropriate split 
for each element.

## Properties
- `radiation_damping_on`: `true` if the deterministic effect of synchrotron radiation 
    is included, `false` otherwise. Defaults to `false`
- `radiation_fluctuations_on`: `true` if the stochastic radiation kicks are included, 
    `false` otherwise. Defaults to `false`
- `ibs_damping_on`: true if the deterministic effect of intrabeam scattering (IBS) is 
    included, `false` otherwise. Defaults to `false`.
- `ibs_fluctuations_on`: true if the stochastic kicks of intrabeam scattering (IBS) is 
    included, `false` otherwise. Defaults to `false`.
"""
@kwdef struct SciBmadStandard
  ibs_damping_on::Bool = false
  ibs_fluctuations_on::Bool = false
end

@enumx StepMeaning::Int8 DSStep NSteps

@kwdef mutable struct UniversalParams <: AbstractParams
  kind            = ""
  name            = ""
  L               = Float32(0.0)
  tracking_method = SciBmadStandard()
  n_slices::UInt  = 1
  step::Float64   = 1
  const step_meaning::StepsMeaning.T = StepMeaning.NSteps
  radiation_damping_on::Bool = false
  radiation_fluctuations_on::Bool = false
end

PROPS(::Type{UniversalParams}) = OrderedDict{String,String}(
  "kind" => "String specifing the \"kind\", of an element, e.g. \"Quadrupole\"",
  "name" => "The name of an element as a string",
  "L"    => "Length of the element [m]",
  "tracking_method" => "Tracking method for the element, defaults to `SciBmadStandard()`"
)

"""
    UniversalParams

Describes the kind, name, length, and tracking method for a `LineElement`.

## Properties
$(PROPSDOC(UniversalParams))
"""
UniversalParams

# For UniversalParams, print each tracking_method field:
function Base.show(io::IO, a::UniversalParams)
  fields = fieldnames(typeof(a))
  width = maximum(length, String.(fields))
  println(io, nameof(typeof(a)))
  for field in fields
    if field == :tracking_method
      tm = getproperty(a, field)
      println(io, " ", rpad(String(field), width), " = ", param_repr(typeof(tm)), "(")
      subfields = fieldnames(typeof(tm))
      subwidth = maximum(length, String.(subfields))
      for subfield in subfields
        println(io, "   ",  rpad(String(subfield), subwidth), " = ", param_repr(getproperty(tm, subfield)), ",")
      end
      println(io, " )")
    else
      println(io, " ", rpad(String(field), width), " = ", param_repr(getproperty(a, field)))
    end
  end
  return
end

function Base.isapprox(a::UniversalParams, b::UniversalParams)
  return a.tracking_method == b.tracking_method &&
         a.L               ≈  b.L
         # Only compare things that affect the physics
         #a.kind           == b.kind &&
         #a.name            
end