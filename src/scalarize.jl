"""
    scalarize(t)

Value of `t` with derivative parts removed: ForwardDiff `Dual`s
and ReverseDiff tracked values are unwrapped at every nesting
level, and a TPS gives its scalar part. Arrays are processed
elementwise and parameter groups fieldwise; any other value is
returned unchanged.
"""
scalarize(t) = t
scalarize(t::AbstractArray) = scalarize.(t)

"""
    scalarize_all(x)

Value of `x` with all derivative parts removed: the value of a
ForwardDiff `Dual` or ReverseDiff tracked number at every nesting
level, the scalar part of a TPS; applied elementwise to arrays (plain
`AbstractFloat`/`Integer` arrays are returned as-is); identity
otherwise. See also `scalarize` (one level).
"""
scalarize_all(x) = x
scalarize_all(t::AbstractArray) = scalarize_all.(t)
scalarize_all(t::AbstractArray{<:Union{AbstractFloat,Integer}}) = t

"""
    scalar_max(a, b)

`max`/`min` decided on scalar parts (ForwardDiff orders equal-valued
`Dual`s by their partials)
"""
@inline scalar_max(a, b) = ((a, b) = promote(a, b);
    scalarize_all(a) >= scalarize_all(b) ? a : b)

"""
    scalar_min(a, b)

`max`/`min` decided on scalar parts (ForwardDiff orders equal-valued
`Dual`s by their partials)
"""
@inline scalar_min(a, b) = ((a, b) = promote(a, b);
    scalarize_all(a) <= scalarize_all(b) ? a : b)

# See element.jl for scalarize function acting on parameter groups

"""
    scalarize!(ele::LatElement)

Modifies the `LatElement` so all element-level parameters are regular number types. 
This may be needed after optimizing the element's parameters using e.g. `ForwardDiff`, 
`ReverseDiff`, or `GTPSA`, which will set the parameter equal to a special number type 
that propagates the gradients.
"""
function scalarize!(ele::LatElement)
  pdict = getfield(ele, :pdict)
  for (key, p) in pdict
    if key == InheritParams
      scalarize!(p.parent)
    elseif key != BeamlineParams
      setindex!(pdict, scalarize(p), key)
    end
  end
  return ele
end

"""
    scalarize!(bl::Beamline)

Modifies the `Beamline` and its `LatElement`s so all parameters are regular number types. 
This may be needed after optimizing the element's parameters using e.g. `ForwardDiff`, 
`ReverseDiff`, or `GTPSA`, which will set the parameter equal to a special number type 
that propagates the gradients.
"""
function scalarize!(bl::Beamline)
    for ele in bl.line
        scalarize!(ele)
    end
    dict = getfield(bl.context, :d)
    for (k,v) in dict
        dict[k] = scalarize(v)
    end
    return bl 
end

"""
    scalarize!(branch::Branch)

Modifies all `Beamline`s and their `LatElement`s in the `Branch` so all parameters are 
regular number types. This may be needed after optimizing the element's parameters using 
e.g. `ForwardDiff`, `ReverseDiff`, or `GTPSA`, which will set the parameter equal to a 
special number type that propagates the gradients.
"""
function scalarize!(branch::Branch)
    for bl in branch.beamlines
        scalarize!(bl)
    end
    return branch
end