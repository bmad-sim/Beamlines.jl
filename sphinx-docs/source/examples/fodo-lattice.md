# Building a FODO Lattice

This example demonstrates building a complete FODO (Focusing-Drift-Defocusing-Drift) lattice.

## Complete FODO Example

```julia
using Beamlines

# Define focusing quadrupole
qf = Quadrupole(Kn1=0.36, L=0.5)

# Define sextupole
sf = Sextupole(Kn2=0.1, L=0.5)

# Define drifts
d1 = Drift(L=0.6)
d2 = Drift(L=1.0)
d3 = Drift(L=0.6)
d4 = Drift(L=1.0)

# Define dipoles
b1 = SBend(L=6.0, angle=pi/132)
b2 = SBend(L=6.0, angle=pi/132)

# Define defocusing quadrupole
qd = Quadrupole(Kn1=-qf.Kn1, L=0.5)

# Define defocusing sextupole
sd = Sextupole(Kn2=-sf.Kn2, L=0.5)

# Create beamline with reference momentum
bl = Beamline([qf, sf, d1, b1, d2, qd, sd, d3, b2, d4], p_over_q_ref=60.0)
```

## Accessing Element Parameters

Once the beamline is created, you can access various parameters:

```julia
# Element lengths
println("QF length: ", qf.L)

# Normalized field strengths
println("QF Kn1: ", qf.Kn1)

# Unnormalized field strengths (uses reference momentum)
println("QF Bn1: ", qf.Bn1)

# Element positions (deferred expressions)
println("QF position: ", qf.s)
println("QF downstream position: ", qf.s_downstream)
println("QD position: ", qd.s)
```

## Finding Elements

Locate specific elements in the beamline:

```julia
# Find all Quadrupoles
quads = findall(t -> t.kind == "Quadrupole", bl.line)
println("Number of quadrupoles: ", length(quads))

# Find focusing quadrupoles
f_quads = findall(t -> t.kind == "Quadrupole" && t.Kn1 > 0., bl.line)
println("Number of focusing quads: ", length(f_quads))

# Find defocusing quadrupoles
d_quads = findall(t -> t.kind == "Quadrupole" && t.Kn1 < 0., bl.line)
println("Number of defocusing quads: ", length(d_quads))

# Find all drifts
drifts = findall(t -> t.kind == "Drift", bl.line)
println("Number of drifts: ", length(drifts))
```

## Modifying Parameters

Update element parameters dynamically:

```julia
# Reset normalized field strength
qf.Kn1 = 0.40

# This automatically affects qd since qd.Kn1 = -qf.Kn1
println("QD Kn1 after QF change: ", qd.Kn1)  # -0.40

# Reset unnormalized field strength
qf.Bn1 = 50.0

# Check the corresponding normalized value
println("QF Kn1: ", qf.Kn1)
```

## Working with Duplicate Elements

Create a repeating FODO structure with duplicate elements:

```julia
qf = Quadrupole(Kn1=0.36, L=0.5)
d = Drift(L=1.0)
qd = Quadrupole(Kn1=-0.36, L=0.5)

# Use elements multiple times
fodo = Beamline([qf, d, qd, d, qf, d, qd, d], p_over_q_ref=60.0)

# First and fifth elements are the same instance
println("Same instance? ", fodo.line[1] === fodo.line[5])  # true

# Modify the parent
qf.Kn1 = 0.40

# All instances reflect the change
println("Fifth element Kn1: ", fodo.line[5].Kn1)  # 0.40
```

## Using Named Elements

Give elements names for easier identification:

```julia
qf = Quadrupole(Kn1=0.36, L=0.5, name="QF")
d1 = Drift(L=1.0, name="D1")
qd = Quadrupole(Kn1=-0.36, L=0.5, name="QD")
d2 = Drift(L=1.0, name="D2")

bl = Beamline([qf, d1, qd, d2], p_over_q_ref=60.0)

# Find by name
qf_found = findall(t -> t.name == "QF", bl.line)
println("Found QF at index: ", qf_found[1])
```

## Adding Misalignments

Include realistic misalignments in elements:

```julia
# Perfect quadrupole
qf_perfect = Quadrupole(Kn1=0.36, L=0.5)

# Misaligned quadrupole
qf_misaligned = Quadrupole(
    Kn1 = 0.36,
    L = 0.5,
    x_offset = 0.2e-3,    # 0.2 mm horizontal offset
    y_offset = 0.1e-3,    # 0.1 mm vertical offset
    tilt = 0.5e-3,        # 0.5 mrad tilt
    y_rot = -0.3e-3       # -0.3 mrad rotation about y
)

# Access misalignment parameters
println("X offset: ", qf_misaligned.x_offset)
println("Tilt: ", qf_misaligned.tilt)
```

## Computing Lattice Properties

Calculate basic lattice properties:

```julia
# Total length
total_length = sum(e.L for e in bl.line)
println("Total lattice length: ", total_length, " m")

# Number of each element type
for kind in ["Quadrupole", "Drift", "SBend", "Sextupole"]
    count = length(findall(t -> t.kind == kind, bl.line))
    println("Number of $kind: ", count)
end

# Total bend angle
bends = findall(t -> t.kind == "SBend", bl.line)
total_angle = sum(bl.line[i].angle for i in bends)
println("Total bend angle: ", total_angle, " rad")
```

## Next Steps

- See [automatic differentiation](differentiation.md) for optimization
- Learn about [controllers](../user-guide/controllers.md) for coordinated control
- Explore [deferred expressions](../user-guide/deferred-expressions.md) for advanced usage
