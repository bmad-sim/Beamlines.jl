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
Base.length(bl::Beamline) = length(bl.line)

#---------------------------------------------------------------------------------------------------

function Base.getindex(branch::Branch, ix::Integer)
  n = 0
  ix0 = ix

  for bl in branch.beamlines
    if ix > length(bl.line)
      ix = ix - length(bl.line)
      n = n + length(bl.line)
      continue
    end

    return bl.line[ix]
  end

  error("Bounds error: branch has $n elements so index $ix0 is out of range.")
end

function Base.length(branch::Branch) 
  try
    return sum([length(x.line) for x in branch.beamlines])
  catch
    return 0
  end
end