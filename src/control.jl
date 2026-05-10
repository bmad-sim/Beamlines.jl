"""
    Controller

An *eagerly*-evaluated controller of `LineElement` properties or other `Controller`
properties. Similar to classical Bmad's "Overlay" or "Group".

Also see `set!`.

!!! tip
    In SciBmad, it is generally preferred to use the *lazily*-evaluated `DefExpr` for 
    deferred expressions. 

## Examples
```julia
qf = Quadrupole(Kn1=0.36, L=0.5)
qd = Quadrupole(Kn1=-0.36, L=0.5)

c1 = Controller(
  (qf, :Kn1) => (ele; x) ->  x,
  (qd, :Kn1) => (ele; x) -> -x;
  vars = (; x = 0.0,)
)

# Now we can vary both simultaneously:
c1.x = 60.
qf.Kn1 == -qd.Kn1 == 60 # true

# Controllers also include the element itself. This can 
# be useful if the current elements' values should be 
# used in the function:
c2 = Controller(
  (qf, :Kn1) => (ele; dKn1) ->  ele.Kn1 + dKn1,
  (qd, :Kn1) => (ele; dKn1) ->  ele.Kn1 - dKn1;
  vars = (; dKn1 = 0.0,)
) 

c2.dKn1 = 20
qf.Kn1 == -qd.Kn1 == 80 # true

# Controllers can also be used to control other controllers:
c3 = Controller(
  (c1, :x) => (ctrl; dx) -> ctrl.x + dx;
  vars = (; dx = 0.0,)
)
```

"""
mutable struct Controller
  fcns::Dict{Tuple{Union{Controller,LineElement},Symbol},Function}
  vars::NamedTuple
  function Controller(pairs...; vars=(; x=0.0,))
    fcns = Dict(pairs...)
    return new(fcns, vars)
  end
end

function Base.setproperty!(c::Controller, key::Symbol, value)
  if !(key in (:fcns, :vars))
    c.vars = set(c.vars, opcompose(PropertyLens(key)), value)
    _run_controller(c, c.vars)
    return value
  else
    return setfield!(c, key, value)
  end
end

function Base.getproperty(c::Controller, key::Symbol)
  if !(key in (:fcns, :vars))
    return getfield(c.vars, key)
  else
    return getfield(c, key)
  end
end

"""
    set!(controller)

Resets all controlled `LineElement`s and `Controllers` in `controller` to the most recently 
set values of that `controller`.
"""
function set!(c::Controller; kwargs...)
  vars = c.vars # Unpack the vars (costly)
  # question: should I unpack all the 
  # Function barrier
  c.vars = _set!(c, vars, kwargs)
  return c.vars
end

function _set!(c, vars, kwargs)
  newvars = merge(vars, values(kwargs))
  _run_controller(c, newvars)
  return newvars
end

function _run_controller(c, vars)
  fcns = c.fcns
  for (ele_and_prop,f) in fcns
    ele = first(ele_and_prop)
    prop = last(ele_and_prop)
    val = f(ele; vars...)
    setproperty!(ele, prop, val)
  end
  return
end
