# Contributing to Beamlines.jl

Thank you for your interest in contributing to Beamlines.jl!

## Development Rules

All properties stored in `Beamline`s and `LineElement`s must follow these rules:

### 1. No Bookkeeping

**All properties must be independent variables.** There is no bookkeeping system.

Dependent variables should be accessed via `getproperty` and `setproperty!` overrides, implementing "virtual" properties.

```julia
# Good: Independent property
struct LineElement
    L::Float64  # Independent
end

# Access dependent property via getproperty
function Base.getproperty(ele::LineElement, s::Symbol)
    if s === :s_downstream
        return ele.s + ele.L  # Computed, not stored
    else
        return getfield(ele, s)
    end
end
```

### 2. Virtual Properties Override Regular Properties

Virtual properties (computed via `getproperty`) take precedence over stored fields.

This allows you to compute values on-the-fly without storing them.

### 3. Parameter Groups Must Be Context-Independent

Any parameter group must be fully defined outside the context of an element.

**Bad example:**
```julia
# DON'T: RFParams meaning depends on element kind
struct RFParams
    field1  # Different meaning for Cavity vs RFDipole
end
```

**Good example:**
```julia
# DO: RFParams has consistent meaning everywhere
struct RFParams
    voltage::Float64   # Always means voltage
    frequency::Float64 # Always means frequency
    phi0::Float64      # Always means phase
end
```

This ensures consistency and prevents accidentally corrupting element state.

### 4. Deferred Expressions for Dependent Quantities

Use deferred expressions (lazy evaluation) for dependent quantities:

```julia
# Element position depends on previous elements
# Computed via deferred expression, not stored and updated
qd.s  # Returns deferred expression that computes position
```

### 5. Polymorphism Throughout

All code should be polymorphic to support:
- Different numeric types (Float64, Float32, etc.)
- Automatic differentiation (GTPSA)
- Uncertainty propagation
- Other generic types

```julia
# Good: Generic function
function compute_something(x::T) where T
    return x * 2
end

# Bad: Assumes Float64
function compute_something(x::Float64)
    return x * 2
end
```

## Code Organization

### Core Types

- `LineElement`: The fundamental building block
- `Beamline`: Collection of elements with reference energy
- `Lattice`: Collection of beamlines
- `DefExpr`: Deferred expression type
- `Controller`: Coordinated parameter control

### Parameter Groups

Parameters are organized into groups for efficiency:
- `BendParams`
- `MultipoleParams`
- `RFParams`
- `MisalignParams`

Each group is an independent struct with its own parameters.

### Element Constructors

Element type constructors are simple wrappers:

```julia
Quadrupole(; kwargs...) = LineElement(; kind="Quadrupole", kwargs...)
Drift(; kwargs...) = LineElement(; kind="Drift", kwargs...)
```

This keeps the type system simple while providing convenient constructors.

## Contributing Code

### Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Run tests
6. Submit a pull request

### Development Setup

```bash
git clone https://github.com/YOUR_USERNAME/Beamlines.jl.git
cd Beamlines.jl
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

### Running Tests

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

### Code Style

- Follow Julia standard style guidelines
- Use meaningful variable names
- Add docstrings for public functions
- Keep functions focused and simple
- Write type-stable code when possible

### Example: Adding a New Element Type

```julia
# 1. Define constructor (no new types needed)
Octupole(; kwargs...) = LineElement(; kind="Octupole", kwargs...)

# 2. Add parameter support if needed
# (May require extending MultipoleParams)

# 3. Add tests
@testset "Octupole" begin
    oct = Octupole(Kn3=2.0, L=0.3)
    @test oct.kind == "Octupole"
    @test oct.Kn3 == 2.0
    @test oct.L == 0.3
end

# 4. Add documentation
# (Update appropriate docs files)
```

## Testing

### Test Organization

Tests are organized by functionality:
- Element creation and parameter access
- Beamline construction
- Deferred expressions
- Controllers
- GTPSA integration

### Writing Tests

```julia
using Test
using Beamlines

@testset "My Feature" begin
    # Setup
    qf = Quadrupole(Kn1=0.36, L=0.5)

    # Test
    @test qf.Kn1 == 0.36
    @test qf.L == 0.5

    # Test modifications
    qf.Kn1 = 0.4
    @test qf.Kn1 == 0.4
end
```

### Test Coverage

Aim for high test coverage of:
- Public API functions
- Edge cases
- Error conditions
- Type stability

## Documentation

### Docstrings

Add docstrings for public functions:

```julia
"""
    Quadrupole(; Kn1=0.0, L=0.0, kwargs...)

Create a quadrupole magnet element.

# Arguments
- `Kn1`: Normalized quadrupole strength (1/m²)
- `L`: Length (m)
- `kwargs...`: Additional LineElement parameters

# Returns
- `LineElement` with kind="Quadrupole"

# Examples
```jldoctest
julia> qf = Quadrupole(Kn1=0.36, L=0.5)
LineElement(kind="Quadrupole", ...)
```
"""
Quadrupole(; kwargs...) = LineElement(; kind="Quadrupole", kwargs...)
```

### Updating Documentation

When adding features:
1. Update API reference (automatic via Documenter.jl)
2. Add examples if appropriate
3. Update user guide if needed
4. Add entry to changelog

## Design Principles

### No Hidden State

Avoid global state and hidden dependencies. All relationships should be explicit.

### Lazy Evaluation

Compute values only when needed. Use deferred expressions for dependent quantities.

### Minimal Overhead

Especially important in optimization loops. Don't compute or store unnecessary values.

### Type Stability

Write type-stable code for performance. Use type annotations where helpful.

### Simplicity

Keep the design simple. Don't add features "just in case" - add them when needed.

## Getting Help

- **Issues**: Report bugs or request features on [GitHub Issues](https://github.com/bmad-sim/Beamlines.jl/issues)
- **Discussions**: Ask questions on [GitHub Discussions](https://github.com/bmad-sim/Beamlines.jl/discussions)
- **Pull Requests**: Submit code via [GitHub Pull Requests](https://github.com/bmad-sim/Beamlines.jl/pulls)

## Acknowledgements

Review the main [Acknowledgements](../index.md#acknowledgements) section for the projects that inspired Beamlines.jl.

## License

Beamlines.jl is released under the MIT License. By contributing, you agree to license your contributions under the same license.
