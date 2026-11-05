@enumx StepMeaning::Int8 DSStep NSteps

"""
    @enumx Fringe::Int8 NoEnd BothEnds EntranceEnd ExitEnd

Defines which ends fringe field modelling should be included
"""
@enumx Fringe::Int8 NoEnd BothEnds EntranceEnd ExitEnd

@kwdef mutable struct UniversalParams <: AbstractParams
  kind            = ""
  name            = ""
  L               = 0f0
  tracking_method = nothing
  n_slices::Int   = 1
  step            = 1  # PROTECTED FROM DIRECT SETS!
  step_meaning::StepMeaning.T = StepMeaning.NSteps # PROTECTED FROM DIRECT SETS!
  fringe_at::Fringe.T = Fringe.BothEnds
  rad_damping::Bool = false
  rad_fluctuations::Bool = false
end

param_replace(p::UniversalParams, key::Symbol, value) = (setproperty!(p, key, value); p)

Base.propertynames(::UniversalParams) = (:kind, :name, :L, :tracking_method, :n_slices, :n_steps, :ds_step, :fringe_at, :rad_damping, :rad_fluctuations)

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
      if !(up.tracking_method isa Exact)
        @info "Setting tracking_method to Exact for element length set to 0"
        setfield!(up, :tracking_method, Exact())
      end
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
      return iszero(up.L) ? 1 : max(ceil(Int, abs(up.L) / up.n_slices / getfield(up, :step)), 1)
    end
  elseif key == :ds_step
    if up.step_meaning == StepMeaning.DSStep
      return getfield(up, :step)
    else
      return abs(up.L) / up.n_slices / up.n_steps
    end
  else
    return getfield(up, key)
  end
end

PROPS(::Type{UniversalParams}) = OrderedDict{String,String}(
  "kind" => "String specifing the \"kind\", of an element, e.g. \"Quadrupole\"",
  "name" => "The name of an element as a string",
  "L"    => "Length of the element [m]",
  "fringe_at" => "A `Fringe` that specifies which, if any, element ends should include fringe field modelling. Default is `Fringe.BothEnds`",
  "n_steps" => "Number of integrator steps to take per element slice, default is 1",
  "ds_step" => "Length of each integrator step to take per element slice, such that `n_steps = ceil(L / n_slices / ds_step)`",
  "n_slices" => "Number of slices to split the element into in tracking, typically so that collective effects can be applied multiple times 
  in an element. If no collective effects are included, then prefer to vary `n_steps`/`ds_step` instead for performance.",
  "tracking_method" => "Tracking method for the element",
  "rad_damping" => "`true` if the deterministic effect of synchrotron radiation is included, `false` otherwise. Defaults to `false`",
  "rad_fluctuations" => "`true` if the stochastic radiation kicks are included, `false` otherwise. Defaults to `false`",
)

"""
    UniversalParams

Describes the kind, name, length, and tracking method for a `LatElement`.

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
    if field == :step || field == :step_meaning
      continue
    elseif field == :tracking_method
      tm = getproperty(a, field)
      print(io, " ", rpad(String(field), width), " = ", param_repr(Base.typename(typeof(tm)).wrapper), "(")
      subfields = fieldnames(typeof(tm))
      if length(subfields) != 0
        println(io)
        subwidth = maximum(length, String.(subfields))
        for subfield in subfields
          println(io, "   ",  rpad(String(subfield), subwidth), " = ", param_repr(getproperty(tm, subfield)), ",")
        end
        println(io, " )")
      else
        println(io, ")")
      end
      if a.step_meaning == StepMeaning.NSteps
        println(io, " ", rpad("n_steps", width), " = ", param_repr(a.n_steps))
      elseif a.step_meaning == StepMeaning.DSStep
        println(io, " ", rpad("ds_step", width), " = ", param_repr(a.ds_step))
      end
    else
      println(io, " ", rpad(String(field), width), " = ", param_repr(getproperty(a, field)))
    end
  end
  return
end

function Base.isapprox(a::UniversalParams, b::UniversalParams)
  return a.tracking_method  == b.tracking_method &&
        a.L                ≈  b.L &&
        a.n_slices         == b.n_slices &&
        a.n_steps          == b.n_steps &&
        a.fringe_at        == b.fringe_at &&
        a.rad_damping      == b.rad_damping &&
        a.rad_fluctuations == b.rad_fluctuations
end