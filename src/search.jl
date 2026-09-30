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

Finds all `LineElement`s in the Beamline `bl` that inherit from `ele`, either directly
(`ele` is the parent) or through a chain of parents. For example, the elements of a `Beamline` 
in a `Branch` are children of the elements of the `Beamline` used to create the `Branch`, which
are in turn children of the elements used to create that `Beamline`.
"""
findchildren(ele::LineElement, bl::Beamline) = filter(x -> _inherits_from(x, ele), bl.line)

# True if `ele` is a parent, grandparent, etc. of `x`.
function _inherits_from(x::LineElement, ele::LineElement)
  pdict = getfield(x, :pdict)
  while haskey(pdict, InheritParams)
    parent = get_parent(pdict)
    parent === ele && return true
    pdict = getfield(parent, :pdict)
  end
  return false
end

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
Base.firstindex(bl::Beamline) = 1
Base.lastindex(bl::Beamline) = length(bl)

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
Base.firstindex(branch::Branch) = 1
Base.lastindex(branch::Branch) = length(branch)

#---------------------------------------------------------------------------------------------------

Base.getindex(lat::Lattice, i::Integer) = lat.branches[i]
Base.getindex(lat::Lattice, f::Function) = filter(f, lat.branches)
Base.length(lat::Lattice) = length(lat.branches)
Base.firstindex(lat::Lattice) = 1
Base.lastindex(lat::Lattice) = length(lat)
