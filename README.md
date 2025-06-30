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


# Duplicate elements are allowed. In this case, the first element 
# instance is used as the "parent", and all duplicates parameters 
# are pulled directly from the parent
qf = Quadrupole(K1=0.36, L=0.5)
d = Drift(L=1)
qd = Quadrupole(K1=-0.36, L=0.5)

fodo = Beamline([qf, d, qd, d, qf, d, qd, d])
bl.line[1] === qf # egality with first instance

# reset parent
qf.K1 = 0.1

# second instance
qf2 = fodo.line[5]
qf2.K1 == 0.1 # true
```
