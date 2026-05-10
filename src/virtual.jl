#=

Functional virtual getters/setters should generally only be used 
when you have a calculation which involves different parameter 
structs, e.g. BMultipoleParams and BeamlineParams are needed to 
get/set normalized field strengths.

If only one parameter struct is needed, then it is better for 
performance to make it a virtual field in the parameter struct 
itself by overriding  getproperty and optionally setproperty! 
for the parameter struct.

Nonetheless the performance difference is not significant so 
functional virtual getters/setters can be used if speed is 
less of a concern.

Virtual getters/setters MUST NOT go to the pdict to get/set values.
This is because of InheritParams. E.g., for an element containing 
InheritParams, the following gets are NOT equal:

ele.BMultipoleParams        # Goes to InheritParams to get parent

=#

function get_BM_strength(ele::LineElement, key::Symbol)
  b = ele.BMultipoleParams
  if isnothing(b)
    return 0f0
  end
  return @noinline _get_BM_strength(ele, b, key)
end

function _get_BM_strength(ele, b::BMultipoleParams, key)
  normal, order, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[key]
  # Default
  if !(order in b.order)
    return zero(first(b.n))
  end
  i = o2i(b,order)
  strength = deval(normal ? b.n[i] : b.s[i])
  stored_normalized = b.normalized[i]
  stored_integrated = b.integrated[i]
  # Yes there is a simpler way to write the below but this 
  # way minimizes type instability.
  if stored_normalized == normalized
    if stored_integrated == integrated
      return strength
    else
      L = ele.L
      if stored_integrated == false 
        # user asking for integrated strength of non-integrated BMultipole
        return strength*L
      else
        # user asking for non-integrated strength of integrated BMultipole
        if L == 0
          error("Unable to get $key of LineElement: Integrated multipole is stored, but the element length L = 0")
        end
        return strength/L
      end
    end
  else
    if !isactive(ele.BeamlineParams)
      if stored_normalized == true
        error("Unable to get $key of LineElement: Normalized multipole is stored, but the element is not within a Beamline with a set p_over_q_ref")
      else
        error("Unable to get $key of LineElement: Unnormalized multipole is stored, but the element is not within a Beamline with a set p_over_q_ref")
      end
    end
    p_over_q_ref = ele.p_over_q_ref
    if stored_integrated == integrated
      if stored_normalized == false
        # user asking for normalized strength of unnormalized BMultipole
        return strength/p_over_q_ref
      else
        # user asking for unnormalized strength of normalized BMultipole
        return strength*p_over_q_ref
      end
    else
      L = ele.L
      if stored_normalized == false
        if stored_integrated == false
          return strength/p_over_q_ref*L
        else
          if L == 0
            error("Unable to get $key of LineElement: Integrated multipole is stored, but the element length L = 0")
          end
          return strength/p_over_q_ref/L
        end
      else
        if stored_integrated == false
          return strength*p_over_q_ref*L
        else
          if L == 0
            error("Unable to get $key of LineElement: Integrated multipole is stored, but the element length L = 0")
          end
          return strength*p_over_q_ref/L
        end
      end
    end
  end
end

function _promote_bm(b1::BMultipoleParams{S}, ::Type{T}) where {S,T}
  SNEW = promote_type(S, T)
  if S == SNEW
    return b1
  else
    return BMultipoleParams{SNEW}(b1)
  end
end

function set_BM_strength!(ele::LineElement, key::Symbol, value)
  b1 = ele.BMultipoleParams
  if isnothing(b1)
    b1 = BMultipoleParams()
  end
  b = @noinline _set_BM_strength!(ele, b1, key, value)
  if !(b === b1)
    ele.BMultipoleParams = b
  end
  return value
end

function _set_BM_strength!(ele, b::BMultipoleParams, key, value)
  normal, order, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[key]

  if !(order in b.order)
    b = addord(b, order, normalized, integrated)
  end

  i = o2i(b, order)
  if b.normalized[i] == normalized && b.integrated[i] == integrated
      # EASY!
      b = _promote_bm(b, typeof(value))
      bm = normal ? b.n : b.s
      bm[i] = value
  end

  # Switching normalized status:
  if b.normalized[i] != normalized
    #=
    This is the hard case.
    Here we will keep the angle between both multipoles the same.
    This is done by ensuring that Bs*Kn = Ks*Bn
    =#
    old_val = normal ? b.n[i] : b.s[i]
    old_other_val = normal ? b.s[i] : b.n[i]
    if old_val == 0
      if old_other_val == 0
        new_other_val = 0
      else
        old_sym = BMULTIPOLE_STRENGTH_INVERSE_MAP[(normal, order, b.normalized[i], b.integrated[i])]
        old_other_sym = BMULTIPOLE_STRENGTH_INVERSE_MAP[(!normal, order, b.normalized[i], b.integrated[i])]
        new_other_sym = BMULTIPOLE_STRENGTH_INVERSE_MAP[(!normal, order, !(b.normalized[i]), integrated)]
        error("
        Unable to set multipole $(key): currently stored is $(old_other_sym), and setting $(key) would 
        change the order $order multipole to have normalized=$normalized as the independent variable.
        The only consistent way to then update $(old_other_sym) is to set the value so the 
        angle between $(new_other_sym) and $(key) remains the same as the angle between $(old_other_sym)
        and $(old_sym). However, this angle is undefined if $(old_sym) = 0, because $(new_other_sym) 
        would have to be infinite.
        ")
      end
    else
      new_other_val = old_other_val*value/old_val
    end
    b = _promote_bm(b, promote_type(typeof(value),typeof(new_other_val)))
    @reset b.normalized[i] = normalized
    if normal
      b.n[i] = value
      b.s[i] = new_other_val
    else
      b.s[i] = value
      b.n[i] = new_other_val
    end
  end

  # Switching integrated status
  if b.integrated[i] != integrated
    L = ele.L
    old_other_val = normal ? b.s[i] : b.n[i]
    new_other_val = old_other_val*(integrated ? L : 1/L)
    b = _promote_bm(b, promote_type(typeof(value),typeof(new_other_val)))
    @reset b.integrated[i] = integrated
    if normal
      b.n[i] = value
      b.s[i] = new_other_val
    else
      b.s[i] = value
      b.n[i] = new_other_val
    end
  end
  return b
end

get_bend_angle(::LineElement, ::Symbol) = error("Property `angle` is write-only, and sets both `g_ref` and `Kn0` together")

function set_bend_angle!(ele::LineElement, ::Symbol, value)
  L = ele.L
  bm = ele.BMultipoleParams
  bp = ele.BendParams
  if isnothing(bp)
    bp = BendParams()
    ele.BendParams = bp
  end
  if isnothing(bm)
    bm = BMultipoleParams()
    ele.BMultipoleParams = bm
  end
  return @noinline _set_bend_angle!(ele, L, bm, bp, value)
end

function _set_bend_angle!(ele, L, bm, bp, value)
  # Angle = K0*L -> K0 = angle/L
  if L == 0
    error("Cannot set angle of LineElement with L = 0 (did you specify `angle` before specifying `L`?)")
  end
  Kn0 = value/L
  _set_bend_g!(ele, bp, bm, Kn0) # sets both g_ref and Kn0
  return value
end

get_bend_g(::LineElement, ::Symbol) = error("Property `g` is write-only, and sets both `g_ref` and `Kn0` together.")

function set_bend_g!(ele::LineElement, ::Symbol, value)
  bp = ele.BendParams
  bm = ele.BMultipoleParams
  if isnothing(bp)
    bp = BendParams()
    ele.BendParams = bp
  end
  if isnothing(bm)
    bm = BMultipoleParams()
    ele.BMultipoleParams = bm
  end
  return @noinline _set_bend_g!(ele, bp, bm, value)
end

function _set_bend_g!(ele::LineElement, bp::BendParams{S}, bm::BMultipoleParams, value) where {S}
  T = promote_type(S, typeof(value))
  if T != S || bp.g_ref != value
    bp = set(bp, opcompose(PropertyLens(:g_ref)), T(value))
    ele.BendParams = bp
  end
  @noinline set_BM_strength!(ele, :Kn0, T(value))
  return value
end

function get_BM_independent(ele::LineElement, ::Symbol)
  b = ele.BMultipoleParams
  return @noinline _get_BM_independent(b)
end

function _get_BM_independent(b)
  if isnothing(b)
    return SVector{0,@NamedTuple{order::Int, normalized::Bool, integrated::Bool}}[]
  end
  v = StaticArrays.sacollect(SVector{length(b),@NamedTuple{order::Int, normalized::Bool, integrated::Bool}}, begin 
    (; order=b.order[i], normalized=b.normalized[i], integrated=b.integrated[i])
  end for i in 1:length(b))
  return v
end

function set_BM_independent!(ele::LineElement, ::Symbol, value)
  eltype(value) == @NamedTuple{order::Int, normalized::Bool, integrated::Bool}  || error("Please provide a list/array/tuple with eltype @NamedTuple{order::Int, normalized::Bool, integrated::Bool} to specify the multipole properties you want to set as independent variables.")
  b = ele.BMultipoleParams
  if isnothing(b)
    b = BMultipoleParams()
    ele.BMultipoleParams = b
  end
  for bm in value
    if bm.order in b.order
      order = bm.order
      normalized = bm.normalized
      integrated = bm.integrated
      i = o2i(b, bm.order)
      oldn = b.n[i]
      olds = b.s[i] 
      old_normalized = b.normalized[i]
      old_integrated = b.integrated[i]
      n = oldn
      s = olds
      if old_normalized != normalized
        if old_normalized == true
          n *= ele.p_over_q_ref
          s *= ele.p_over_q_ref
        else
          n /= ele.p_over_q_ref
          s /= ele.p_over_q_ref
        end
      end

      if old_integrated != integrated
        if old_integrated == true
          ele.L != 0 || error("Unable to set change multipole order $order to have independent variable $sym: element length L = 0")
          n /= ele.L
          s /= ele.L
        else
          n *= ele.L
          s *= ele.L
        end
      end
      T = promote_type(typeof(n),typeof(oldn))
      if T != typeof(oldn)
        b = BMultipoleParams{T}(b)
        ele.BMultipoleParams = b
      end
      b.n[i] = n
      b.s[i] = s
      @reset b.normalized[i] = normalized
      @reset b.integrated[i] = integrated
      ele.BMultipoleParams = b
    else # just add it in , easy
      b = addord(b, bm.order, bm.normalized, bm.integrated)
      ele.BMultipoleParams = b
    end
  end
  return value
end

# When field_master = true, the B fields are the independent variables
# If false, the normalized strengths are the independent variables
# so field_master = !normalized in my BMultipole structure
function set_field_master!(ele::LineElement, ::Symbol, value::Bool)
  BM_independent = _get_BM_independent(ele.BMultipoleParams)
  c = map(t->(; order=t.order, normalized=!value, integrated=t.integrated), BM_independent)
  return set_BM_independent!(ele, :nothing, c)
end

function set_integrated_master!(ele::LineElement, ::Symbol, value::Bool)
  BM_independent = _get_BM_independent(ele.BMultipoleParams)
  c = map(t->(; order=t.order, normalized=t.normalized, integrated=value), BM_independent)
  return set_BM_independent!(ele, :nothing, c)
end

function get_field_master(ele::LineElement, ::Symbol)
  b = ele.BMultipoleParams
  return @noinline _get_field_master(b)
end

function _get_field_master(b)
  if isnothing(b)
    error("Unable to get field_master: LineElement does not contain BMultipoleParams")
  end
  check = first(b.normalized)
  if !all(t->t==check, b.normalized)
    error("Unable to get field_master: BMultipoleParams contains at least one BMultipole with the normalized strength as the independent variable and at least one other BMultipole with the unnormalized strength as the independent variable")
  end
  return !check
end

function get_integrated_master(ele::LineElement, ::Symbol)
  b = ele.BMultipoleParams
  return @noinline _get_integrated_master(b)
end

function _get_integrated_master(b)
  if isnothing(b)
    error("Unable to get integrated_master: LineElement does not contain BMultipoleParams")
  end
  check = first(b.integrated)
  if !all(t->t==check, b.integrated)
    error("Unable to get integrated_master: BMultipoleParams contains at least one BMultipole with the integrated strength as the independent variable and at least one other BMultipole with the non-integrated strength as the independent variable")
  end
  return check
end

function get_cavity_rate(ele::LineElement, key::Symbol)
  rfp = ele.RFParams
  if isnothing(rfp) || getfield(rfp, :rate_meaning) == RateMeaning.Indeterminate
    return 0f0 # Default value
  end
  rate_meaning = getfield(rfp, :rate_meaning)
  rate = getfield(rfp, :rate)
  if ((key == :harmon) && rate_meaning == RateMeaning.Harmon) || ((key == :rf_frequency) && rate_meaning == RateMeaning.RFFrequency)
    return rate
  else # Need to convert
    bp = ele.BeamlineParams
    if isnothing(bp)
      error("Unable to get $key from LineElement: element is not in a Beamline and has harmon_master = $(rfp.harmon_master)")
    end
    bl = bp.beamline
    species = bl.species_ref
    circumference = bl.line[end].s_downstream
    v = R_to_v(species, bl.p_over_q_ref)
    if key == :harmon # rf_frequency is stored, user asks for harmon
      rf_frequency = rate
      return rf_frequency*circumference/v
    else # harmon is stored, user asks for rf_frequency
      harmon = rate
      return harmon*v/circumference
    end
  end
end

function set_cavity_rate!(ele::LineElement, key::Symbol, value)
  rf1 = ele.RFParams
  if isnothing(rf1)
    rf1 = RFParams()
  end
  rf = @noinline _set_cavity_rate!(rf1, key, value)
  if !(rf === rf1)
    ele.RFParams = rf
  end
  return value
end

function _set_cavity_rate!(rf::RFParams{S}, key, value) where {S}
  rate_meaning = key == :harmon ? RateMeaning.Harmon : RateMeaning.RFFrequency
  if rf.rate_meaning != rate_meaning
    rf = set(rf, opcompose(PropertyLens(:rate_meaning)), rate_meaning)
  end
  T = promote_type(S,typeof(value))
  if T != S
    rf = set(rf, opcompose(PropertyLens(:rate)), T(value))
  else
    setfield!(rf, :rate, T(value))
  end
  return rf
end

function set_harmon_master!(ele::LineElement, ::Symbol, value::Bool)
  rfp = ele.RFParams
  if isnothing(rfp)
    ele.RFParams = RFParams(harmon_master=value)
    return value
  else # Need to convert internal
    if value # store harmon internally now
      # Use the regular getter - changing harmon_master doesn't need to 
      # be super optimized
      harmon = ele.harmon
      rfp = set(rfp, opcompose(PropertyLens(:rate)), harmon)
    else
      rf_frequency = ele.rf_frequency
      rfp = set(rfp, opcompose(PropertyLens(:rate)), rf_frequency)
    end
  end
  rfp = set(rfp, opcompose(PropertyLens(:rate_meaning)), value ? RateMeaning.Harmon : RateMeaning.RFFrequency)
  ele.RFParams = rfp
  return value
end

# Override is only needed bc error is thrown if either reference
# species or reference energy are not set and generic setter 
# first does a get to check if type promotion needed
function set_bl_params!(ele::LineElement, sym::Symbol, value)
  ibp = ele.InitialBeamlineParams
  if isnothing(ibp)
    ibp = InitialBeamlineParams()
    ele.InitialBeamlineParams = ibp
  end
  return setproperty!(ibp, sym, value)
end

# TODO: add logic to auto-set p_over_q_ref properly if species specified
function get_bl_params(ele::LineElement, key::Symbol)
  pdict = getfield(ele, :pdict)
  
  if haskey(pdict, BeamlineParams) # If element in a Beamline
    beamline = (pdict[BeamlineParams]::BeamlineParams).beamline
    ibp = first(beamline.line).InitialBeamlineParams
    if isnothing(ibp) # If first element does not have InitialBeamlineParams, then it is inferred from previous
      lattice_index = getfield(beamline, :lattice_index)
      if lattice_index == -1 || lattice_index == 1
        error("Unable to get $key: $key is not set nor inferrable")
      else
        return getproperty(getfield(beamline, :lattice).beamlines[lattice_index-1], key)
      end
    elseif key == :species_ref # Species
      field = getfield(ibp, :species_ref) 
      if isnullspecies(field)
        lattice_index = getfield(beamline, :lattice_index)
        if lattice_index == -1 || lattice_index == 1
          error("Unable to get $key: $key is not set nor inferrable")
        else
          return getproperty(getfield(beamline, :lattice).beamlines[lattice_index-1], key)
        end
      else
        return field
      end
    else # key in (:E_ref, :pc_ref, :p_over_q_ref, :dE_ref, :dpc_ref, :dp_over_q_ref)
      ref = getfield(ibp, :ref)
      if isnothing(ref)
        lattice_index = getfield(beamline, :lattice_index)
        if lattice_index == -1 || lattice_index == 1
          error("Unable to get $key: $key is not set nor inferrable")
        else
          return getproperty(getfield(beamline, :lattice).beamlines[lattice_index-1], key)
        end
      end
      ref_meaning = refmeaning_to_sym(getfield(ibp, :ref_meaning))
      if key == ref_meaning
        return ref
      elseif key in (:E_ref, :pc_ref, :p_over_q_ref) # Key absolute
        species_ref = getfield(ibp, :species_ref)
        if isnullspecies(species_ref)
          error("
            Unable to get $key: stored is $ref_meaning and computing $key requires a species_ref,
            which has not been set.
          ")
        end
        if ref_meaning in (:E_ref, :pc_ref, :p_over_q_ref) # key absolute, ref_meaning absolute
          if key == :E_ref
            if ref_meaning == :pc_ref
              return pc_to_E(species_ref, ref)
            else
              return R_to_E(species_ref, ref)
            end
          elseif key == :pc_ref
            if ref_meaning == :E_ref
              return E_to_pc(species_ref, ref)
            else
              return R_to_pc(species_ref, ref)
            end
          else
            if ref_meaning == :pc_ref
              return pc_to_R(species_ref, ref)
            else
              return E_to_R(species_ref, ref)
            end
          end
        else # Key absolute, ref_meaning relative
          if (key == :E_ref && ref_meaning == :dE_ref) || 
              (key == :pc_ref && ref_meaning == :dpc_ref) || 
              (key == :p_over_q_ref && ref_meaning == :dp_over_q_ref)
            # Can just add going backwards
            lattice_index = getfield(beamline, :lattice_index)
            if lattice_index == -1
              error("
                Unable to get property $key: because this Beamline has set $(ref_meaning),
                the property $key must be dependent on an upstream Beamline in a Lattice, but 
                the Beamline is not in a Lattice.
              ")
            elseif latice_index == 1
              return ref # Basically just assume zero for all "before" if first Beamline (out of thin air)
            else
              return ref + getproperty(getfield(beamline, :lattice).beamlines[lattice_index-1], key)
            end
          elseif key == :E_ref
            species_ref = getfield(ibp, :species_ref)
            if isnullspecies(species_ref)
              error("
                Unable to get $key: stored is $ref_meaning and computing $key requires a species_ref,
                which has not been set.
              ")
            end
            if ref_meaning == :dpc_ref
              return pc_to_E(species_ref, ibp.pc_ref)
            else
              return R_to_E(species_ref, ibp.p_over_q_ref)
            end
          elseif key == :pc_ref
            if ref_meaning == :dE_ref
              return E_to_pc(species_ref, ibp.E_ref)
            else
              return R_to_pc(species_ref, ibp.p_over_q_ref)
            end
          else # key == :p_over_q_ref
            if ref_meaning == :dpc_ref
              return pc_to_R(species_ref, ibp.pc_ref)
            else
              return E_to_R(species_ref, ibp.E_ref)
            end
          end
        end
      else # Key relative
        lattice_index = getfield(b, :lattice_index)
        if lattice_index == -1
          error("
            Unable to get property $key: because this Beamline has set $(ref_meaning),
            the property $key must be dependent on an upstream Beamline in a Lattice, but 
            the Beamline is not in a Lattice.
          ")
        elseif lattice_index == 1
          return ref # Basically just assume zero for all "before" if first Beamline (out of thin air)
        else
          if key == :dE_ref
            return ibp.E_ref - getfield(beamline, :lattice).beamlines[lattice_index-1].E_ref
          elseif key == :dpc_ref
            return ibp.pc_ref - getfield(beamline, :lattice).beamlines[lattice_index-1].pc_ref
          else
            return ibp.p_over_q_ref - getfield(beamline, :lattice).beamlines[lattice_index-1].p_over_q_ref
          end
        end
      end
    end
  else # not in a Beamline, just return ibp
    ibp = ele.InitialBeamlineParams
    if isnothing(ibp)
      error("Unable to get $key: $key is not set nor inferrable")
    else
      return getproperty(ibp, key)
    end
  end
end

function get_parent_ele(ele::LineElement, ::Symbol)
  pdict = getfield(ele, :pdict)
  if haskey(pdict, InheritParams)
    return get_parent(pdict)
  else
    return ele
  end
end

const VIRTUAL_GETTER_MAP = Dict{Symbol,Function}(
  [key => get_BM_strength for (key, value) in BMULTIPOLE_STRENGTH_MAP]...,

  :angle => get_bend_angle,
  :g => get_bend_g,

  :BM_independent => get_BM_independent,
  :field_master => get_field_master,
  :integrated_master => get_integrated_master,

  :rf_frequency => get_cavity_rate,
  :harmon => get_cavity_rate,

  :species_ref => get_bl_params,
  :p_over_q_ref => get_bl_params,
  :E_ref => get_bl_params,
  :pc_ref => get_bl_params,
  :dp_over_q_ref => get_bl_params,
  :dE_ref => get_bl_params,
  :dpc_ref => get_bl_params,

  :parent => get_parent_ele,
)

const VIRTUAL_SETTER_MAP = Dict{Symbol,Function}(
  [key => set_BM_strength! for (key, value) in BMULTIPOLE_STRENGTH_MAP]...,

  :angle => set_bend_angle!,
  :g => set_bend_g!,

  :BM_independent => set_BM_independent!,
  :field_master => set_field_master!,
  :integrated_master => set_integrated_master!,

  :rf_frequency => set_cavity_rate!,
  :harmon => set_cavity_rate!,
  :harmon_master => set_harmon_master!,

  :species_ref => set_bl_params!,
  :p_over_q_ref => set_bl_params!,
  :E_ref => set_bl_params!,
  :pc_ref => set_bl_params!,
  :dp_over_q_ref => set_bl_params!,
  :dE_ref => set_bl_params!,
  :dpc_ref => set_bl_params!,
)
