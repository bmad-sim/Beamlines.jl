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
  ix0 = ix

  if ix >= 1
    for bl in branch.beamlines
      n = length(bl.line)
      ix <= n && return bl.line[ix]
      ix -= n
    end
  end

  throw(BoundsError(branch, ix0))
end

Base.length(branch::Branch) = sum(length, branch.beamlines; init=0)

#---------------------------------------------------------------------------------------------------

Base.getindex(lat::Lattice, i::Integer) = lat.branches[i]
Base.getindex(lat::Lattice, f::Function) = filter(f, lat.branches)
Base.length(lat::Lattice) = length(lat.branches)
