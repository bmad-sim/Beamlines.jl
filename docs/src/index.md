# Beamlines.jl Documentation

Welcome to the documentation for **Beamlines.jl**, a Julia package for defining particle accelerator beamlines with powerful features for optimization, automatic differentiation, and lazy evaluation.

## What is Beamlines.jl?

Beamlines.jl provides the `Beamline` and `LineElement` types for defining particle (and potentially x-ray) beamlines. Key features include:

- **Fully extensible and polymorphic** element types optimized for fast parameter access
- **High-order automatic differentiation** of parameters (magnet strengths, lengths, etc.)
- **Lazy evaluation** with deferred expressions - no eager bookkeeper needed
- **Minimal overhead** by computing only what you need (especially important in optimization loops)
- **Generic `DefExpr` type** for controlling multiple parameters with a single update

## Quick Example

```julia
using Beamlines, GTPSA

# Define elements
qf = Quadrupole(Kn1=0.36, L=0.5)
d = Drift(L=1.0)
qd = Quadrupole(Kn1=-0.36, L=0.5)

# Create a beamline
fodo = Beamline([qf, d, qd, d], p_over_q_ref=60.0)

# Access and modify parameters
qf.Kn1  # Normalized field strength
qd.s    # Position in beamline (deferred expression)
```

## Documentation Sections

```{toctree}
:maxdepth: 2
:caption: Contents

getting-started
user-guide/index
examples/index
developer-guide/index
```

## API Reference

For detailed API documentation, see the {external+julia:std:doc}`API Reference <index>`.

## Key Features

### No Bookkeeping Required

All non-fundamental quantities are computed lazily as deferred expressions. This eliminates overhead and ensures you don't need to rely on a bookkeeper to update dependent variables.

### Full Polymorphism

Everything is fully polymorphic for differentiability. Use GTPSA for automatic differentiation:

```julia
# Make parameters TPSA variables
const D = Descriptor(2,1)
ΔL = @vars(D)[1]
d.L += ΔL

# Now dependent quantities are also TPSA
qd.s  # Returns TPSA
```

### Deferred Expressions

Control multiple elements together using `DefExpr`:

```julia
Kn1 = 0.36
qf.Kn1 = DefExpr(()->Kn1)
qd.Kn1 = DefExpr(()->-qf.Kn1)

# Update the control variable
Kn1 = 0.3
qf.Kn1 == 0.3  # true - evaluated on get
```

### Controllers

Use Controllers to "push" updates to multiple elements:

```julia
c = Controller(
  (qf, :Kn1) => (ele; x) ->  x,
  (qd, :Kn1) => (ele; x) -> -x;
  vars = (; x = 0.36,)
)

c.x = 0.5  # Updates both qf and qd
```

## Acknowledgements

Beamlines.jl builds on powerful lattice definitions from:
- [Classic Bmad](https://github.com/bmad-sim/bmad-ecosystem)
- [AcceleratorLattice.jl](https://github.com/bmad-sim/AcceleratorLattice.jl)
- [Particle Accelerator Lattice Standard (PALS)](https://github.com/campa-consortium/pals)

The lazy evaluation approach is inspired by [MAD-NG](https://github.com/MethodicalAcceleratorDesign/MAD-NG).

## Getting Help

- Visit the [GitHub repository](https://github.com/bmad-sim/Beamlines.jl)
- Check the {external+julia:std:doc}`API Reference <index>`
- Report issues on [GitHub Issues](https://github.com/bmad-sim/Beamlines.jl/issues)
