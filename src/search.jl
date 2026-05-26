function Base.in(ele::LineElement, bl::Beamline)
  bp = ele.BeamlineParams
  if !isnothing(bp) && bp.beamline == bl
    return true
  else
    return false
  end
end

"""
    findchildren(ele::LineElement, bl::Beamline)

Finds all `LineElement`s in the Beamline `bl` with parent `ele`.
"""
findchildren(ele::LineElement, bl::Beamline) = filter(x->x.parent === ele, bl.line)

function Base.getindex(bl::Beamline, ele::LineElement)
  if ele in bl
    return [ele]
  else
    return findchildren(ele, bl)
  end
end

Base.getindex(bl::Beamline, i::Integer) = bl.line[i]
Base.getindex(bl::Beamline, f::Function) = filter(f, bl.line)