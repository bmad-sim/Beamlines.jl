"""
    @enumx ForkOrientation::Int8 TANGENT=1 ANTI_TANGENT=-1

Orientation of the connected branch relative to the direction of travel of particles that 
go through the fork. With `TANGENT`, particles travel in the downstream (`+s`) direction in 
the connected branch. With `ANTI_TANGENT`, particles travel in the upstream (`-s`) direction.
"""
@enumx ForkOrientation::Int8 TANGENT=1 ANTI_TANGENT=-1

@kwdef mutable struct ForkParams <: AbstractParams
  fork_connect_element::Union{LineElement,Nothing} = nothing
  fork_orientation::ForkOrientation.T              = ForkOrientation.TANGENT
  fork_propagate_reference::Bool                   = true
end

PROPS(::Type{ForkParams}) = OrderedDict{String,String}(
  "fork_connect_element"     => "For a fork element, the connected `LineElement` in a `Branch` that is forked to. For a connected element in a `Lattice`, the fork element that connects to it. Default is `nothing`",
  "fork_orientation"         => "Orientation of the connected branch, see `ForkOrientation`. Default is `ForkOrientation.TANGENT`",
  "fork_propagate_reference" => "`true` if the reference species and energy are propagated from the fork element to the connected element. Default is `true`",
)

"""
    ForkParams

Describes a fork from the element containing the `ForkParams` (the "fork" element) to a 
"connected" element (`fork_connect_element`) in a `Branch`. The branch containing the fork 
element is the "source" branch and the branch containing the connected element is the 
"destination" branch. These may be the same branch. The fork element and the connected element 
must both have zero length.

A `Fork` element (kind `"Fork"`) marks where particles can leave a branch and travel to 
another branch. At least one element of a connected pair must be a `Fork` element: two 
non-`Fork` elements cannot be connected to each other.

When a `Lattice` is constructed, the connected element in the `Lattice` is given a 
`ForkParams` whose `fork_connect_element` is the fork element, with the same 
`fork_orientation` and `fork_propagate_reference` as the fork element. This is not done if 
the connected element is itself a fork element. See `Lattice`.

Forks are uni-directional: particles can travel from the fork element to the connected 
element, but not in reverse. A bi-directional link requires two fork elements, each having 
the other as its connected element.

`fork_connect_element` is stored by reference: copying a `ForkParams` (including via 
`deepcopy`) does not copy the connected element.

## Properties
$(PROPSDOC(ForkParams))
"""
ForkParams

# The connected element is a reference, not owned by the element, so it is never copied.
function Base.deepcopy_internal(fp::ForkParams, stackdict::IdDict)
  return get!(()->ForkParams(fp.fork_connect_element, fp.fork_orientation, fp.fork_propagate_reference), stackdict, fp)::ForkParams
end

function Base.isapprox(a::ForkParams, b::ForkParams)
  return a.fork_connect_element     === b.fork_connect_element &&
         a.fork_orientation         ==  b.fork_orientation     &&
         a.fork_propagate_reference ==  b.fork_propagate_reference
end

# Only show a short description of the connected element: showing the whole element would be 
# verbose and recurse infinitely since fork and connected elements point at each other.
function Base.show(io::IO, a::ForkParams)
  println(io, "ForkParams")
  ele = a.fork_connect_element
  println(io, " fork_connect_element     = ", isnothing(ele) ? "nothing" : _ele_location_repr(ele))
  println(io, " fork_orientation         = ", param_repr(a.fork_orientation))
  println(io, " fork_propagate_reference = ", a.fork_propagate_reference)
  return
end

# Short description of an element: kind (if set), name, and location. E.g. `Quadrupole "q7" (branch "b2", index 1)`.
# The index is the index of the element in the Branch (as in `branch[index]`) if the element 
# is in a Branch, else the index in its Beamline.
function _ele_location_repr(ele::LineElement)
  kind = ele.kind
  str = kind == "" ? repr(ele.name) : "$kind $(repr(ele.name))"
  pdict = getfield(ele, :pdict)
  haskey(pdict, BeamlineParams) || return str
  bp = pdict[BeamlineParams]::BeamlineParams
  bl = bp.beamline
  bl_index = getfield(bl, :branch_index)
  if bl_index == -1
    return str * " (beamline index $(bp.beamline_index))"
  end
  branch = getfield(bl, :branch)
  index = sum(i -> length(branch.beamlines[i].line), 1:bl_index-1; init=0) + bp.beamline_index
  branch_str = branch.name == "" ? "unnamed branch" : "branch $(repr(branch.name))"
  return str * " ($branch_str, index $index)"
end
