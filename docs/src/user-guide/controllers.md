# Controllers

Controllers provide a "push" mechanism for coordinated control of multiple elements. When you update a controller's control variable, all dependent elements are updated immediately.

## Basic Usage

Create a controller that links element parameters to control variables:

```julia
using Beamlines

qf = Quadrupole(Kn1=0.36, L=0.5)
qd = Quadrupole(Kn1=-0.36, L=0.5)

c = Controller(
    (qf, :Kn1) => (ele; x) ->  x,
    (qd, :Kn1) => (ele; x) -> -x;
    vars = (; x = 0.36,)
)
```

Now update both quadrupoles simultaneously:

```julia
c.x = 0.5

qf.Kn1  # 0.5
qd.Kn1  # -0.5
```

## Controller Syntax

The general syntax is:

```julia
Controller(
    (element, :parameter) => (ele; control_var) -> expression,
    (element2, :parameter2) => (ele; control_var) -> expression2,
    ...;
    vars = (; control_var = initial_value,)
)
```

- `element`: The LineElement to control
- `:parameter`: Symbol for the parameter to set
- `ele`: Reference to the element (available in expression)
- `control_var`: Named control variable(s)
- `expression`: Function that computes parameter value from control variables

## Using Element Values

Controllers can use current element values in expressions:

```julia
qf = Quadrupole(Kn1=0.36, L=0.5)
qd = Quadrupole(Kn1=-0.36, L=0.5)

c = Controller(
    (qf, :Kn1) => (ele; dKn1) -> ele.Kn1 + dKn1,
    (qd, :Kn1) => (ele; dKn1) -> ele.Kn1 - dKn1;
    vars = (; dKn1 = 0.0,)
)

# Apply a change
c.dKn1 = 0.1

qf.Kn1  # 0.46 (0.36 + 0.1)
qd.Kn1  # -0.46 (-0.36 - 0.1)
```

## Multiple Control Variables

Use multiple control variables in a single controller:

```julia
qf = Quadrupole(Kn1=0.36, L=0.5)
qd = Quadrupole(Kn1=-0.36, L=0.5)

c = Controller(
    (qf, :Kn1) => (ele; kf, kd) -> kf,
    (qd, :Kn1) => (ele; kf, kd) -> kd;
    vars = (; kf = 0.36, kd = -0.36,)
)

# Set independently
c.kf = 0.4
c.kd = -0.35

qf.Kn1  # 0.4
qd.Kn1  # -0.35
```

## Controlling Multiple Parameters

Control different parameters of the same or different elements:

```julia
qf = Quadrupole(Kn1=0.36, L=0.5)

c = Controller(
    (qf, :Kn1) => (ele; scale) -> 0.36 * scale,
    (qf, :L) => (ele; scale) -> 0.5 * scale;
    vars = (; scale = 1.0,)
)

# Scale both strength and length
c.scale = 1.2

qf.Kn1  # 0.432 (0.36 * 1.2)
qf.L    # 0.6 (0.5 * 1.2)
```

## Controlling Other Controllers

Controllers can control other controllers:

```julia
qf = Quadrupole(Kn1=0.36, L=0.5)
qd = Quadrupole(Kn1=-0.36, L=0.5)

# First controller
c1 = Controller(
    (qf, :Kn1) => (ele; x) ->  x,
    (qd, :Kn1) => (ele; x) -> -x;
    vars = (; x = 0.36,)
)

# Second controller controls first
c2 = Controller(
    (c1, :x) => (ele; dx) -> ele.x + dx;
    vars = (; dx = 0.0,)
)

# Update via second controller
c2.dx = 0.1

c1.x    # 0.46
qf.Kn1  # 0.46
qd.Kn1  # -0.46
```

This creates a hierarchy of controls for complex systems.

## Resetting to Controller State

Use `set!` to reset elements to the controller's current state:

```julia
c = Controller(
    (qf, :Kn1) => (ele; x) -> x;
    vars = (; x = 0.36,)
)

# Manually change element
qf.Kn1 = 0.5

# Reset to controller state
set!(c)
qf.Kn1  # 0.36
```

## Polymorphic Control Variables

Controllers work with any type, including GTPSA for automatic differentiation:

```julia
using GTPSA

const D = Descriptor(1, 1)
dx = @vars(D)[1]

qf = Quadrupole(Kn1=0.36, L=0.5)
qd = Quadrupole(Kn1=-0.36, L=0.5)

c = Controller(
    (qf, :Kn1) => (ele; x) ->  x,
    (qd, :Kn1) => (ele; x) -> -x;
    vars = (; x = 0.36,)
)

# Set as TPSA
c.x = 0.36 + dx

qf.Kn1  # TPSA: 0.36 + 1.0*x
qd.Kn1  # TPSA: -0.36 - 1.0*x
```

## Use Cases

### Tune Matching

Control quadrupole families for tune adjustment:

```julia
c = Controller(
    (qf1, :Kn1) => (ele; kqf) -> kqf,
    (qf2, :Kn1) => (ele; kqf) -> kqf,
    (qd1, :Kn1) => (ele; kqd) -> kqd,
    (qd2, :Kn1) => (ele; kqd) -> kqd;
    vars = (; kqf = 0.36, kqd = -0.36,)
)
```

### Orbit Correction

Control corrector magnets:

```julia
c = Controller(
    (hcor1, :Kn0) => (ele; kick) -> kick,
    (hcor2, :Kn0) => (ele; kick) -> -kick;
    vars = (; kick = 0.0,)
)
```

### Energy Ramping

Scale magnet strengths for energy changes:

```julia
c = Controller(
    (qf, :Kn1) => (ele; E) -> 0.36 * E_ref / E,
    (qd, :Kn1) => (ele; E) -> -0.36 * E_ref / E,
    (b1, :g) => (ele; E) -> 0.5 * E_ref / E;
    vars = (; E = E_ref,)
)
```

## Controllers vs Deferred Expressions

Controllers and deferred expressions serve similar purposes but differ in approach:

**Controllers (push):**
- Update elements when control variable changes
- Explicit function calls at set time
- Good for batch updates
- Clear dependency structure

**Deferred Expressions (pull):**
- Evaluate when accessed
- Implicit evaluation on get
- No update overhead until needed
- Flexible for optimization

Choose based on your use case:
- Use controllers for coordinated updates
- Use deferred expressions for lazy evaluation

## Next Steps

- Learn about [deferred expressions](deferred-expressions.md)
- See [examples](../examples/index.md) for practical applications
- Check the {external+julia:std:doc}`API Reference <index>` for detailed documentation
