scalarize(t) = t
scalarize(t::AbstractArray) = scalarize.(t)

# See element.jl for scalarize function acting on parameter groups

"""
    scalarize!(ele::LineElement)

Modifies the LineElement so all element-level parameters are scalars
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

Modifies the Beamline so all LineElement parameters are scalars and all 
Beamline-level parameters are scalars.
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

Modifies the Lattice so all LineElement and Beamline parameters are scalars.
"""
function scalarize!(lat::Lattice)
    for bl in lat.beamlines
        scalarize!(bl)
    end
    return lat
end