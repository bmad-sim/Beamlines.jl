scalarize(t) = t
scalarize(t::AbstractArray) = scalarize.(t)

# See element.jl for scalarize function acting on parameter groups

"""
    scalarize!(ele::LineElement)

Modifies the `LineElement` so all element-level parameters are regular number types. 
This may be needed after optimizing the element's parameters using e.g. `ForwardDiff`, 
`ReverseDiff`, or `GTPSA`, which will set the parameter equal to a special number type 
that propagates the gradients.
"""
function scalarize!(ele::LineElement)
  pdict = getfield(ele, :pdict)
  for (key, p) in pdict
    if key != BeamlineParams
      setindex!(pdict, scalarize(p), key)
    end
  end
  return ele
end

"""
    scalarize!(bl::Beamline)

Modifies the `Beamline` and its `LineElement`s so all parameters are regular number types. 
This may be needed after optimizing the element's parameters using e.g. `ForwardDiff`, 
`ReverseDiff`, or `GTPSA`, which will set the parameter equal to a special number type 
that propagates the gradients.
"""
function scalarize!(bl::Beamline)
    for ele in bl.line
        scalarize!(ele)
    end
    bl.ref = scalarize(bl.ref)
    return bl 
end

"""
    scalarize!(lat::Lattice)

Modifies all `Beamline`s and their `LineElement`s in the `Lattice` so all parameters are 
regular number types. This may be needed after optimizing the element's parameters using 
e.g. `ForwardDiff`, `ReverseDiff`, or `GTPSA`, which will set the parameter equal to a 
special number type that propagates the gradients.
"""
function scalarize!(lat::Lattice)
    for bl in lat.beamlines
        scalarize!(bl)
    end
    return lat
end