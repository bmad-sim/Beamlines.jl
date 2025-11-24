#=
We need a "parameter group" which is evaluated AND DELETED only
upon Lattice construction.

E.g., one of these guys will be dE_ref, which can only 
be evaluated upon lattice construction. However, during Beamline
construction, if this quantity is present and is NOT the last
element in the Beamline, then it should throw an error.

Perhaps we could include a flag, `delay_execution`

=#

struct Lattice <: _Lattice
  beamlines::Vector{Beamline}
end

struct PreExpansionDirective
  op::Function
  data
end

# Lattice construction should always kill any pre expansion params
# Beamline construction can leave them in
@kwdef struct PreExpansionParams <: AbstractParams
  directives::Vector{PreExpansionDirective} = PreExpansionDirective[]
end

# These are the functions called for a given symbol DURING expansion
const PREDIRECTIVES = Dict{Symbol,Function}(
  :dE_ref => pre_dE_ref
)

# These are the functions called for a given symbol AFTER expansion
const POSTDIRECTIVES = Dict{Symbol,Function}(

)

# Different behavior if lattice vs beamline expansion
function pre_dE_ref(bl::Beamline, ele::LineElement, data)
  if !(bl.line[end] === ele)
    error("Property dE_ref marks a discontinuity in a Beamline, and therefore 
           can only be set for the first element in a Beamline. Consider using 
           a Lattice constructor instead.")
  elseif any(t->haskey(getfield(t, :pdict), InheritParams) && 
                getfield(t, :pdict)[InheritParams].parent === ele, bl.line)
    
  end

  end
end

function dE_ref(lat::Lattice, ele::LineElement, data)

end




  
struct PreExpansionParams
  # 
end

struct PreBeamlineParams