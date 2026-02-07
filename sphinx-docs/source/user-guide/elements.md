# LineElements

## Overview

`LineElement` is the fundamental building block of beamlines. All element types (Quadrupole, Drift, etc.) are actually just `LineElement` instances with different parameters.

## The LineElement Type

All elements are created using:

```julia
LineElement(kind="ElementType"; kwargs...)
```

For convenience, constructors are provided:

```julia
Quadrupole(; kwargs...) = LineElement(; kind="Quadrupole", kwargs...)
Drift(; kwargs...) = LineElement(; kind="Drift", kwargs...)
SBend(; kwargs...) = LineElement(; kind="SBend", kwargs...)
# ... and so on
```

## Common Parameters

All elements support these parameters:

- `L`: Length (m)
- `name`: Element name (String)
- `kind`: Element type (String)
- `tracking_method`: Custom tracking method

### Misalignment Parameters

- `x_offset`: Horizontal offset (m)
- `y_offset`: Vertical offset (m)
- `tilt`: Tilt angle (rad)
- `x_rot`: Rotation about x-axis (rad)
- `y_rot`: Rotation about y-axis (rad)
- `z_rot`: Rotation about z-axis (rad)

## Element Types

### Drift

A drift space with no fields:

```julia
d = Drift(L=1.0)
```

### Quadrupole

Quadrupole magnet with normalized or unnormalized strength:

```julia
# Normalized strength
qf = Quadrupole(Kn1=0.36, L=0.5)

# Unnormalized strength (requires beamline reference momentum)
qf = Quadrupole(Bn1=50.0, L=0.5)

# Skew quadrupole
qs = Quadrupole(Ks1=0.36, L=0.5)
```

Field strengths:
- `Kn1`: Normalized strength (1/m²)
- `Bn1`: Unnormalized strength (T/m)
- `Ks1`: Skew normalized strength
- `Bs1`: Skew unnormalized strength

### Dipole Magnets

Sector bend (SBend) or rectangular bend (RBend):

```julia
# Sector bend
sb = SBend(L=6.0, angle=pi/132)

# Rectangular bend
rb = RBend(L=6.0, angle=pi/132)

# With field strength
sb = SBend(L=6.0, angle=pi/132, Kn1=0.01)
```

Parameters:
- `L`: Arc length (m)
- `angle`: Bend angle (rad)
- `g`: Field strength (T)
- `Kn1`, `Bn1`: Quadrupole components

### Sextupole

Sextupole magnet:

```julia
sf = Sextupole(Kn2=0.1, L=0.5)
sd = Sextupole(Kn2=-0.1, L=0.5)
```

Field strengths:
- `Kn2`: Normalized strength (1/m³)
- `Bn2`: Unnormalized strength (T/m²)
- `Ks2`: Skew normalized strength
- `Bs2`: Skew unnormalized strength

### Multipole

General multipole up to 21st order:

```julia
# Octupole
oct = Multipole(Kn3=2.0, L=0.3)

# High-order multipole
m21 = Multipole(Kn21=5.0, L=6.0)

# Thin multipole (integrated strength)
m_thin = Multipole(Kn1L=0.16)

# Thick with integrated strength
m_thick = Multipole(Kn1L=0.16, L=2.0)
```

For multipole order `n`:
- `Kn{n}`: Normalized strength (1/m^(n+1))
- `Bn{n}`: Unnormalized strength (T/m^(n-1))
- `Ks{n}`: Skew normalized
- `Bs{n}`: Skew unnormalized
- `Kn{n}L`: Integrated normalized
- `Bn{n}L`: Integrated unnormalized

Whichever you specify first (integrated vs non-integrated, normalized vs unnormalized) becomes the independent variable.

### Solenoid

Solenoid magnet:

```julia
sol = Solenoid(Ksol=0.12, L=5.3)
```

Parameters:
- `Ksol`: Normalized strength (1/m)
- `Bsol`: Unnormalized strength (T)

### RF Cavity

```julia
cav = RFCavity(
    voltage = 1e6,     # Voltage (V)
    frequency = 500e6, # Frequency (Hz)
    phi0 = 0.0         # Phase (rad)
)
```

## Parameter Groups

Elements organize parameters into groups for efficiency:

- `BendParams`: Dipole parameters (g, angle, etc.)
- `MultipoleParams`: All multipole strengths
- `RFParams`: RF cavity parameters
- `MisalignParams`: Misalignment parameters

Access via element properties:

```julia
qf = Quadrupole(Kn1=0.36, L=0.5)
qf.MultipoleParams.Kn1  # Access via parameter group
qf.Kn1                  # Shorthand - same as above
```

## Independent vs Dependent Variables

Many parameters have multiple representations (normalized/unnormalized, integrated/non-integrated). Whichever you set first becomes the independent variable:

```julia
# Set normalized first - it becomes independent
qf = Quadrupole(Kn1=0.36, L=0.5)
# Kn1 is independent, Bn1 is computed from it

# Set unnormalized first - it becomes independent
qf = Quadrupole(Bn1=50.0, L=0.5)
# Bn1 is independent, Kn1 is computed from it
```

The same applies to integrated strengths:

```julia
# Non-integrated is independent
m = Multipole(Kn1=0.08, L=2.0)
m.Kn1L == 0.16  # true (computed)

# Integrated is independent
m = Multipole(Kn1L=0.16, L=2.0)
m.Kn1 == 0.08   # true (computed)
```

## Tracking Methods

Set a custom tracking method for any element:

```julia
struct MyTrackingMethod end

qf.tracking_method = MyTrackingMethod()
```

## Custom Element Types

Define your own element types easily:

```julia
# Define constructor
SkewQuadrupole(; kwargs...) = LineElement(
    ; kind="SkewQuadrupole",
    tilt1=pi/4,
    kwargs...
)

# Use it
sqf = SkewQuadrupole(Kn1=0.36, L=0.2)
```

The `tilt1` parameter tilts only the Kn1 (quadrupole) component.

## Element Properties

Access element properties:

```julia
qf = Quadrupole(Kn1=0.36, L=0.5, name="QF1")

qf.name      # "QF1"
qf.kind      # "Quadrupole"
qf.L         # 0.5
qf.Kn1       # 0.36
qf.s         # Position in beamline (deferred expression)
```

Modify properties:

```julia
qf.Kn1 = 0.4
qf.L = 0.6
qf.name = "QF_NEW"
```

## Next Steps

- Learn about [deferred expressions](deferred-expressions.md)
- See how to use [controllers](controllers.md) to manage multiple elements
- Check [examples](../examples/index.md) for practical usage
