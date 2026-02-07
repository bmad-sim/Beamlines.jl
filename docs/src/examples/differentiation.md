# Automatic Differentiation with GTPSA

Beamlines.jl is fully polymorphic and works seamlessly with GTPSA (Generalized Truncated Power Series Algebra) for high-order automatic differentiation.

## Setup

First, install GTPSA:

```julia
using Pkg
Pkg.add("GTPSA")
```

## Basic Differentiation

### Making Parameters Variables

Make element lengths or strengths TPSA variables:

```julia
using Beamlines, GTPSA

# Create TPSA descriptor (2 variables, 1st order)
const D = Descriptor(2, 1)

# Get TPSA variables
vars = @vars(D)
ΔL = vars[1]
ΔKn1 = vars[2]

# Create elements
qf = Quadrupole(Kn1=0.36, L=0.5)
d = Drift(L=1.0)
qd = Quadrupole(Kn1=-0.36, L=0.5)

# Make drift length a TPSA variable
d.L = 1.0 + ΔL

# Create beamline
bl = Beamline([qf, d, qd], p_over_q_ref=60.0)
```

### Differentiation Propagates

All dependent quantities automatically become TPSA:

```julia
# Position is now TPSA
println(qd.s)              # TPSA: 1.5 + 1.0*ΔL
println(qd.s_downstream)   # TPSA: 2.0 + 1.0*ΔL

# Extract derivatives
println(qd.s[1])           # ∂(qd.s)/∂ΔL = 1.0
```

## Differentiating Field Strengths

### Quadrupole Strengths

```julia
using Beamlines, GTPSA

const D = Descriptor(1, 1)
dKn1 = @vars(D)[1]

qf = Quadrupole(Kn1=0.36, L=0.5)
qd = Quadrupole(Kn1=-0.36, L=0.5)

# Make QF strength a variable
qf.Kn1 = 0.36 + dKn1

# QF is now TPSA
println(qf.Kn1)  # TPSA: 0.36 + 1.0*dKn1

# Unnormalized strength is also TPSA
bl = Beamline([qf, qd], p_over_q_ref=60.0)
println(qf.Bn1)  # TPSA in Bn1
```

### Using DefExpr with GTPSA

Combine deferred expressions with differentiation:

```julia
using Beamlines, GTPSA

const D = Descriptor(1, 1)
dKn1 = @vars(D)[1]

# Control variable
Kn1 = 0.36

qf = Quadrupole(Kn1=DefExpr(() -> Kn1), L=0.5)
qd = Quadrupole(Kn1=DefExpr(() -> -Kn1), L=0.5)

# Update with TPSA
Kn1 = 0.36 + dKn1

# Elements now return TPSA
println(qf.Kn1)  # TPSA: 0.36 + 1.0*dKn1
println(qd.Kn1)  # TPSA: -0.36 - 1.0*dKn1
```

## Differentiating Reference Energy

The reference energy can also be a TPSA variable:

```julia
using Beamlines, GTPSA

const D = Descriptor(2, 1)
vars = @vars(D)
ΔL = vars[1]
Δp = vars[2]

qf = Quadrupole(Kn1=0.36, L=0.5)
d = Drift(L=1.0 + ΔL)

# Create beamline with TPSA reference momentum
bl = Beamline([qf, d], p_over_q_ref=60.0 + Δp)

# Unnormalized field strength depends on both
println(qf.Bn1)  # TPSA: depends on reference momentum
```

## High-Order Differentiation

GTPSA supports arbitrary-order differentiation:

```julia
using Beamlines, GTPSA

# 5th order in 1 variable
const D = Descriptor(1, 5)
dL = @vars(D)[1]

qf = Quadrupole(Kn1=0.36, L=0.5)
d = Drift(L=1.0 + dL)
qd = Quadrupole(Kn1=-0.36, L=0.5)

bl = Beamline([qf, d, qd])

# Extract high-order derivatives
pos = qd.s
println("Position: ", pos[0])           # Value
println("1st derivative: ", pos[1])     # ∂s/∂dL
println("2nd derivative: ", pos[1,1])   # ∂²s/∂dL²
# Higher orders are zero for linear relationship
```

## Multiple Variables

Differentiate with respect to multiple parameters:

```julia
using Beamlines, GTPSA

# 3 variables, 2nd order
const D = Descriptor(3, 2)
vars = @vars(D)
dL = vars[1]
dKn1 = vars[2]
dp = vars[3]

qf = Quadrupole(Kn1=0.36 + dKn1, L=0.5)
d = Drift(L=1.0 + dL)
qd = Quadrupole(Kn1=-0.36, L=0.5)

bl = Beamline([qf, d, qd], p_over_q_ref=60.0 + dp)

# Mixed partial derivatives
bn1 = qf.Bn1
println("∂Bn1/∂Kn1: ", bn1[dKn1])
println("∂Bn1/∂p: ", bn1[dp])
println("∂²Bn1/∂Kn1∂p: ", bn1[dKn1, dp])
```

## Use Cases

### Optimization

Use GTPSA for gradient-based optimization:

```julia
using Beamlines, GTPSA

# Setup with variables
const D = Descriptor(2, 1)
vars = @vars(D)
dkf = vars[1]
dkd = vars[2]

qf = Quadrupole(Kn1=0.36 + dkf, L=0.5)
d = Drift(L=1.0)
qd = Quadrupole(Kn1=-0.36 + dkd, L=0.5)

bl = Beamline([qf, d, qd, d])

# Compute objective (e.g., from tracking)
objective = some_tracking_function(bl)

# Extract gradient
gradient = [objective[dkf], objective[dkd]]

# Use gradient in optimizer
# update parameters based on gradient...
```

### Sensitivity Analysis

Analyze parameter sensitivity:

```julia
using Beamlines, GTPSA

const D = Descriptor(4, 1)
vars = @vars(D)

# Make multiple parameters variables
qf.Kn1 = 0.36 + vars[1]
d.L = 1.0 + vars[2]
qd.Kn1 = -0.36 + vars[3]
bl.p_over_q_ref = 60.0 + vars[4]

# Compute quantity of interest
result = compute_something(bl)

# Extract sensitivities
sensitivities = [result[v] for v in vars]

# Identify most sensitive parameter
max_sens, idx = findmax(abs.(sensitivities))
println("Most sensitive to variable $idx")
```

### Taylor Map Construction

Build transfer maps using high-order GTPSA:

```julia
using Beamlines, GTPSA

# 6D phase space, 3rd order
const D = Descriptor(6, 3)
x = @vars(D)

# Initial conditions as TPSA
x0 = [xi for xi in x]

# Track through beamline (with appropriate tracking code)
# xf = track(bl, x0)

# Transfer map is encoded in TPSA coefficients
# Can extract Jacobian, nonlinear terms, etc.
```

## Controllers with GTPSA

Controllers also work with GTPSA:

```julia
using Beamlines, GTPSA

const D = Descriptor(1, 1)
dx = @vars(D)[1]

qf = Quadrupole(Kn1=0.36, L=0.5)
qd = Quadrupole(Kn1=-0.36, L=0.5)

c = Controller(
    (qf, :Kn1) => (ele; x) ->  x,
    (qd, :Kn1) => (ele; x) -> -x;
    vars = (; x = 0.36,)
)

# Set control variable as TPSA
c.x = 0.36 + dx

# Elements now have TPSA values
println(qf.Kn1)  # TPSA: 0.36 + 1.0*dx
println(qd.Kn1)  # TPSA: -0.36 - 1.0*dx
```

## Performance Tips

1. **Use appropriate order**: Higher orders are slower. Use minimum needed.
2. **Minimize variables**: Each variable adds computational cost.
3. **Type stability**: Ensure functions are type-stable with TPSA.
4. **Preallocate**: Reuse TPSA objects when possible.

## Example: Complete Optimization Setup

```julia
using Beamlines, GTPSA, Optim

function setup_optimization()
    # Create descriptor
    const D = Descriptor(2, 1)
    vars = @vars(D)

    # Nominal values
    k_nom = [0.36, -0.36]

    # Create lattice
    qf = Quadrupole(Kn1=k_nom[1], L=0.5)
    d = Drift(L=1.0)
    qd = Quadrupole(Kn1=k_nom[2], L=0.5)
    bl = Beamline([qf, d, qd, d])

    # Objective function with gradient
    function objective_and_gradient(k)
        # Update parameters with TPSA
        qf.Kn1 = k[1] + vars[1]
        qd.Kn1 = k[2] + vars[2]

        # Compute objective (example)
        obj = your_tracking_function(bl)

        # Return value and gradient
        return obj[0], [obj[vars[1]], obj[vars[2]]]
    end

    return objective_and_gradient, k_nom
end

# Run optimization
obj_grad, k0 = setup_optimization()
result = optimize(obj_grad, k0, LBFGS())
```

## Next Steps

- Learn more about [GTPSA.jl](https://github.com/bmad-sim/GTPSA.jl)
- Explore [controllers](../user-guide/controllers.md) for parameter control
- See [deferred expressions](../user-guide/deferred-expressions.md) for lazy evaluation
