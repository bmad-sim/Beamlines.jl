abstract type Branch end # Only subtype is Beamline

struct _Lattice{T<:Branch}
  beamlines::Vector{T}
  function _Lattice{T}(beamlines::Vector{T}) where {T}
    lat = new(beamlines)
    for i in eachindex(beamlines)
      bl = beamlines[i]
      if getfield(bl, :lattice_index) != -1
        error("Beamline $i is already in another Lattice!")
      end
      setfield!(bl, :lattice, lat)
      setfield!(bl, :lattice_index, i)
    end
    return lat
  end
end

@enumx RefMeaning R_ref E_ref pc_ref dR_ref dE_ref dpc_ref

@inline function refmeaning_to_sym(ref_meaning::RefMeaning.T)
  if ref_meaning == RefMeaning.R_ref
    return :R_ref
  elseif ref_meaning == RefMeaning.E_ref
    return :E_ref
  elseif ref_meaning == RefMeaning.pc_ref
    return :pc_ref
  elseif ref_meaning == RefMeaning.dR_ref
    return :dR_ref
  elseif ref_meaning == RefMeaning.dE_ref
    return :dE_ref
  else
    return :dpc_ref
  end
end

@inline function sym_to_refmeaning(sym::Symbol)
  if sym == :R_ref
    return RefMeaning.R_ref
  elseif sym == :E_ref
    return RefMeaning.E_ref
  elseif sym == :pc_ref
    return RefMeaning.pc_ref
  elseif sym == :dR_ref
    return RefMeaning.dR_ref
  elseif sym == :dE_ref
    return RefMeaning.dE_ref
  else
    return RefMeaning.dpc_ref
  end
end

# The Beamline type is essentially an "expanded" lattice, as
# in there are no PreExpansionDirectives here anymore.
@kwdef mutable struct Beamline <: Branch
  const line::ReadOnlyVector{LineElement, Vector{LineElement}}
  const species_ref::Species
  lattice::_Lattice{Beamline} # This should be HARD to change, not allowed easily
  lattice_index::Int          # This should be HARD to change, not allowed easily
  ref_meaning::RefMeaning.T   # This should be HARD to change, not allowed easily
  ref # Will be nothing if not specified

  # Beamlines can be very long, so realistically only 
  # Base.Vector should be allowed.
  function Beamline(
    line;
    species_ref::Species=Species(),  
    R_ref=nothing, 
    E_ref=nothing, 
    pc_ref=nothing,
    dR_ref=nothing, 
    dE_ref=nothing, 
    dpc_ref=nothing,
  )
    kwargs = (R_ref, E_ref, pc_ref, dR_ref, dE_ref, dpc_ref)
    kwarg_syms = (:R_ref, :E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref)
    c = count(t->!isnothing(t), kwargs)
    if c > 1
      error("Only one of $(kwarg_syms) can be specified")
    end
    
    ibp = length(line) > 0 && haskey(getfield(first(line), :pdict), InitialBeamlineParams) ? getfield(first(line), :pdict)[InitialBeamlineParams] : nothing
    if !isnothing(ibp)
      if isnullspecies(species_ref)
        species_ref = getfield(ibp, :species_ref)
      end
    end

    bl = new(ReadOnlyVector(vec(line)), species_ref, NULL_LATTICE, -1, RefMeaning.R_ref, nothing)

    # Check if any are in a Beamline already
    for i in eachindex(bl.line)
      if i != 1 && haskey(getfield(bl.line[i], :pdict), InitialBeamlineParams)
        reverse_bl_construction!(bl, i)
        error("Cannot construct Beamline: element $i contains an InitialBeamlineParams 
               which can only be placed in the first element of a Beamline. To include 
               reference energy/species changes in the middle of an accelerator, use the 
               Lattice constructor instead which will automatically construct separate 
               Beamlines for each InitialBeamlineParams.")
      end
      if haskey(getfield(bl.line[i], :pdict), BeamlineParams)
        if bl.line[i].beamline != bl # Different Beamline - need to error
          reverse_bl_construction!(bl, i)
          error("Cannot construct Beamline: element $i with name $(bl.line[i].name) is already in a Beamline")
        else # Duplicate element
          # .parent overrides ReadOnlyArray
          bl.line.parent[i] = LineElement(ParamDict(InheritParams=>InheritParams(bl.line[i])))
        end
      end
      # HARD put in because may need to override InheritParams
      getfield(bl.line[i], :pdict)[BeamlineParams] = BeamlineParams(bl, i)
    end


    # Now at end set the stuff (in case construction needed to be reversed due to error)
    if !isnothing(ibp)
      setproperty!(bl, refmeaning_to_sym(ibp.ref_meaning), getfield(ibp, :ref))
      delete!(getfield(bl.line[1], :pdict), InitialBeamlineParams) # always delete it
    end

    # Beamline ctor kwargs override any InitialBeamlineParams
    if c == 1
      idx = findfirst(t->!isnothing(t), kwargs)
      sym = (:R_ref, :E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref)[idx]
      val = (R_ref, E_ref, pc_ref, dR_ref, dE_ref, dpc_ref)[idx]
      setproperty!(bl, sym, val)
    end

    return bl
  end
end

function reverse_bl_construction!(bl::Beamline, idx)
  for i in idx:-1:1
    ele = bl.line[i]
    if !isnothing(ele.BeamlineParams) && ele.BeamlineParams.beamline === bl
      ele.BeamlineParams = nothing
    end
  end
  return
end

const Lattice = _Lattice{Beamline}
const NULL_LATTICE = Lattice(Beamline[])

Base.propertynames(::Beamline) = (:line, :ref_meaning, :ref, :lattice, :lattice_index, :R_ref, :E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref, :species_ref)
 

# Sign is included to ensure that values could be dE_ref, dR_ref, for example
R_to_E(species_ref::Species, R) = @FastGTPSA sign(R)*sign(chargeof(species_ref))*sqrt((R*C_LIGHT*chargeof(species_ref))^2 + massof(species_ref)^2)
E_to_R(species_ref::Species, E) = @FastGTPSA sign(E)*massof(species_ref)*sinh(acosh(abs(E)/massof(species_ref)))/C_LIGHT/chargeof(species_ref)  # sqrt(E^2-massof(species_ref)^2)/C_LIGHT/chargeof(species_ref)
pc_to_R(species_ref::Species, pc) = @FastGTPSA pc/C_LIGHT/chargeof(species_ref)
R_to_pc(species_ref::Species, R) = @FastGTPSA R*chargeof(species_ref)*C_LIGHT
E_to_pc(species_ref::Species, E) = @FastGTPSA sign(E)*massof(species_ref)*sinh(acosh(abs(E)/massof(species_ref)))
pc_to_E(species_ref::Species, pc) = @FastGTPSA sign(pc)*sqrt((pc)^2 + massof(species_ref)^2)

function Base.getproperty(b::Beamline, key::Symbol)
  # Fast gets first, hopefully constant prop
  if key in (:ref, :ref_meaning, :species_ref, :line, :lattice, :lattice_index)
    field = deval(getfield(b, key))
    if key == :ref && isnothing(field)
      #@warn "R_ref has not been set: using default value of NaN"
      error("Unable to get $key: ref of the Beamline has not been set")
    elseif key == :species_ref && isnullspecies(field)
      error("Unable to get species_ref: species_ref of the Beamline has not been set")
    elseif key in (:lattice, :lattice_index) && (field == -1 || field === NULL_LATTICE)
      error("Unable to get $key: Beamline is not in a Lattice")
    end
    return field
  elseif key in (:E_ref, :pc_ref, :R_ref, :dE_ref, :dpc_ref, :dR_ref)
    ref_meaning = refmeaning_to_sym(b.ref_meaning)
    if key == ref_meaning
      return b.ref
    elseif key in (:E_ref, :pc_ref, :R_ref)
      # Key absolute
      if ref_meaning in (:E_ref, :pc_ref, :R_ref)
        # Both absolute is easy
        if key == :E_ref
          if ref_meaning == :pc_ref
            return pc_to_E(b.species_ref, b.ref)
          else
            return R_to_E(b.species_ref, b.ref)
          end
        elseif key == :pc_ref
          if ref_meaning == :E_ref
            return E_to_pc(b.species_ref, b.ref)
          else
            return R_to_pc(b.species_ref, b.ref)
          end
        else
          if ref_meaning == :pc_ref
            return pc_to_R(b.species_ref, b.ref)
          else
            return E_to_R(b.species_ref, b.ref)
          end
        end
      else
        # Key absolute, ref_meaning relative
        if (key == :E_ref && ref_meaning == :dE_ref) || 
            (key == :pc_ref && ref_meaning == :dpc_ref) || 
            (key == :R_ref && ref_meaning == :dR_ref)
          # Can just add going backwards
          lat_idx = getfield(b, :lattice_index)
          if lat_idx == -1
            error("Unable to get property $key: because this Beamline has set $(ref_meaning),
                    the property $key must be dependent on an upstream Beamline in a Lattice, but 
                    the Beamline is not in a Lattice.")
          elseif lat_idx == 1
            return b.ref # Basically just assume zero for all "before" if first Beamline (out of thin air)
          else
            return b.ref + getproperty(b.lattice.beamlines[b.lattice_index-1], key)
          end
        elseif key == :E_ref
          if ref_meaning == :dpc_ref
            return pc_to_E(b.species_ref, b.pc_ref)
          else
            return R_to_E(b.species_ref, b.R_ref)
          end
        elseif key == :pc_ref
          if ref_meaning == :dE_ref
            return E_to_pc(b.species_ref, b.E_ref)
          else
            return R_to_pc(b.species_ref, b.R_ref)
          end
        else
          if ref_meaning == :dpc_ref
            return pc_to_R(b.species_ref, b.pc_ref)
          else
            return E_to_R(b.species_ref, b.E_ref)
          end
        end
      end
    else
      # Key relative
      lat_idx = getfield(b, :lattice_index)
      if lat_idx == -1
        error("Unable to get property $key: because this Beamline has set $(ref_meaning),
                the property $key must be dependent on an upstream Beamline in a Lattice, but 
                the Beamline is not in a Lattice.")
      elseif lat_idx == 1
        return b.ref # Basically just assume zero for all "before" if first Beamline (out of thin air)
      else
        if key == :dE_ref
          return b.E_ref - b.lattice.beamlines[b.lattice_index-1].E_ref
        elseif key == :dpc_ref
          return b.pc_ref - b.lattice.beamlines[b.lattice_index-1].pc_ref
        else
          return b.R_ref - b.lattice.beamlines[b.lattice_index-1].R_ref
        end
      end
    end
  else
    error("Unable to get property $key from Beamline: Beamline does not have this property")
  end
  error("This error is unreachable. If reached, submit an issue to Beamlines")
end

function Base.setproperty!(b::Beamline, key::Symbol, value)
  if key in (:ref, :species_ref, :line)
    return setfield!(b, key, value)
  elseif key in (:lattice, :lattice_index, :ref_meaning)
    error("Unable to set property $key: this field is protected")
  elseif key in (:E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref)
    setfield!(b, :ref_meaning, sym_to_refmeaning(key))
    return setfield!(b, :ref, value)
  elseif key == :R_ref
    species_ref = getfield(b, :species_ref)
    if !isnothing(value) && !isnullspecies(species_ref) && sign(chargeof(species_ref)) != sign(value)
      println("Setting R_ref to $(sign(chargeof(species_ref))*value) to match sign of species_ref charge")
      setfield!(b, :ref_meaning, sym_to_refmeaning(key))
      return setfield!(b, :ref, sign(chargeof(species_ref))*value)
    else
      setfield!(b, :ref_meaning, sym_to_refmeaning(key))
      return setfield!(b, :ref, value)
    end
  else
    error("Unable to set property $key in Beamline: Beamline does not have this property")
  end
end

struct BeamlineParams <: AbstractParams
  beamline::Beamline
  beamline_index::Int
end

# Make E_ref and R_ref (in beamline) be properties
# Also make s a property of BeamlineParams
# Note that because BeamlineParams is immutable, not setting rn
Base.propertynames(::BeamlineParams) = (:beamline, :beamline_index, :s, :s_downstream, :R_ref, :E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref, :species_ref, :lattice, :lattice_index)

function Base.setproperty!(bp::BeamlineParams, key::Symbol, value)
  # only settable at first element
  if key in (:R_ref, :E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref)
    if bp.beamline_index == 1 # && !any(t->haskey(getfield(t, :pdict), InheritParams) && getfield(t, :pdict)[InheritParams].parent === ele, bp.beamline.line)
      return setproperty!(bp.beamline, key, value)
    else
      error("Property $key is a Beamline property, and therefore is only settable at 
            at the first element in a Beamline Consider setting $key at the Beamline 
            level (e.g. beamline.$key = $value), or setting this parameter in an element 
            prior to Lattice construction to automatically generate a separate Beamline.")
    end
  else
    return setproperty!(bp.beamline, key, value)
  end
end

# Because BeamlineParams contains an abstract type, "replacing" it 
# is just modifying the field and returning itself
# Unreachable? need to check coverage
function replace(bp::BeamlineParams, key::Symbol, value)
  #if key in (:R_ref, :E_ref, :pc_ref, :dR_ref, :dE_ref, :dpc_ref, :species_ref)
  setproperty!(bp, key, value)
  return bp
  #else
  #  error("BeamlineParams property $key cannot be modified")
  #end
end

function Base.getproperty(bp::BeamlineParams, key::Symbol)
  if key in (:R_ref, :E_ref, :pc_ref, :species_ref, :lattice, :lattice_index, :ref)
    return deval(getproperty(bp.beamline, key))
  elseif key in (:dR_ref, :dE_ref, :dpc_ref)
    if bp.beamline_index != 1
      return 0
    else
      return deval(getproperty(bp.beamline, key))
    end
  elseif key in (:s, :s_downstream)
    if key == :s
      n = bp.beamline_index - 1
      if n == 0
        return 0
      end
    else
      n = bp.beamline_index
    end
    # s is the sum of the lengths of all preceding elements
    line = bp.beamline.line
    return deval(sum(line[i].L for i in 1:n))
  else
    return getfield(bp, key)
  end
end


# InitialBeamlineParams which stores things before making a Beamline
# This allows the behavior of e.g. setting the first element's E_ref, etc
# This will then get destroyed when constructing a Beamline
@kwdef mutable struct InitialBeamlineParams <: AbstractParams
  species_ref::Species       = Species()
  ref_meaning::RefMeaning.T  = RefMeaning.R_ref
  ref                        = nothing
end

function Base.setproperty!(ibp::InitialBeamlineParams, key::Symbol, value)
  if key in (:E_ref, :R_ref, :pc_ref, :dE_ref, :dR_ref, :dpc_ref)
    setfield!(ibp, :ref_meaning, sym_to_refmeaning(key))
    setfield!(ibp, :ref, value)
  else
    setfield!(ibp, key, value)
  end
  return value
end

function Base.getproperty(ibp::InitialBeamlineParams, key::Symbol)
  if key in (:ref, :species_ref, :ref_meaning)
    field = deval(getfield(ibp, key))
    if key == :ref && isnothing(field)
      error("Unable to get ref: ref of the Beamline has not been set")
    elseif key == :species_ref && isnullspecies(field)
      error("Unable to get species_ref: species_ref of the Beamline has not been set")
    end
    return field
  else
    ref_meaning = refmeaning_to_sym(ibp.ref_meaning)
    if key == ref_meaning
      return ibp.ref
    elseif key in (:R_ref, :E_ref, :pc_ref) && ref_meaning in (:R_ref, :E_ref, :pc_ref)
      if key == :E_ref
        if ref_meaning == :pc_ref
          return pc_to_E(ibp.species_ref, ibp.ref)
        else
          return R_to_E(ibp.species_ref, ibp.ref)
        end
      elseif key == :pc_ref
        if ref_meaning == :E_ref
          return E_to_pc(ibp.species_ref, ibp.ref)
        else
          return R_to_pc(ibp.species_ref, ibp.ref)
        end
      else
        if ref_meaning == :pc_ref
          return pc_to_R(ibp.species_ref, ibp.ref)
        else
          return E_to_R(ibp.species_ref, ibp.ref)
        end
      end
    else
      error("Unable to get property $key: InitialBeamlineParams has stored $(ibp.ref_meaning), and
            so property $key depends on an upstream Lattice which has not been constructed yet.")
    end
  end
  error("This error is unreachable. If reached, submit an issue to Beamlines")
end