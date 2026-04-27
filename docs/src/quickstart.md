```@meta
CurrentModule = Beamlines
```

# Quickstart Guide

Let's start by constructing a simple FODO cell `Beamline`, which consists of a quadrupole magnet that focuses the beam in the horizontal plane (defocuses in the vertical), followed by a drift (empty space), then a quadrupole that defocuses in the horizontal plane (focuses in the vertical), and finally another drift. 

To do this, we will define four `LineElement`s corresponding to each of these objects. The lengths of each object are specified by `L` (in meters), and the quadrupole strengths can be set using the property `Kn1`, where `n` means the "normal" multipole (`s` would be "skew") and `1` means 1st order multipole (quadrupole). 

```@example
using Beamlines

qf = Quadrupole(Kn1=0.36, L=0.5)
d = Drift(L=1.2)
qd = Quadrupole(Kn1=-0.36, L=0.5)

fodo = Beamline([qf, d, qd, d])
```

As you can see, because we did not specify a reference particle species `species_ref`, nor a **signed** reference [magnetic rigidity](https://en.wikipedia.org/wiki/Rigidity_(electromagnetism)) `p_over_q_ref`, both of those show `Inferred`. This means that it will infer those values from either a preceeding `Beamline`, or simply leave it up to a tracking code to decide. One can also specify `E_ref` or `pc_ref` instead of `p_over_q_ref` for convenience.

The rest looks ok, except for the fact that the `name` column is empty! This is because we didn't specify a `name` property for each element. It would often be convenient if we can make the variable symbols (e.g. `qf`, `d`, etc.) automatically fill in the `name` field for each element. We can do exactly this by wrapping the element definitions in a `@elements` block:

```@example defexpr1
@elements begin
    qf = Quadrupole(Kn1=0.36, L=0.5)
    d = Drift(L=1.2)
    qd = Quadrupole(Kn1=-0.36, L=0.5)
end

fodo = Beamline([qf, d, qd, d])
```

Much better!

Earlier we set `qf.Kn1 = 0.36`, and `qd.Kn1 = -0.36`. But what if we want to ensure that `qf.Kn1 == -qd.Kn1` always? We can bake-in such an interdependence, common in particle accelerator parameters, using a "deferred expression" - an expression where evaluation is postponed until its result is actually needed, rather than immediately when it is defined. 

To do this, let's first define a function that returns the current value of `-qf.Kn1`. We can do this without giving the function any explicit name using [lambda/anonymous functions](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions): 


```@example defexpr1
lambdafun = () -> -qf.Kn1
println("Before: ", lamdbafun())
qf.Kn1 = 0.1
println("After: ", lambdafun())
```

Here `lambdafun` takes no arguments (specified by the empty tuple `()`) and returns `-qf.Kn1`. In the context of programming, `lambdafun` is specifically called a [**closure**](https://en.wikipedia.org/wiki/Closure_(computer_programming)), because it "encloses" the variable `qf.Kn1`. 

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



Here we set `qd.Kn1` equal to `DefExpr(() -> -qf.Kn1)`. The syntax `() -> ...` is a [lambda/anonymous function](https://docs.julialang.org/en/v1/manual/functions/#man-anonymous-functions) that takes in no arguments and returns a numerical result. Specifically, when you evaluate the anonymous function `() -> -qf.Kn1`, you will get the **current** value of `-qf.Kn1` at the time of evaluation. E.g.:



As you can see, closures provide a powerful tool that lazily "get" the state 



