# Getting Started

This guide will help you get started with Beamlines.jl.

## Installation

```julia
using Pkg
Pkg.add("Beamlines")
```

For automatic differentiation support, also install GTPSA:

```julia
Pkg.add("GTPSA")
```

## Basic Usage

### Defining Elements

Beamlines.jl provides element constructors for common accelerator components:

```julia
using Beamlines

# Create a quadrupole
qf = Quadrupole(Kn1=0.36, L=0.5)

# Create a drift
d = Drift(L=1.0)

# Create a dipole
b = SBend(L=6.0, angle=pi/132)

# Create a sextupole
sf = Sextupole(Kn2=0.1, L=0.5)

# Create a solenoid
sol = Solenoid(Ksol=0.12, L=5.3)
```

### Accessing Parameters

All element parameters can be accessed and modified:

```julia
qf.L      # Length
qf.Kn1    # Normalized field strength
qf.Bn1    # Unnormalized field strength (requires reference momentum)
```

### Creating a Beamline

Combine elements into a beamline:

```julia
# Create elements
qf = Quadrupole(Kn1=0.36, L=0.5)
d = Drift(L=1.0)
qd = Quadrupole(Kn1=-0.36, L=0.5)

# Create FODO beamline
fodo = Beamline([qf, d, qd, d], p_over_q_ref=60.0)
```

The `p_over_q_ref` parameter sets the reference momentum-to-charge ratio for the beamline.

### Modifying Parameters

Update element parameters at any time:

```julia
# Set normalized field strength
qf.Kn1 = 0.4

# Set unnormalized field strength
qf.Bn1 = 50.0
```

## A Complete Example: FODO Lattice

Here's a complete example of defining a FODO lattice:

```julia
using Beamlines

# Define elements
qf = Quadrupole(Kn1=0.36, L=0.5)
sf = Sextupole(Kn2=0.1, L=0.5)
d1 = Drift(L=0.6)
b1 = SBend(L=6.0, angle=pi/132)
d2 = Drift(L=1.0)
qd = Quadrupole(Kn1=-0.36, L=0.5)
sd = Sextupole(Kn2=-0.1, L=0.5)
d3 = Drift(L=0.6)
b2 = SBend(L=6.0, angle=pi/132)
d4 = Drift(L=1.0)

# Create beamline
bl = Beamline([qf, sf, d1, b1, d2, qd, sd, d3, b2, d4], p_over_q_ref=60.0)

# Access element positions (deferred expressions)
qf.s              # Position at start of element
qf.s_downstream   # Position at end of element
```

## Finding Elements

Use `findall` to locate specific elements:

```julia
# Find all Quadrupoles
quads = findall(t -> t.kind == "Quadrupole", bl.line)

# Find focusing quadrupoles
f_quads = findall(t -> t.kind == "Quadrupole" && t.Kn1 > 0., bl.line)

# Find all drifts
drifts = findall(t -> t.kind == "Drift", bl.line)
```

## Multipoles

Beamlines.jl supports up to 21st order multipoles:

```julia
# High-order multipole
m21 = Multipole(Kn21=5.0, L=6.0)

# Thin multipole (integrated strength)
m_thin = Multipole(Kn1L=0.16)

# Thick multipole with integrated strength
m_thick = Multipole(Kn1L=0.16, L=2.0)

# Check values
m_thick.Kn1L == 0.16      # true
m_thick.Kn1 == 0.16/2.0   # true
```

The first specification (integrated vs non-integrated) sets the independent variable.

## Misalignments

Elements can have misalignments and rotations:

```julia
# Misaligned quadrupole
bad_quad = Quadrupole(
    Kn1 = 0.36,
    L = 0.5,
    x_offset = 0.2e-3,    # Horizontal offset
    tilt = 0.5e-3,        # Tilt angle
    y_rot = -0.5e-3       # Rotation about y-axis
)
```

## Custom Element Types

Define your own element types:

```julia
# Define a skew quadrupole constructor
SkewQuadrupole(; kwargs...) = LineElement(; kind="SkewQuadrupole", kwargs..., tilt1=pi/4)

# Create an instance
sqf = SkewQuadrupole(Kn1=0.36, L=0.2)

# Alternatively, use the skew strength directly
sqf = Quadrupole(Ks1=0.36, L=0.2)
```

## Next Steps

- Learn about [beamline basics](user-guide/beamline-basics.md)
- Explore [deferred expressions](user-guide/deferred-expressions.md)
- See [examples](examples/index.md) for more advanced usage
- Check the <a href="api/index.html">API Reference</a> for detailed documentation
