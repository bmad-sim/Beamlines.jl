using Beamlines, GTPSA

# This only needs to be specified if we input normalized field strengths
qf = Quadrupole(K1=0.36, L=0.5)
sf = Sextupole(K2=0.1, L=0.5)
d1 = Drift(L=0.6)
b1 = SBend(L=6.0, angle=pi/132)
d2 = Drift(L=1.0)
qd = Quadrupole(K1=-qf.K1, L=0.5)
sd = Sextupole(K2=-sf.K2, L=0.5)
d3 = Drift(L=0.6)
b2 = SBend(L=6.0, K0=pi/132/L)
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
# As in, if you enter K1L, then vary the reference rigidity and element length, 
# K1L remains constant while K1, B1, and B1L would change

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
bl = Beamline([qf, sf, d1, b1, d2, qd, sd, d3, b2, d4]; Brho_ref=60.0)

# Now we can get the unnormalized field strengths:
qf.B1

# We can also reset quantities:
qf.B1 = 70.
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
ΔE = @vars(D)[2]
bl.Brho_ref += ΔE

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

# Beamlines.jl also provides functionality to convert the Beamline to a fully isbits type.
# This may be useful in cases where the Beamline is mostly static and you would like to 
# put the entire line on a GPU, for example.
qf = Quadrupole(K1=0.36, L=0.5)
d1 = Drift(L=1.6)
qd = Quadrupole(K1=-qf.K1, L=0.5)
d2 = Drift(L=1.6)

bl = Beamline([qf, d1, qd, d2])
bit_LE_type = Beamlines.bitseltype(bl)
bitbl = Beamlines.tobits(bl, bit_LE_type) # Vector of BitsLineElement

isbitstype(eltype(bitbl)) == true # true