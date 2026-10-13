@kwdef mutable struct ForkParams <: AbstractParams
  fork_connect_element::Union{LineElement,Nothing} = nothing
  fork_propagate_reference::Bool                   = true
end

PROPS(::Type{ForkParams}) = OrderedDict{String,String}(
  "fork_connect_element"     => "For a fork element, the connected `LineElement` in a `Branch` that is forked to. For a connected element in a `Lattice`, the fork element that connects to it. Default is `nothing`",
  "fork_propagate_reference" => "`true` if the reference species and energy are propagated from the fork element to the connected element when it is the beginning element of its `Branch`. Default is `true`",
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
`fork_propagate_reference` as the fork element. This is not done if 
the connected element is itself a fork element. See `Lattice`.

If `fork_propagate_reference` is `true` and the connected element is the beginning (first) 
element of its `Branch`, the reference species and energy of the fork element are propagated 
to that `Branch`: wherever the reference species or energy of the `Branch` is not set, it is 
that at the fork element. If the first `Beamline` of the `Branch` sets a relative energy 
(e.g. `dE_ref`), it is relative to the energy at the fork element. The values are looked up 
when they are read, so changes upstream of the fork element are seen in the `Branch`. 
Nothing is propagated if the connected element is not the beginning element of its `Branch`.

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
  return get!(()->ForkParams(fp.fork_connect_element, fp.fork_propagate_reference), stackdict, fp)::ForkParams
end

function Base.isapprox(a::ForkParams, b::ForkParams)
  return a.fork_connect_element     === b.fork_connect_element &&
         a.fork_propagate_reference ==  b.fork_propagate_reference
end

# Only show a short description of the connected element: showing the whole element would be 
# verbose and recurse infinitely since fork and connected elements point at each other.
function Base.show(io::IO, a::ForkParams)
  println(io, "ForkParams")
  ele = a.fork_connect_element
  println(io, " fork_connect_element     = ", isnothing(ele) ? "nothing" : _ele_location_repr(ele))
  println(io, " fork_propagate_reference = ", a.fork_propagate_reference)
  return
end

# `(branch, index)` of `ele` in the `Branch` it is in (as in `branch[index]`), or `nothing` if 
# `ele` is not in a `Branch`.
function _branch_and_index(ele::LineElement)
  pdict = getfield(ele, :pdict)
  haskey(pdict, BeamlineParams) || return nothing
  bp = pdict[BeamlineParams]::BeamlineParams
  bl = bp.beamline
  bl_index = getfield(bl, :branch_index)
  bl_index == -1 && return nothing
  branch = getfield(bl, :branch)
  index = sum(i -> length(branch.beamlines[i].line), 1:bl_index-1; init=0) + bp.beamline_index
  return (branch, index)
end

# Short description of an element: kind (if set), name, and location. E.g. `Quadrupole "q7" (branch "b2", index 1)`.
# The index is the index of the element in the Branch (as in `branch[index]`) if the element 
# is in a Branch, else the index in its Beamline.
function _ele_location_repr(ele::LineElement)
  kind = ele.kind
  str = kind == "" ? repr(ele.name) : "$kind $(repr(ele.name))"
  loc = _branch_and_index(ele)
  if isnothing(loc)
    pdict = getfield(ele, :pdict)
    haskey(pdict, BeamlineParams) || return str
    return str * " (beamline index $((pdict[BeamlineParams]::BeamlineParams).beamline_index))"
  end
  branch, index = loc
  branch_str = branch.name == "" ? "unnamed branch" : "branch $(repr(branch.name))"
  return str * " ($branch_str, index $index)"
end

#---------------------------------------------------------------------------------------------------
# Reference propagation through forks

# Reference property `key` upstream of `beamline`: that of the previous Beamline in the Branch, 
# or for the first Beamline, that propagated by a fork to the beginning of the Branch.
function _try_get_upstream_ref(beamline::Beamline, key::Symbol)
  branch_index = getfield(beamline, :branch_index)
  if branch_index > 1
    return trygetproperty(getfield(beamline, :branch).beamlines[branch_index-1], key)
  end
  if branch_index == 1
    ref = _try_get_fork_ref(getfield(beamline, :branch), key)
    isnothing(ref) || return ref
  end
  return GetError("Unable to get $key: $key is not set nor inferrable")
end

# The fork element whose reference propagates to the beginning element `ele` of a Branch, else 
# `nothing`. This is the case if `ele` and the fork element are connected to each other and 
# the fork element has `fork_propagate_reference` set. In a `Lattice`, the beginning element 
# of a Branch forked to points back to the fork element (see `_connect_forks!`).
function _propagating_fork(ele::LineElement)
  fp = ele.ForkParams
  (isnothing(fp) || isnothing(fp.fork_connect_element)) && return nothing
  fork = fp.fork_connect_element
  fork_fp = fork.ForkParams
  if isnothing(fork_fp) || fork_fp.fork_connect_element !== ele || !fork_fp.fork_propagate_reference
    return nothing
  end
  return fork
end

const FORK_REF_VISITING = :beamlines_fork_ref_visiting

# Reference property `key` propagated by a fork to the beginning of `branch`, `nothing` if there 
# is no such fork, or a `GetError` if the fork element's reference is not inferrable. Branches 
# being looked up are recorded per Task so that forks propagating around a cycle with no 
# reference set give a `GetError` rather than infinite recursion.
function _try_get_fork_ref(branch::Branch, key::Symbol)
  length(branch) == 0 && return nothing
  fork = _propagating_fork(branch[1])
  isnothing(fork) && return nothing
  visiting = get!(() -> Base.IdSet{Any}(), task_local_storage(), FORK_REF_VISITING)::Base.IdSet{Any}
  branch in visiting && return GetError("Unable to get $key: $key is not set nor inferrable")
  push!(visiting, branch)
  try
    fork_bl = (getfield(fork, :pdict)[BeamlineParams]::BeamlineParams).beamline
    return try_get_bl_params(fork, key, _context(fork_bl))
  finally
    delete!(visiting, branch)
  end
end
