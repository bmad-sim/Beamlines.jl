function Base.in(ele::LatElement, bl::Beamline)
  bp = ele.BeamlineParams
  if !isnothing(bp) && bp.beamline == bl
    return true
  else
    return false
  end
end

"""
    findchildren(ele::LatElement, bl::Beamline)

Finds all `LatElement`s in the Beamline `bl` that inherit from `ele`, either directly
(`ele` is the parent) or through a chain of parents. For example, the elements of a `Beamline` 
in a `Branch` are children of the elements of the `Beamline` used to create the `Branch`, which
are in turn children of the elements used to create that `Beamline`.
"""
findchildren(ele::LatElement, bl::Beamline) = filter(x -> _inherits_from(x, ele), bl.line)

# True if `ele` is a parent, grandparent, etc. of `x`.
function _inherits_from(x::LatElement, ele::LatElement)
  pdict = getfield(x, :pdict)
  while haskey(pdict, InheritParams)
    parent = get_parent(pdict)
    parent === ele && return true
    pdict = getfield(parent, :pdict)
  end
  return false
end

Base.getindex(bl::Beamline, eles::AbstractVector{LatElement}) = collect(LatElement, Iterators.flatten(findchildren(ele, bl) for ele in eles))
Base.getindex(bl::Beamline, idxs::AbstractVector{<:Integer}) = LatElement[bl[i] for i in idxs]
Base.getindex(bl::Beamline, eles_or_idxs::AbstractVector) = collect(LatElement, Iterators.flatten(_resolve_index(bl, ele_or_idx) for ele_or_idx in eles_or_idxs))
function _resolve_index(bl::Beamline, ele_or_idx)
  if ele_or_idx isa LatElement
    return bl[[ele_or_idx]]
  elseif ele_or_idx isa Integer
    return LineElement[bl[ele_or_idx]]
  else
    return bl[ele_or_idx]
  end
end

function Base.getindex(bl::Beamline, ele::LatElement)
  if ele in bl
    return ele
  else
    children = findchildren(ele, bl)
    if length(children) == 1
      return children[1]
    elseif length(children) == 0
      error("LatElement $(ele.name) not found in beamline")
    else
      error("LatElement $(repr(ele.name)) is placed $(length(children)) times in the Beamline: ",
        "index with `[[ele]]` for all of them, or with one beamline index")
    end
  end
end

Base.getindex(bl::Beamline, i::Integer) = bl.line[i]
Base.getindex(bl::Beamline, f::Function) = filter(f, bl.line)
Base.length(bl::Beamline) = length(bl.line)
Base.firstindex(bl::Beamline) = 1
Base.lastindex(bl::Beamline) = length(bl)
Base.iterate(bl::Beamline, i=1) = iterate(bl.line, i)
Base.eltype(::Type{Beamline}) = LatElement

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
