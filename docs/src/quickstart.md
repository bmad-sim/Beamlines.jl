```@meta
CurrentModule = Beamlines
```

# Quickstart Guide
## Getting Started
Let's start by constructing a simple FODO cell `Beamline`, which consists of a quadrupole magnet that focuses the beam in the horizontal plane (defocuses in the vertical), followed by a drift (empty space), then a quadrupole that defocuses in the horizontal plane (focuses in the vertical), and finally another drift. 

To do this, we will define four `LineElement`s corresponding to each of these objects. The lengths of each object are specified by `L` (in meters), and the quadrupole strengths can be set using the property `Kn1`, where `n` means the "normal" multipole (`s` would be "skew") and `1` means 1st order multipole (quadrupole). 

```@example first
using Beamlines

qf = Quadrupole(Kn1=0.36, L=0.5)
d = Drift(L=1.2)
qd = Quadrupole(Kn1=-0.36, L=0.5)

fodo = Beamline([qf, d, qd, d])
```

As you can see, because we did not specify a reference particle species `species_ref`, nor a **signed** reference [magnetic rigidity](https://en.wikipedia.org/wiki/Rigidity_(electromagnetism)) `p_over_q_ref`, both of those show `Inferred`. This means that it will infer those values from either a preceeding `Beamline`, or simply leave it up to a tracking code to decide. One can also specify `E_ref` or `pc_ref` instead of `p_over_q_ref` for convenience. Let's do that now, and specify electrons with a total reference energy of 18 GeV:

```@example first
fodo = Beamline([qd, d, qd, d], species_ref=Species("electron"), E_ref=18e9)
```

`Beamlines.jl` uses the [`AtomicAndPhysicalConstants.jl](https://github.com/bmad-sim/AtomicAndPhysicalConstants.jl) package for specifying particle species, and so any species defined by that package may be provided.

The rest of the output looks ok, except for the fact that the `name` column is empty! This is because we didn't specify a `name` property for each element. It would often be convenient if we can make the variable symbols (e.g. `qf`, `d`, etc.) automatically fill in the `name` field for each element. We can do exactly this by wrapping the element definitions in a `@elements` block:

```@example defexpr1
@elements begin
    qf = Quadrupole(Kn1=0.36, L=0.5)
    d = Drift(L=1.2)
    qd = Quadrupole(Kn1=-0.36, L=0.5)
end

fodo = Beamline([qf, d, qd, d], species_ref=Species("electron"), E_ref=18e9)
```

Much better!

Python users may use the dict-based naming function `elements` instead.

```@docs
@elements
elements
```

## Deferred Expressions

Earlier we set `qf.Kn1 = 0.36`, and `qd.Kn1 = -0.36`. But what if we want to ensure that `qd.Kn1 == -qf.Kn1` always? We can bake-in such an interdependence, common in particle accelerator parameters, using a "deferred expression" - an expression where evaluation is postponed until its result is actually needed, rather than immediately when it is defined. 

To do this, let's first define a function that returns the current value of `-qf.Kn1`. We can do this without giving the function any explicit name using [lambda/anonymous functions](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions):


```@example defexpr1
lambdafun = () -> -qf.Kn1
println("Before: ", lamdbafun())
qf.Kn1 = 0.1
println("After: ", lambdafun())
```

Here `lambdafun` takes no arguments (specified by the empty tuple `()`) and returns `-qf.Kn1`. In the context of programming, `lambdafun` is specifically called a [**closure**](https://en.wikipedia.org/wiki/Closure_(computer_programming)), because it "encloses" `qf`, and at the time of evaluation gets the `Kn1` of that enclosed `qf` and negates its sign.

Now we just wrap this function in `Beamlines`'s `DefExpr` type, and we can set any `LineElement` parameter to be such a deferred expression:

```@example defexpr1
qd.Kn1 = DefExpr(lambdafun)
qd.Kn1
```

Now if we change `qf.Kn1`, evaluation of `qd.Kn1` will always be `-qf.Kn1`:

```@example defexpr1
qf.Kn1 = 0.7
qd.Kn1
```
'

Deferred expressions can also be manipulated like any other number:

```@example
a = 1
da = DefExpr(()->a)
b = 2
db = DefExpr(()->b)
dc = da + db
println(dc())
a = 4
println(dc())
dd = sin(dc)
println(dd())
```

One can really "go crazy" with deferred expressions if they want to. They can be infinitely nested, and you can write any function that the programming language allows, for example file I/O, or even control system gets/puts with a real accelerator for a digital twin.

## Parameters

`Beamlines.jl` supports a continually-growing list of parameters to define accelerator elements. To see a full list of the parameters you can set, look at the docstring for the `LineElement` type. This can be retrieved in a Julia session using `Doc.docs(LineElement)`.

```@docs
LineElement
```

For a more detailed description of each parameter, see the docstrings for individual parameter groups. These are shown in the [Parameter Groups](@ref pgs) section of the documentation.

## Multiple `LineElement`s in (multiple) `Beamline`s

Let's go back to the earlier example,

```@example multiple
@elements begin
    qf = Quadrupole(Kn1=0.36, L=0.5)
    d = Drift(L=1.2)
    qd = Quadrupole(Kn1=-0.36, L=0.5)
end

fodo = Beamline([qf, d, qd, d], species_ref=Species("electron"), E_ref=18e9);
```

Here, `fodo` contains two instances of the line element `d`. Therefore, if the length of `d` is changed, then both instances of `d` will see this new, changed length:

```@example multiple
d.L = 2.0
println(fodo.line[2].L)
println(fodo.line[4].L)
```

However, both drifts in `fodo` are unique elements. We can check this using the [`===`](https://docs.julialang.org/en/v1/base/base/#Core.:(===)) operator:

```@example multiple
println(fodo.line[2] === fodo.line[4])
println(d === fodo.line[2])
println(d === fodo.line[4])
```

Under the hood, when an element is placed in a Beamline, a **shallow copy** of that element is created that points to the "parent" element, from which it inherits its parameters. So, in this above example when the "get" `fodo.line[2].L` is executed, the code goes to the parent element `d` and returns `d.L`. "Sets", such as `fodo.line[2].L = 10`, will also pass through from the child to the parent:

```@example multiple
fodo.line[2].L = 3.0
println(d)
println(fodo.line[4].L)
println(d === fodo.line[4].L)
```

The only case where a child element can have parameters different from its parent is when a given [parameter group](@ref pgs) is contained within the child. For example, `fodo.line[2]` and `fodo.line[4]` both have their own instance of `BeamlineParams`, from which we can extract things like `beamline_index`, `s`, and `s_downstream`. On the other hand, the parent element `d` does *not* have a `BeamlineParams`.

```@example multiple
println("beamline_index:")
println(fodo.line[2].beamline_index)
println(fodo.line[4].beamline_index)

println("s_downstream:")
println(fodo.line[2].s_downstream)
println(fodo.line[4].s_downstream)

# This will error:
d.beamline_index
```

The parent element can be retrieved using `parent`:

```@example multiple
fodo.line[2].parent
```

Sometimes it can be a pain to find exactly where in a beamline are the corresponding child elements. As such, the `findchildren` function is provided for convenience:

```@example multiple
children = findchildren(d, fodo);
```

Finally, elements in a beamline allow one to "get" parameters that may only be defined when said element is in a beamline. We showed the `s` and `s_downstream`, but another example would be the unnormalized magnetic field, if the normalied magnetic field is stored as an independent variable:

```@example dep
ele = Quadrupole(Kn1=2, L=2)
bl = Beamline([ele], p_over_q_ref=3)
println(bl.line[1].Bn1) # Returns Kn1 * p_over_q_ref = 2 * 3
```

The last parameter "set" will always define what the independent variable is. So if we then set the unnormalized quadrupole strength `Bn1`, that will be the independent variable:

```@example dep
ele.Bn1 = 10
println(bl.line[1].Kn1) # Returns Bn1 / p_over_q_ref = 10 / 3
```

Now, if we then change the reference energy of the beamline, `Bn1` will remain constant but `Kn1` will change:

```@example dep
bl.p_over_q_ref = 4
println(bl.line[1].Bn1) # == 10
println(bl.line[1].Kn1) # Now equals 10 / 4
```

## Polymorphism/Differentiability

To enable full auto-differentiability of all accelerator parameters, `Beamlines.jl` is fully **polymorphic**. Full polymorphism this means that you can set any parameter to be any _type_ that you want. For auto-differentiability, a special number type that propagates the partial derivative(s) with actual value must be used in-place of the regular 64-bit floating point numbers -- polymorphism allows that. Differentiable codes in accelerator physics are *not* new: an early example of such a differentiable code is the [Polymorphic Tracking Code (PTC)](https://cds.cern.ch/record/573082/files/sl-2002-044.pdf), written in Fortran back in the 90s.

As an example, let's see how to compute the derivative of the total length of the beamline w.r.t. a particular element length. We will use the [`GTPSA.jl`](https://bmad-sim.github.io/GTPSA.jl/stable/) package to do so.

```@example gtpsa
using GTPSA
d1 = Descriptor(1, 1) # 1 variable, 1st order

@elements begin
    qf = Quadrupole(Kn1=0.36, L=0.5)
    d = Drift(L=1.2)
    qd = Quadrupole(Kn1=-0.36, L=0.5)
end

fodo = Beamline([qf, d, qd, d], species_ref=Species("electron"), E_ref=18e9);
println(fodo.line[end].s_downstream)
```

Now we just need to update `L` to be a differential-algebra variable,

```@example gtpsa
ΔL = vars(d1)[1] # get the first differential

d.L += ΔL
println(fodo.line[end].s_downstream)
```

This output shows that the total length of `fodo` is equal to ``3.4 + 2L``, which is exactly what we'd expect given that there are two drifts. 

Here we just showed the length, but **any*** accelerator parameters defined in `Beamlines.jl` can be set to any number type (fully polymorphic), so that derivatives can be computed using any automatic-differentiation package in Julia. 

After computing derivatives, e.g. during an optimization, one might want to restore all number types back to their primitive values ( `Float64`, `Float32`, etc). This can be done using the `scalarize!` function:

```@example gtpsa
scalarize!(fodo)
println(fodo.line[end].s_downstream)
```

```@docs
scalarize!
```