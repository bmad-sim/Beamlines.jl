# Deferred Expressions

Deferred expressions are a core feature of Beamlines.jl, enabling lazy evaluation without a bookkeeper. This design minimizes overhead and ensures consistency.

## What are Deferred Expressions?

A deferred expression is a value that is computed **when accessed**, not when created. In Beamlines.jl:

- Element positions (`s`, `s_downstream`) are deferred
- Normalized/unnormalized field conversions are deferred
- Energy-dependent quantities are deferred
- Custom user-defined relationships can be deferred

## Built-in Deferred Expressions

### Element Positions

Element positions in a beamline are automatically deferred:

```julia
using Beamlines

qf = Quadrupole(Kn1=0.36, L=0.5)
d = Drift(L=1.0)
qd = Quadrupole(Kn1=-0.36, L=0.5)

bl = Beamline([qf, d, qd, d])

# Positions are computed on access
qf.s              # 0.0
d.s               # 0.5
qd.s              # 1.5
qd.s_downstream   # 2.0
```

If you change an element length, positions update automatically:

```julia
d.L = 2.0

# Positions update on next access
qd.s              # 2.5 (was 1.5)
qd.s_downstream   # 3.0 (was 2.0)
```

No bookkeeper is needed - the deferred expression recomputes when accessed.

### Field Strength Conversions

Normalized and unnormalized field strengths are deferred:

```julia
qf = Quadrupole(Kn1=0.36, L=0.5)
bl = Beamline([qf], p_over_q_ref=60.0)

# Bn1 is computed from Kn1 and reference momentum
qf.Bn1  # Computed on access

# Change reference momentum
bl.p_over_q_ref = 80.0

# Bn1 updates automatically
qf.Bn1  # New value
```

The relationship is lazy - `Bn1` is only computed when you access it.

## Custom Deferred Expressions

Create your own deferred expressions using `DefExpr`:

```julia
# Control variable
Kn1 = 0.36

# Create deferred expression
qf = Quadrupole(Kn1=DefExpr(() -> Kn1), L=0.5)

# Access evaluates the expression
qf.Kn1  # 0.36

# Update control variable
Kn1 = 0.4

# Next access uses new value
qf.Kn1  # 0.4
```

The `DefExpr` uses a closure to capture the variable.

## Linking Elements with DefExpr

Control multiple elements from a single variable:

```julia
Kn1 = 0.36

qf = Quadrupole(Kn1=DefExpr(() -> Kn1), L=0.5)
qd = Quadrupole(Kn1=DefExpr(() -> -Kn1), L=0.5)

# Both read from same control variable
qf.Kn1  # 0.36
qd.Kn1  # -0.36

# Update control variable
Kn1 = 0.4

# Both update
qf.Kn1  # 0.4
qd.Kn1  # -0.4
```

## Element-to-Element Dependencies

Create expressions that depend on other elements:

```julia
qf = Quadrupole(Kn1=0.36, L=0.5)
qd = Quadrupole(Kn1=DefExpr(() -> -qf.Kn1), L=0.5)

# qd depends on qf
qf.Kn1  # 0.36
qd.Kn1  # -0.36

# Update qf
qf.Kn1 = 0.5

# qd follows
qd.Kn1  # -0.5
```

This creates a dependency chain without a bookkeeper.

## Type Stability

For best performance, use type-stable closures:

```julia
# Type-unstable (not recommended)
g = 0.5
b.g = DefExpr(() -> g)  # Return type can't be inferred

# Type-stable (recommended)
g::Float64 = 0.5
b.g = DefExpr(() -> g)  # Return type is Float64

# Now parameter access is type-stable
b.BendParams  # All gets are type-stable
```

## Complex Expressions

DefExpr can contain arbitrary Julia code:

```julia
# Energy-dependent strength
E_ref = 10e9
qf.Kn1 = DefExpr(() -> 0.36 * 10e9 / E_ref)

# Conditional logic
threshold = 0.5
qf.Kn1 = DefExpr(() -> Kn1 > threshold ? Kn1 : 0.0)

# Mathematical functions
qf.Kn1 = DefExpr(() -> 0.36 * cos(angle))
```

## DefExpr with GTPSA

DefExpr works seamlessly with automatic differentiation:

```julia
using GTPSA

const D = Descriptor(1, 1)
Kn1_base = 0.36
dKn1 = @vars(D)[1]

qf = Quadrupole(Kn1=DefExpr(() -> Kn1_base + dKn1), L=0.5)

# Access gives TPSA
qf.Kn1  # TPSA: 0.36 + 1.0*dKn1
```

This enables automatic differentiation through beamline parameters.

## Evaluation Timing

Key point: **DefExpr is evaluated on get, not on set.**

```julia
Kn1 = 0.36
qf.Kn1 = DefExpr(() -> Kn1)

# Not evaluated yet...

value = qf.Kn1  # NOW it's evaluated

Kn1 = 0.4       # Update variable

value = qf.Kn1  # Evaluates with new value
```

This "pull" model contrasts with Controllers' "push" model.

## No Bookkeeping

Traditional accelerator codes use bookkeepers to track dependencies:

```
element.L = 2.0
--> bookkeeper updates element.s_downstream
--> bookkeeper updates next_element.s
--> bookkeeper updates dependent quantities
...
```

Beamlines.jl has **no bookkeeper**. Instead:

```julia
element.L = 2.0
# Nothing happens yet

next_element.s  # Computed on access from element.L
```

This has several advantages:

1. **No overhead** if you don't access dependent quantities
2. **No bugs** from bookkeeper failing to update something
3. **Simpler** code with no global state
4. **Faster** in optimization loops (only compute what you need)

## Deferred vs Eager

**Eager evaluation (traditional):**
```
Set parameter --> Update all dependencies --> Read value
```

**Deferred evaluation (Beamlines.jl):**
```
Set parameter --> (nothing happens) --> Read value --> Compute on demand
```

Deferred is faster when you set many parameters but only read a few values.

## Use Cases

### Optimization Loops

In optimization, you set many parameters but only evaluate a few objectives:

```julia
# Set many parameters (cheap)
for (i, k) in enumerate(quad_strengths)
    quads[i].Kn1 = k
end

# Only evaluate what you need (efficient)
objective = compute_tunes(lattice)  # Only touches necessary elements
```

With eager evaluation, every set would trigger cascading updates.

### Parameter Scans

Scan a parameter and observe effects:

```julia
results = []
for k in range(0.3, 0.4, 100)
    qf.Kn1 = k
    push!(results, some_computation(bl))
end
```

Only the quantities accessed in `some_computation` are evaluated.

### Differentiation

With GTPSA, deferred expressions propagate derivatives:

```julia
using GTPSA

d = Descriptor(1, 1)
dL = @vars(d)[1]

qf.L = 0.5 + dL
qd.s  # TPSA with derivative wrt dL
```

## Best Practices

1. **Use type-stable closures** for performance
2. **Don't create circular dependencies** (will cause infinite loops)
3. **Prefer DefExpr for "pull" updates**, Controllers for "push" updates
4. **Keep expressions simple** when possible
5. **Document complex expressions** for maintainability

## DefExpr vs Controllers

| Feature | DefExpr | Controllers |
|---------|---------|-------------|
| Update timing | On get (pull) | On set (push) |
| Overhead | Only when accessed | On every set |
| Use case | Lazy evaluation | Coordinated updates |
| Syntax | Closure | Structured mapping |
| Complexity | Simple expressions | Complex relationships |

## Next Steps

- Learn about [controllers](controllers.md) for push-style updates
- See [examples](../examples/index.md) for practical applications
- Check [elements](elements.md) for built-in deferred quantities
