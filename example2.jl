using Revise, Beamlines, GTPSA, BenchmarkTools

# This only needs to be specified if we input normalized field strengths

function make_fodo(K1=0.40, L_quad=0.5, L_drift=5.0)
  qf = Quadrupole(K1=K1, L=L_quad, tracking_method=Linear())
  d1 = Drift(L=L_drift, tracking_method=Linear())
  qd = Quadrupole(K1=-qf.K1, L=L_quad, tracking_method=Linear())
  d2 = Drift(L=L_drift, tracking_method=Linear())
  return [qf, d1, qd, d2]
end

K1 = 0.40
L_quad = 0.5
L_drift = 5.0
N_fodo = 1000

bl = Beamline([ele for i in 1:N_fodo for ele in make_fodo(K1,L_quad,L_drift)]; rigidity=60.0)

bunch = Bunch(1000)
track!(bunch, bl)

const D = Descriptor([1,1,1,1,10], 10+4) 
Δx = @vars(D)[1:4]
ΔK1 = @vars(D)[5]
bunch = Bunch(x=Δx[1], px=Δx[2], y=Δx[3], py=Δx[4])

# Get all focusing/defocusing quadrupoles
qf_idxs = findall(t->t.class=="Quadrupole" && t.K1 > 0, bl.line)
qd_idxs = findall(t->t.class=="Quadrupole" && t.K1 < 0, bl.line)
qfs = bl.line[qf_idxs]
qds = bl.line[qd_idxs]

# Now make controller to set all of these
cq = Controller(
  map(t->(t, :K1) => (ele; x) -> x, qfs)...,
  map(t->(t, :K1) => (ele; x) -> -x, qds)...,
  vars = (; x = 0.0)
)

# Now make TPSA
cq.x = K1 + ΔK1

# Now let's track parametric GTPSA
track!(bunch, bl)

# Get the phase advance
p = Particle(bunch)
mu = acos(1/2*(deriv(p.v.x[1,:],1) + deriv(p.v.px[2,:],2)))/(2*pi)

# Note we can evaluate mu as a function:
mu([0,0,0,0,0.13])

# It turns out that mu([0,0,0,0,0.13064]) ≈ 0.25
# Set the quadrupoles:
cq.x = K1 + 0.13064

# Start over bunch:
bunch = Bunch(x=Δx[1], px=Δx[2], y=Δx[3], py=Δx[4])
track!(bunch, bl)

p = Particle(bunch)
M = GTPSA.jacobian(p.v)
mu = acos(1/2*(M[1,1]+M[2,2]))/(2*pi) # About 0.25!