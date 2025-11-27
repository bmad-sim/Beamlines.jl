# For simplicity at the moment, PreExpansionDirectives will only 
# be run during Lattice construction, not Beamline construction.

struct PreExpansionDirective
  pre::Function   # Function run on the RAW element 
  post::Function
  data
end

# Directives executed as a priority queue on a per-element basis
struct PreExpansionParams
  directives::PriorityQueue{PreExpansionDirective,Int}
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
  lat = Beamline[]
  for ele_or_bl in lat
    if ele_or_bl isa LineElement
      if 
      push!(expanded_lat, ele_or_bl)
    elseif ele_or_bl isa Beamline
      push!(expanded_lat, ele_or_bl.line...)
    else
      error("Lattice array may only contain LineElements and/or Beamlines")
    end
  end

  # Do the first pass of all PreExpansionDirectives on expanded_lat
  for ele in expanded_lat
    if haskey(getfield(ele, :pdict), PreExpansionParams)
  end

end
