# Beamline Basics

## What is a Beamline?

A `Beamline` is a collection of `LineElement`s with associated reference energy and particle species. It provides:

- Reference momentum-to-charge ratio (`p_over_q_ref`)
- Reference energy (`E_ref`) or momentum (`pc_ref`)
- Reference particle species (`species_ref`)
- Ordered collection of elements (`line`)

## Creating a Beamline

### Basic Construction

Create a beamline from a vector of elements:

```julia
using Beamlines

qf = Quadrupole(Kn1=0.36, L=0.5)
d = Drift(L=1.0)
qd = Quadrupole(Kn1=-0.36, L=0.5)

bl = Beamline([qf, d, qd, d], p_over_q_ref=60.0)
```

### Specifying Reference Energy

You can specify the reference energy in multiple ways:

```julia
# Using momentum-to-charge ratio
bl = Beamline(elements, p_over_q_ref=60.0)

# Using total energy
bl = Beamline(elements, E_ref=10e9)  # 10 GeV

# Using momentum
bl = Beamline(elements, pc_ref=5e9)  # 5 GeV/c
```

The last specification becomes the independent variable.

### Specifying Particle Species

Set the reference particle species:

```julia
bl = Beamline(
    elements,
    E_ref = 10e9,
    species_ref = Species("proton")
)

# Or electron
bl = Beamline(
    elements,
    E_ref = 3e9,
    species_ref = Species("electron")
)
```

## Element Access

Access elements in the beamline:

```julia
# First element
bl.line[1]

# All elements
bl.line

# Number of elements
length(bl.line)
```

## Finding Elements

Use `findall` to locate specific elements:

```julia
# Find all quadrupoles
quads = findall(t -> t.kind == "Quadrupole", bl.line)

# Find focusing quadrupoles
f_quads = findall(t -> t.kind == "Quadrupole" && t.Kn1 > 0., bl.line)

# Find elements by name (if set)
named = findall(t -> t.name == "QF1", bl.line)
```

## Duplicate Elements

Beamlines.jl allows duplicate elements. The first instance is the "parent", and all duplicates pull parameters from it:

```julia
qf = Quadrupole(Kn1=0.36, L=0.5)
d = Drift(L=1.0)
qd = Quadrupole(Kn1=-0.36, L=0.5)

# Use qf twice
fodo = Beamline([qf, d, qd, d, qf, d, qd, d])

# First and fifth elements are the same instance
fodo.line[1] === fodo.line[5]  # true

# Modify parent
qf.Kn1 = 0.4

# All instances reflect the change
fodo.line[5].Kn1 == 0.4  # true
```

## Element Positions

Elements automatically compute their positions in the beamline using deferred expressions:

```julia
qf = Quadrupole(Kn1=0.36, L=0.5)
d = Drift(L=1.0)
qd = Quadrupole(Kn1=-0.36, L=0.5)

bl = Beamline([qf, d, qd, d])

# Position at element start
qf.s            # 0.0
d.s             # 0.5
qd.s            # 1.5

# Position at element end
qf.s_downstream # 0.5
d.s_downstream  # 1.5
qd.s_downstream # 2.0
```

These positions update automatically when element lengths change.

## Lattices with Multiple Beamlines

A `Lattice` can contain multiple beamlines with different energies:

```julia
# Create two beamlines
bl1 = Beamline(elements1, E_ref=10e9, species_ref=Species("proton"))
bl2 = Beamline(elements2, dE_ref=-3e9, species_ref=Species("proton"))

# Combine into lattice
lat = Lattice([bl1, bl2])

# bl1.E_ref = 10 GeV
# bl2.E_ref = 7 GeV (10 - 3)
```

The `dE_ref` parameter specifies energy change relative to the previous beamline.

## Alternative Construction from Elements

You can also construct a `Lattice` directly from elements with energy changes:

```julia
ele1 = LineElement(E_ref=10e9, species_ref=Species("electron"))
ele1a = LineElement()
ele2 = LineElement(dE_ref=-3e9, species_ref=Species("electron"))
ele2a = LineElement()

# Automatically splits into beamlines at energy changes
lat = Lattice([ele1, ele1a, ele2, ele2a])

# lat.beamlines[1] contains [ele1, ele1a]
# lat.beamlines[2] contains [ele2, ele2a]
```

## Setting Energy in Elements

You can specify reference energy in the first element:

```julia
ele1 = LineElement(E_ref=10e9, species_ref=Species("proton"))
ele2 = LineElement()

bl = Beamline([ele1, ele2])

# Beamline inherits reference energy from first element
bl.E_ref == 10e9  # true
bl.species_ref == Species("proton")  # true
```

## Next Steps

- Learn about [LineElements](elements.md)
- Explore [deferred expressions](deferred-expressions.md)
- See how to use [controllers](controllers.md)
