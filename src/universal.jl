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
  n_slices::Int   = 1
  step            = 1  # PROTECTED FROM DIRECT SETS!
  step_meaning::StepMeaning.T = StepMeaning.NSteps # PROTECTED FROM DIRECT SETS!
  radiation_damping_on::Bool = false
  radiation_fluctuations_on::Bool = false
end

Base.propertynames(::UniversalParams) = (:kind, :name, :L, :tracking_method, :n_slices, :n_steps, :ds_step, :radiation_damping_on, :radiation_fluctuations_on)

function Base.setproperty!(up::UniversalParams, key::Symbol, value)
  if key == :step || key == :step_meaning
    error("UniversalParams property $key is protected. Try setting n_steps or ds_step instead.")
  elseif key == :n_steps
    if !isinteger(value)
      error("Cannot set n_steps to be non-integer value: $value")
    elseif value < 1
      error("Cannot set n_steps to be < 1")  
    elseif up.L == 0 && value != 1
      @warn "Ignoring n_steps set: n_steps for zero length element must be 1"
    else
      setfield!(up, :step, Int(value))
      setfield!(up, :step_meaning, StepMeaning.NSteps)
    end
  elseif key == :ds_step
    if value < 0
      error("Cannot set ds_step to be < 0")
    elseif up.L == 0 && value != 0
      @warn "Ignoring ds_step set: ds_step for zero length element must be 0"
    elseif up.L != 0 && value == 0
      error("ds_step must be > 0 for nonzero length element")
    else
      setfield!(up, :step, value)
      setfield!(up, :step_meaning, StepMeaning.DSStep)
    end
  elseif key == :n_slices
    if !isinteger(value)
        error("Cannot set n_slices to be non-integer value: $value")
    elseif value < 1
        error("Cannot set n_slices to be < 1")
    elseif up.L == 0 && value != 1
        @warn "Ignoring n_slices set: n_slices for zero length element must be 1"
    else
        setfield!(up, :n_slices, Int(value))
    end
  elseif key == :L
    if value == 0
      if up.step_meaning == StepMeaning.DSStep && up.step != 0
        @info "Setting ds_step to 0 for element length set to 0"
        setfield!(up, :step, 0)
      elseif up.step_meaning == StepMeaning.NSteps && up.step != 1
        @info "Setting n_steps to 1 for element length set to 0"
        setfield!(up, :step, 1)
      end
      if up.n_slices != 1
        @info "Setting n_slices to 1 for element length set to 0"
        setfield!(up, :n_slices, 1)
      end
    elseif up.step_meaning == StepMeaning.DSStep && up.step == 0
      @info "Setting n_steps to 1 for zero length element set to nonzero length"
      setfield!(up, :step, 1)
      setfield!(up, :step_meaning, StepMeaning.NSteps)
    end
    setfield!(up, :L, value)
  else
    setfield!(up, key, value)
  end
  return value
end

function Base.getproperty(up::UniversalParams, key::Symbol)
  if key == :n_steps
    if up.step_meaning == StepMeaning.NSteps
      return getfield(up, :step)
    else
      return iszero(up.L) ? 1 : max(ceil(Int, abs(up.L) / getfield(up, :step)), 1)
    end
  elseif key == :ds_step
    if up.step_meaning == StepMeaning.DSStep
        return getfield(up, :step)
    else
        return abs(up.L) / up.n_steps
    end
  else
    return getfield(up, key)
  end
end

PROPS(::Type{UniversalParams}) = OrderedDict{String,String}(
  "kind" => "String specifing the \"kind\", of an element, e.g. \"Quadrupole\"",
  "name" => "The name of an element as a string",
  "L"    => "Length of the element [m]",
  "n_steps" => "Number of integrator steps to take per element slice, default is 1",
  "ds_step" => "Length of each integrator step to take per element slice, such that `n_steps = ceil(L / ds_step)`",
  "tracking_method" => "Tracking method for the element, default is `DriftKick` if element kind is not initially specified",
  "radiation_damping_on" => "`true` if the deterministic effect of synchrotron radiation is included, `false` otherwise. Defaults to `false`",
  "radiation_fluctuations_on" => "`true` if the stochastic radiation kicks are included, `false` otherwise. Defaults to `false`",
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