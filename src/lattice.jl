# PreExpansionDirectives are executed during Lattice construction
# These may affect the number of Beamlines and elements.

# Expansion here is defined as taking a Lattice as a Vector{LineElement},
# and converting it to Vector{Vector{LineElement}}, where each Vector is
# a separate Beamline. Upon reading the lattice in, it is first converted 
# to a single vector of a vector, e.g. [ele1, ..., elen] -> [[ele1, ..., elen]]
# Then all PreExpansionDirectives are gathered into a single priority queue
# (also contains the element number)
struct PreExpansionDirective
  op::Function
  data
end

# Directives in a given element
@kwdef struct PreExpansionParams <: AbstractParams
  # Stores symbol => data in order of insertion
  directives::OrderedDict{Symbol,Any} =  OrderedDict{Symbol,Any}() 
end

const KEY_TO_PREDIRECTIVE = Dict{Symbol,Function}(
  :R_ref => 

)

# Now we see the problem -- to do this I need to make it so that 
# setting the first element R_ref in a Beamline is acceptable

# Two ways - one is to do Pre- and post- functions, not the biggest 
# fan of that
# the other way is to make it so Beamlines also work with PreExpansionDirectives

# Alternatively, we could have a PreBeamlineParams

# Maybe this is the best way to go - instead of having this whole PreExpansionDirective 
# system, maybe just let it be on a case-by-case basis, since vastly different behavior 
# is needed and it can't really be captured well in this attempted generic system 


function apply_R_ref!(line::Vector{Vector{LineElement}}, ele_idx, R_ref)

end

# Special constructor for Lattice which takes a Vector{LineElement}
function Lattice(
  line::Vector{LineElement};
  R_ref0=nothing, # Initial reference energy, will override if first element set
  E_ref0=nothing, 
  pc_ref0=nothing,
  species_ref0=Species(),  
)
  c = count(t->!isnothing(t), (R_ref, E_ref, pc_ref)) <= 1 || error("Only one of R_ref, E_ref, and pc_ref can be specified")
  # Gather all predirectives
  directives = PriorityQueue{}
  expanded_lat = [line]

end
