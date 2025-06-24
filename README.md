# Beamlines

[![Build Status](https://github.com/mattsignorelli/Beamlines.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mattsignorelli/Beamlines.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![codecov](https://codecov.io/github/bmad-sim/Beamlines.jl/graph/badge.svg?token=4776DOLQ8B)](https://codecov.io/github/bmad-sim/Beamlines.jl)

This package defines the `Beamline` and `LineElement` types, which can be used to define particle (or in the future, potentially x-ray) beamlines. The `LineElement` is fully extensible and polymorphic, and has been highly optimized for fast getting/setting of the beamline element parameters. High-order automatic differentiation of parameters, e.g. magnet strengths or lengths, is easy using `Beamlines.jl`. Furthermore, all non-fundamental quantities computed from `LineElement`s are "deferred expressions" in that they are computed only when you need them, and on the fly. There is no "bookkeeper". This both fully minimizes overhead from storing and computing quantities you don't need (especially impactful in optimization loops), and ensures that you don't need to rely on a bookkeeper to properly update all dependent variables, minimizing bugs and easing long term maintainence.

`Beamlines.jl` is best shown with an example:

```julia
using Beamlines, GTPSA

qf = Quadrupole(K1=0.36, L=0.5)
sf = Sextupole(K2=0.1, L=0.5)
d1 = Drift(L=0.6)
b1 = SBend(L=6.0, angle=pi/132)
d2 = Drift(L=1.0)
qd = Quadrupole(K1=-qf.K1, L=0.5)
sd = Sextupole(K2=-sf.K2, L=0.5)
d3 = Drift(L=0.6)
b2 = SBend(L=6.0, angle=pi/132)
d4 = Drift(L=1.0)

# We can access quantities like:
qf.L
qf.K1 # Normalized field strength

sol = Solenoid(Ks=0.12, L=5.3)

# Up to 21st order multipoles allowed:
m21 = Multipole(K21=5.0, L=6)

# Integrated multipoles can also be specified:
m_thin = Multipole(K1L=0.16)
m_thick = Multipole(K1L=0.16, L=2.0)

m_thick.K1L == 0.16    # true
m_thick.K1 == 0.16/2.0 # true

# Whichever you enter first for a specific multipole - integrated/nonintegrated
# and normalized/unnormalized - sets that value to be the independent variable

# Misalignments are also supported:
bad_quad = Quadrupole(K1=0.36, L=0.5, x_offset=0.2e-3, tilt=0.5e-3, y_rot=-0.5e-3)

# All of these are really just one type, LineElement
# E.g. literally,
# Quadrupole(; kwargs) = LineElement("Quadrupole"; kwargs...)
# Feel free to define your own element "classes":
SkewQuadrupole(; kwargs...) = LineElement(class="SkewQuadrupole", kwargs..., tilt1=pi/4)
sqf = SkewQuadrupole(K1=0.36, L=0.2)
# Note that tilt1 specifies a tilt to only the K1 multipole.

# Create a FODO beamline
bl = Beamline([qf, sf, d1, b1, d2, qd, sd, d3, b2, d4], Brho_ref=60.0)

# Now we can get the unnormalized field strengths:
qf.B1

# We can also reset quantities:
qf.B1 = 60.
qf.K1 = 0.36

# Set the tracking method of an element:
struct MyTrackingMethod end
qf.tracking_method = MyTrackingMethod()
# EVERYTHING is a deferred expression, there is no bookkeeper

# Easily get s, and s_downstream, as deferred expression:
qd.s
qd.s_downstream

# We can get all Quadrupoles for example in the line with:
quads = findall(t->t.class == "Quadrupole", bl.line)

# Or just the focusing quadrupoles with:
f_quads = findall(t->t.class == "Quadrupole" && t.K1 > 0., bl.line)

# And of course, EVERYTHING is fully polymorphic for differentiability.
# Let's make the length of the first drift a TPSA variable:
const D = Descriptor(2,1)
ΔL = @vars(D)[1]

d1.L += ΔL

# Now we can see that s and s_downstream are also TPSA variables:
qd.s
qd.s_downstream

# Even the reference energy of the Beamline can be set as 
# a TPSA variable:
ΔBrho_ref = @vars(D)[2]
bl.Brho_ref += ΔBrho_ref

# Now e.g. unnormalized field strengths will be TPSA:
qd.B1

# We can also define control elements to control LineElements
# Let's create a controller which sets the B1 of qf and qd:
c1 = Controller(
  (qf, :K1) => (ele; x) ->  x,
  (qd, :K1) => (ele; x) -> -x;
  vars = (; x = 0.0,)
)

# Now we can vary both simultaneously:
c1.x = 60.
qf.K1
qd.K1

# Controllers also include the element itself. This can 
# be useful if the current elements' values should be 
# used in the function:
c2 = Controller(
  (qf, :K1) => (ele; dK1) ->  ele.K1 + dK1,
  (qd, :K1) => (ele; dK1) ->  ele.K1 - dK1;
  vars = (; dK1 = 0.0,)
)

c2.dK1 = 20

qf.K1
qd.K1

# We can reset the values back to the most recently set state
# of a controller using set!
set!(c1)
qf.K1
qd.K1

# Controllers can also be used to control other controllers:
c3 = Controller(
  (c1, :x) => (ele; dx) -> ele.x + dx;
  vars = (; dx = 0.0,)
)

# And of course still fully polymorphic:
dx = @vars(D)[1]
c3.dx = dx
qf.K1
qd.K1

# Beamlines.jl also provides functionality to convert the Beamline to a
# compressed, fully isbits type. This may be useful in cases where the 
# Beamline is mostly static and you would like to put the entire line on 
# a GPU, for example.
qf = Quadrupole(K1L=0.18, L=0.5)
d1 = Drift(L=1.6)
qd = Quadrupole(K1L=-qf.K1L, L=0.5)
d2 = Drift(L=1.6)

bl = Beamline([qf, d1, qd, d2])
bbl = BitsBeamline(bl) # Fully immutable, isbits compressed type

# A warning will be issued if the size is >64KB (CUDA constant memory)
sizeof(bbl) 

# Convert back:
bl2 = Beamline(bbl)
all(bl.line .≈ bl2.line) # true
```

## Contributing to `Beamlines.jl`

`Beamlines.jl` was designed in such a way so that, by construction, many classes of bugs are simply not possible. The key principle is that the `Beamline` and `LineElement`s are never "corruptable" - the code and state is **always** self-consistent, and minimal. Only the bare-minimum independent variables needed to fully define the `LineElement` and `Beamline` are stored.

To abide by the rules of `Beamlines.jl`, **all** parameter groups must be fully self-consistent _outside of the context of a `LineElement`_. As an example, let us consider a new parameter group which has _fields_ corresponding to various parameters of a rectangle, including the lengths of its sides, area, and perimeter:

```julia
@kwdef mutable struct BadRectangleParams{T} <: AbstractParams
  x::T        = 0.
  y::T        = 0.
  area::T      = 0.
  perimeter::T = 0.
end

# Convenience constructor:
function BadRectangleParams(x, y)
  area = x*y
  perimeter = 2*x + 2*y
  return BadRectangleParams(x, y, area, perimeter)
end
```

Such a parameter group definition is **NOT** allowed in `Beamlines.jl`, because the internal state is easily corruptable:

```julia
badrect = BadRectangleParams(1.0, 2.0)
badrect.area = 12345.6789 # Now area is incorrect
```

This is why only **independent** variables must be stored as **fields** in the parameter groups.

However, what if we are interested in accessing such dependent variables frequently? Two ways to go about this in a consistent and correct way are:

```julia
@kwdef mutable struct RectangleParams{T} <: AbstractParams
  x::T        = 0.
  y::T        = 0.
end

# 1: Unique getter functions, e.g.:
area(r::RectangleParams)      = r.x*r.y
perimeter(r::RectangleParams) = 2*r.x + 2*r.y

# 2: General-purpose getter function, e.g.:
function get_variable(r::RectangleParams, key::Symbol)
  if key == :area
    return r.x*r.y
  elseif key == :perimeter
    return 2*r.x + 2*r.y
  else # Fall back to getting the field of the parameter group
    return getfield(r, key)
  end
end


rect = RectangleParams(1.0, 2.0)

# Now we can do one of either:
x = rect.x
y = rect.y
a = area(rect)
p = perimeter(rect)

x = get_variable(rect, :x)
y = get_variable(rect, :y)
a = get_variable(rect, :area)
p = get_variable(rect, :perimeter)
```

Both of these methods will work fine, and for many applications. The first is generally the most recommended approach. However, for `Beamlines.jl`, there is a third way which is used throughout the package.

It turns out that writing 
```julia
x = rect.x
```

lowers to

```julia
x = Base.getproperty(rect, :x)
```

and `Base.getproperty` basically has the _default_ implementation

```julia
Base.getproperty(r, :x) = getfield(r, :x)
```
where `getfield` is a part of `Core`, meaning it isn't overloadable. We now see a distinction between `fields` of a struct - which for `RectangleParams` are `x` and `y`, and `properties` of a struct, which we can actually make anything by overriding `Base.getproperty` for our given type.

So for `RectangleParams` we can actually do:

```julia
function Base.getproperty(r::RectangleParams, key::Symbol)
  if key == :area
    return r.x*r.y
  elseif key == :perimeter
    return 2*r.x + 2*r.y
  else # Fall back to getfield
    return getfield(r, key)
  end
end

# Now:
x = rect.x
y = rect.y
a = rect.area
p = rect.perimeter
```

Likewise, there is `Base.setproperty!` and `setfield!` for setting fields in a struct. For example, we can add a settable-only property called `square` which receives the length of one side of a square and sets the `RectangleParams` to represent the square:

```julia
function Base.setproperty!(r::RectangleParams{T}, key::Symbol, value) where {T}
  if key == :square
    # note that these will call setproperty!, then go to other branch 
    # below in the conditional
    r.x = value
    r.y = value
  elseif key == :area || key == :perimeter
    error("Properties `area` and `perimeter` are not settable")
  else
    # Note that setfield! will not automatically promote the input 
    # to the struct field type, and will error if the types don't agree
    setfield!(r, key, T(value))
  end
  return value
end
```

For good practice, we should also add a conditional in `Base.getproperty` checking if the symbol is `:square`, and giving a descriptive error to the user the `square` is not a gettable property.

Now we have a struct which has the fields `x` and `y`, two gettable-only properties `area` and `perimeter`, and a settable-only property `square`. For full consistency with both Julia and with `Beamlines.jl`, we will need to override `Base.propertynames` to include these properties:

```julia
Base.propertynames(::RectangleParams) = (:x, :y, :area, :perimeter)
```

In `Beamlines.jl`, the `LineElement` struct has only a dictionary of `AbstractParams` as a field. Both `Base.getproperty` and `Base.setproperty!` are overridden to call `Base.getproperty` and/or `Base.setproperty!` for a given parameter group and its properties, which can also be overridden by each parameter group. It is basically a tree of overridden  `Base.getproperty` and `Base.setproperty!`. 

As an example, let's formally add `RectangleParams` as a parameter group to `LineElement`. First, I will need to tell `LineElement` that the symbol `:RectangleParams` corresponds to a property. This is done with the `Beamlines.PARAMS_MAP` dictionary:

```julia
Beamlines.PARAMS_MAP[:RectangleParams] = RectangleParams

# Now we can do:
ele = LineElement()
rect = RectangleParams(1.0, 2.0)
ele.RectangleParams = rect
rect.x = 5.0
ele.RectangleParams.x == 5.0 # true
```

Now, if I want to do `ele.x`, `ele.y`, `ele.area`, `ele.perimeter`, and `ele.square = 123`, I need to tell `Beamlines.jl` which parameter group the symbols `:x`, `:y`, etc belong to. This is done in the `Beamlines.PROPERTIES_MAP` dictionary:

```julia
Beamlines.PROPERTIES_MAP[:x] = RectangleParams
Beamlines.PROPERTIES_MAP[:y] = RectangleParams
Beamlines.PROPERTIES_MAP[:area] = RectangleParams
Beamlines.PROPERTIES_MAP[:perimeter] = RectangleParams
Beamlines.PROPERTIES_MAP[:square] = RectangleParams

# Now we can do:

ele = LineElement(x = 1.0, y = 2.0)
ele.RectangleParams
ele.x = 5.0

ele.square = 6.0
ele.area == 36 # true
```

Finally, there are certain 

Any struct inheriting `AbstractParams` must have a default constructor with no arguments, which produced a parameter group that has no impact on the physics. E.g. for `RectangleParams`, because I defined it using `@kwdef` and specified default values for each field, I can just write

```julia
RectangleParams()
```










```julia
ele = Quadrupole(L=0.5, K1=0.36) 
ele.BMultipoleParams
```