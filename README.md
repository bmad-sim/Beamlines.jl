# Beamlines
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://bmad-sim.github.io/Beamlines.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://bmad-sim.github.io/Beamlines.jl/dev/)
[![Build Status](https://github.com/mattsignorelli/Beamlines.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/mattsignorelli/Beamlines.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![codecov](https://codecov.io/github/bmad-sim/Beamlines.jl/graph/badge.svg?token=4776DOLQ8B)](https://codecov.io/github/bmad-sim/Beamlines.jl)

This package defines the `Beamline` and `LineElement` types, which can be used to define particle accelerator beamlines. The `LineElement` is fully extensible and polymorphic, and has been highly optimized for fast getting/setting of the beamline element parameters. High-order automatic differentiation of parameters, e.g. magnet strengths or lengths, is also easy using `Beamlines.jl`. All dependent variables computed from `LineElement`s are computed from the internally stored independent variables as lazily as deferred expressions; there is no eager "bookkeeper". This both fully minimizes overhead from storing and computing quantities you don't need (especially impactful in optimization loops), and ensures that you don't need to rely on a complicated bookkeeper to properly update all dependent variables, minimizing bugs and easing long term maintainence. Furthermore, the generic `DefExpr` type is provided as a general usage lazily-evaluated deferred expression for controlling potentially many parameters with only a single update.


## Installation
To use `Beamlines.jl`, simply run:

```julia
import Pkg; Pkg.add("Beamlines")
```

## Basic Example

```julia
using Beamlines

@elements begin
  qf = Quadrupole(Kn1=0.36, L=0.5)
  d = Drift(L=1.2)
  qd = Quadrupole(Kn1=-0.36, L=0.5)
end

fodo = Beamline([qf, d, qd, d], species_ref=Species("electron"), E_ref=18e9)
```

See the [documentation](https://bmad-sim.github.io/Beamlines.jl) for more.

# Acknowledgements

`Beamlines.jl` aims to provide the powerful lattice definitions enabled by [classic Bmad](https://github.com/bmad-sim/bmad-ecosystem), [`AcceleratorLattice.jl`](https://github.com/bmad-sim/AcceleratorLattice.jl), and the [Particle Accelerator Lattice Standard (PALS) project](https://github.com/campa-consortium/pals). The use of lazily-evaluated deferred expressions is inspired completely by [MAD-NG](https://github.com/MethodicalAcceleratorDesign/MAD-NG). This package would be a fragment of what it is today without all of these efforts.
