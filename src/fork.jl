"""
    @enumx ForkDirection::Int8 FORWARDS=1 BACKWARDS=-1

Longitudinal direction of travel of a particle that is injected into the forked-to branch.
`FORWARDS` is the downstream (`+s`) direction and `BACKWARDS` is the upstream (`-s`) direction.
"""
@enumx ForkDirection::Int8 FORWARDS=1 BACKWARDS=-1

@kwdef mutable struct ForkParams <: AbstractParams
  fork_to_element::Union{LineElement,Nothing} = nothing
  fork_direction::ForkDirection.T             = ForkDirection.FORWARDS
  fork_propagate_reference::Bool              = true
end

PROPS(::Type{ForkParams}) = OrderedDict{String,String}(
  "fork_to_element"          => "Destination `LineElement` in a `Branch` that is forked to. Default is `nothing`",
  "fork_direction"           => "Direction of travel of particles in the destination branch, see `ForkDirection`. Default is `ForkDirection.FORWARDS`",
  "fork_propagate_reference" => "`true` if the reference species and energy are propagated from the fork element to the destination element. Default is `true`",
)

"""
    ForkParams

Describes a fork from the element containing the `ForkParams` to a destination element 
(`fork_to_element`) in a `Branch`. The branch containing the fork element is the "source" 
branch and the branch containing the destination element is the "destination" branch. 
These may be the same branch.

Forks are uni-directional: particles can travel from the fork element to the destination 
element, but not in reverse. A bi-directional link requires two fork elements, each having 
the other as its destination.

`fork_to_element` is stored by reference: copying a `ForkParams` (including via 
`deepcopy`) does not copy the destination element.

## Properties
$(PROPSDOC(ForkParams))
"""
ForkParams

# The destination element is a reference, not owned by the fork element, so it is never copied.
function Base.deepcopy_internal(fp::ForkParams, stackdict::IdDict)
  return get!(()->ForkParams(fp.fork_to_element, fp.fork_direction, fp.fork_propagate_reference), stackdict, fp)::ForkParams
end

function Base.isapprox(a::ForkParams, b::ForkParams)
  return a.fork_to_element          === b.fork_to_element &&
         a.fork_direction           ==  b.fork_direction  &&
         a.fork_propagate_reference ==  b.fork_propagate_reference
end

# Only show the name of the destination element: showing the whole element would be verbose 
# and recurse infinitely for forks pointing at each other.
function Base.show(io::IO, a::ForkParams)
  println(io, "ForkParams")
  dest = a.fork_to_element
  println(io, " fork_to_element          = ", isnothing(dest) ? "nothing" : "LineElement(name = $(repr(dest.name)))")
  println(io, " fork_direction           = ", param_repr(a.fork_direction))
  println(io, " fork_propagate_reference = ", a.fork_propagate_reference)
  return
end
