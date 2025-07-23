# Beamlines

[![Build Status](https://github.com/mattsignorelli/Beamlines.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mattsignorelli/Beamlines.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![codecov](https://codecov.io/github/bmad-sim/Beamlines.jl/graph/badge.svg?token=4776DOLQ8B)](https://codecov.io/github/bmad-sim/Beamlines.jl)

This package defines the `Beamline` and `LineElement` types, which can be used to define particle (or in the future, potentially x-ray) beamlines. The `LineElement` is fully extensible and polymorphic, and has been highly optimized for fast getting/setting of the beamline element parameters. High-order automatic differentiation of parameters, e.g. magnet strengths or lengths, is easy using `Beamlines.jl`. Furthermore, all non-fundamental quantities computed from `LineElement`s are computed lazily as deferred expressions. There is no eager "bookkeeper". This both fully minimizes overhead from storing and computing quantities you don't need (especially impactful in optimization loops), and ensures that you don't need to rely on a bookkeeper to properly update all dependent variables, minimizing bugs and easing long term maintainence. Furthermore, the generic `DefExpr` type is provided as a general usage lazily-evaluated deferred expression for controlling potentially many parameters with only a single update.

`Beamlines.jl` is best shown with an example:

```julia
using Beamlines, GTPSA

qf = Quadrupole(Kn1=0.36, L=0.5)
sf = Sextupole(Kn2=0.1, L=0.5)
d1 = Drift(L=0.6)
Bn1 = SBend(L=6.0, angle=pi/132)
d2 = Drift(L=1.0)
qd = Quadrupole(Kn1=-qf.Kn1, L=0.5)
sd = Sextupole(Kn2=-sf.Kn2, L=0.5)
d3 = Drift(L=0.6)
b2 = SBend(L=6.0, angle=pi/132)
d4 = Drift(L=1.0)

# We can access quantities like:
qf.L
qf.Kn1 # Normalized field strength

sol = Solenoid(Ksol=0.12, L=5.3)

# Up to 21st order multipoles allowed:
m21 = Multipole(Kn21=5.0, L=6)

# Integrated multipoles can also be specified:
m_thin = Multipole(Kn1L=0.16)
m_thick = Multipole(Kn1L=0.16, L=2.0)

m_thick.Kn1L == 0.16    # true
m_thick.Kn1 == 0.16/2.0 # true

# Whichever you enter first for a specific multipole - integrated/nonintegrated
# and normalized/unnormalized - sets that value to be the independent variable

# Misalignments are also supported:
bad_quad = Quadrupole(Kn1=0.36, L=0.5, x_offset=0.2e-3, tilt=0.5e-3, y_rot=-0.5e-3)

# All of these are really just one type, LineElement
# E.g. literally,
# Quadrupole(; kwargs) = LineElement("Quadrupole"; kwargs...)
# Feel free to define your own element "classes":
SkewQuadrupole(; kwargs...) = LineElement(; class="SkewQuadrupole", kwargs..., tilt1=pi/4)
sqf = SkewQuadrupole(Kn1=0.36, L=0.2)
# Alternatively and equivalently:
sqf = Quadrupole(Ks1=0.36, L=0.2)
# Note that tilt1 specifies a tilt to only the Kn1 multipole.

# Create a FODO beamline
bl = Beamline([qf, sf, d1, Bn1, d2, qd, sd, d3, b2, d4], Brho_ref=60.0)

# Now we can get the unnormalized field strengths:
qf.Bn1

# We can also reset quantities:
qf.Bn1 = 60.
qf.Kn1 = 0.36

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
f_quads = findall(t->t.class == "Quadrupole" && t.Kn1 > 0., bl.line)

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
qd.Bn1

# We can control elements together using the deferred expression 
# type DefExpr. DefExpr uses closures to evaluate a parameter, 
# and is always evaluated when *pulling* a value from a Beamline.
# Let's use DefExpr to set the Kn1 of qf and qd together

Kn1 = 0.36
qf.Kn1 = DefExpr(()->Kn1)
qd.Kn1 = DefExpr(()->-qf.Kn1)

# The quadrupole strength values are set to anonymous functions 
# which "stores"/"encloses" the value of Kn1 in the evaluated scope.

# When getting a parameter which is a DefExpr from a LineElement
# or parameter group, the deferred expression is evaluated:
qf.Kn1 == 0.36 # true
qd.Kn1 == -0.36 # true

Kn1 = 0.3 # update local variable
qf.Kn1 == 0.3 # true: closure evaluated upon *get*
qd.Kn1 == -0.3 # true: closure evaluated upon *get*

# We can improve the performance of deferred expressions by 
# by passing type-stable functions:
g::Float64 = b1.g
b1.g = DefExpr(()->g) # Closure has inferrable return type
b1.BendParams # any gets from BendParams are now type stable


# Deferred expressions provide a "pull" way of controlling multiple 
# elements together: in the above example, the DefExpr stored in 
# qf.Kn1 is evaluated *at the time of getting*.

# An alternative way of controlling multiple elements together 
# is with a "push" scheme, where when setting the control parameter, 
# all dependent values are updated. Beamline.jl's Controller type 
# provides a way to "push" values LineElements, or other Controllers.
# Let's create a controller which sets the Bn1 of qf and qd:
c1 = Controller(
  (qf, :Kn1) => (ele; x) ->  x,
  (qd, :Kn1) => (ele; x) -> -x;
  vars = (; x = 0.0,)
)

# Now we can vary both simultaneously:
c1.x = 60.
qf.Kn1
qd.Kn1

# Controllers also include the element itself. This can 
# be useful if the current elements' values should be 
# used in the function:
c2 = Controller(
  (qf, :Kn1) => (ele; dKn1) ->  ele.Kn1 + dKn1,
  (qd, :Kn1) => (ele; dKn1) ->  ele.Kn1 - dKn1;
  vars = (; dKn1 = 0.0,)
)

c2.dKn1 = 20

qf.Kn1
qd.Kn1

# We can reset the values back to the most recently set state
# of a controller using set!
set!(c1)
qf.Kn1
qd.Kn1

# Controllers can also be used to control other controllers:
c3 = Controller(
  (c1, :x) => (ele; dx) -> ele.x + dx;
  vars = (; dx = 0.0,)
)

# And of course still fully polymorphic:
dx = @vars(D)[1]
c3.dx = dx
qf.Kn1
qd.Kn1

# Beamlines.jl also provides functionality to convert the Beamline to a
# compressed, fully isbits type. This may be useful in cases where the 
# Beamline is mostly static and you would like to put the entire line on 
# a GPU, for example.
qf = Quadrupole(Kn1L=0.18, L=0.5)
d1 = Drift(L=1.6)
qd = Quadrupole(Kn1L=-qf.Kn1L, L=0.5)
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
qf = Quadrupole(Kn1=0.36, L=0.5)
d = Drift(L=1)
qd = Quadrupole(Kn1=-0.36, L=0.5)

fodo = Beamline([qf, d, qd, d, qf, d, qd, d])
bl.line[1] === qf # egality with first instance

# reset parent
qf.Kn1 = 0.1

# second instance
qf2 = fodo.line[5]
qf2.Kn1 == 0.1 # true
```

# Acknowledgements

`Beamlines.jl` aims to provide the powerful lattice definitions enabled by [classic Bmad](github.com/bmad-sim/bmad-ecosystem), [`AcceleratorLattice.jl`](https://github.com/bmad-sim/AcceleratorLattice.jl), and the [Particle Accelerator Lattice Standard (PALS) project](https://github.com/campa-consortium/pals). The use of lazily-evaluated deferred expressions is inspired completely by [MAD-NG](https://github.com/MethodicalAcceleratorDesign/MAD-NG). This package would be a fragment of what it is today without all of these efforts.
