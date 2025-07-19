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
  return @noinline _get_BM_strength(ele, b, key)
end

function _get_BM_strength(ele, b::BMultipoleParams, key)
  normal, order, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[key]
  if isnothing(b) || !(order in b.order)
    error("Unable to get property $key from $b::$(typeof(b))")
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
        error("Unable to get $key of LineElement: Normalized multipole is stored, but the element is not within a Beamline with a set Brho_ref")
      else
        error("Unable to get $key of LineElement: Unnormalized multipole is stored, but the element is not within a Beamline with a set Brho_ref")
      end
    end
    Brho_ref = ele.Brho_ref
    if stored_integrated == integrated
      if stored_normalized == false
        # user asking for normalized strength of unnormalized BMultipole
        return strength/Brho_ref
      else
        # user asking for unnormalized strength of normalized BMultipole
        return strength*Brho_ref
      end
    else
      L = ele.L
      if stored_normalized == false
        if stored_integrated == false
          return strength/Brho_ref*L
        else
          if L == 0
            error("Unable to get $key of LineElement: Integrated multipole is stored, but the element length L = 0")
          end
          return strength/Brho_ref/L
        end
      else
        if stored_integrated == false
          return strength*Brho_ref*L
        else
          if L == 0
            error("Unable to get $key of LineElement: Integrated multipole is stored, but the element length L = 0")
          end
          return strength*Brho_ref/L
        end
      end
    end
  end
end

function set_BM_strength!(ele::LineElement, key::Symbol, value)
  if isnothing(ele.BMultipoleParams)
    ele.BMultipoleParams = BMultipoleParams() 
  end

  # Setting is painful, because we do not know what the type of
  # of the input must be (including L and Brho_ref potentially)
  # And, if it requires promotion of the BMultipoleParams struct,
  # ouchies
  b = ele.BMultipoleParams
  strength = calc_BM_internal_strength(ele, b, key, value)
  @noinline _set_BM_strength!(ele, b, key, strength)
  return value
end

function calc_BM_internal_strength(ele, b::BMultipoleParams, key, value)
  ___, order, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[key]
  
  if !(order in b.order) # First set
    return value
  else
    i = o2i(b,order)
    stored_normalized = b.normalized[i]
    stored_integrated = b.integrated[i]
    if stored_normalized == normalized
      if stored_integrated == integrated
        return value
      else
        L = ele.L
        if stored_integrated == false 
          # user setting integrated strength of non-integrated BMultipole
          if L == 0
            error("Unable to set $key of LineElement: Nonintegrated multipole is stored, but the element length L = 0")
          end
          return value/L
        else
          # user setting non-integrated strength of integrated BMultipole
          return value*L
        end
      end
    else
      Brho_ref = ele.Brho_ref
      if stored_integrated == integrated
        if stored_normalized == false
          # user setting normalized strength of unnormalized BMultipole
          return value*Brho_ref
        else
          # user setting unnormalized strength of normalized BMultipole
          return value/Brho_ref
        end
      else
        L = ele.L
        if stored_normalized == false
          if stored_integrated == false
            # user setting normalized, integrated strength of 
            # unnormalized, nonintegrated BMultipole
            if L == 0
              error("Unable to set $key of LineElement: Nonintegrated multipole is stored, but the element length L = 0")
            end
            return value*Brho_ref/L
          else
            # user setting normalized, nonintegrated strength of 
            # unnormalized, integrated BMultipole
            return value*Brho_ref*L
          end
        else
          if stored_integrated == false
            # user setting unnormalized, integrated strength of 
            # normalized, nonintegrated BMultipole
            if L == 0
              error("Unable to set $key of LineElement: Nonintegrated multipole is stored, but the element length L = 0")
            end
            return value/Brho_ref/L
          else
            # user setting unnormalized, nonintegrated strength of 
            # normalized, integrated BMultipole
            return value/Brho_ref*L
          end
        end
      end
    end
  end
end

function _set_BM_strength!(ele, b1::BMultipoleParams{S}, key, strength) where {S}
  normal, order, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[key]

  T = promote_type(S,typeof(strength))
  if T != S
    b = BMultipoleParams{T}(b1)
    ele.BMultipoleParams = b
  else
    b = b1
  end

  # If first set, this now defines normalized + integrated.
  if !(order in b.order)
    b = addord(b, order, normalized, integrated)
    ele.BMultipoleParams = b
  end

  if normal
    b.n[o2i(b,order)] = strength
  else
    b.s[o2i(b,order)] = strength
  end
  return 
end

function set_bend_angle!(ele::LineElement, ::Symbol, value)
  L = ele.L
  return @noinline _set_bend_angle!(ele, L, value)
end

function _set_bend_angle!(ele, L, value)
  # Angle = K0*L -> K0 = angle/L
  if L == 0
    error("Cannot set angle of LineElement with L = 0 (did you specify `angle` before specifying `L`?)")
  end
  Kn0 = value/L
  setproperty!(ele, :Kn0, Kn0)
  setproperty!(ele, :g, Kn0)
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
    ele.BMultipoleParams = BMultipoleParams()
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
          n *= ele.Brho_ref
          s *= ele.Brho_ref
        else
          n /= ele.Brho_ref
          s /= ele.Brho_ref
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
    error("Unable to get field_master: LineElement does not contain a BMultipoleParams")
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
    error("Unable to get integrated_master: LineElement does not contain a BMultipoleParams")
  end
  check = first(b.integrated)
  if !all(t->t==check, b.integrated)
    error("Unable to get integrated_master: BMultipoleParams contains at least one BMultipole with the integrated strength as the independent variable and at least one other BMultipole with the non-integrated strength as the independent variable")
  end
  return check
end

function get_cavity_frequency(ele::LineElement, key::Symbol)
  c = ele.RFParams
  if isnothing(c)
    return nothing
  end
  return @noinline _get_cavity_frequency(c, key)
end

function _get_cavity_frequency(c, key)
  harmon_master = CAVITY_FREQUENCY_MAP[key]
  if c.harmon_master == harmon_master
    return c.frequency
  else
    correctkey = CAVITY_FREQUENCY_INVERSE_MAP[c.harmon_master]
    error("Cannot calculate $key of RFParams since particle species is unknown at Beamlines level and harmon_master=$(c.harmon_master)")
  end
end

function set_cavity_frequency!(ele::LineElement, key::Symbol, value)
r = ele.RFParams
if isnothing(r)
  ele.RFParams = RFParams(harmon_master=key == :harmon ? true : false)
end

  c = ele.RFParams
  @noinline _set_cavity_frequency!(ele, c, key, value)
  return value
end

function _set_cavity_frequency!(ele, c1::RFParams{S}, key, value) where {S}
  harmon_master = CAVITY_FREQUENCY_MAP[key]
  
  T = promote_type(S, typeof(value))
  if T != S || c1.harmon_master != harmon_master
    # Create new RFParams with updated type and/or harmon_master
    c = RFParams(
      harmon_master = harmon_master,
      frequency     = T(value),
      voltage       = T(c1.voltage),
      phi0          = T(c1.phi0)
    )
    ele.pdict[RFParams] = c
  else
    # Can modify in place
    c1.frequency = T(value)
  end
  
  return
end

const VIRTUAL_GETTER_MAP = Dict{Symbol,Function}(
  [key => get_BM_strength for (key, value) in BMULTIPOLE_STRENGTH_MAP]...,

  :BM_independent => get_BM_independent,
  :field_master => get_field_master,
  :integrated_master => get_integrated_master,

  :rf_frequency => get_cavity_frequency,
  :harmonic_number => get_cavity_frequency,
)

const VIRTUAL_SETTER_MAP = Dict{Symbol,Function}(
  [key => set_BM_strength! for (key, value) in BMULTIPOLE_STRENGTH_MAP]...,

  :angle => set_bend_angle!,

  :BM_independent => set_BM_independent!,
  :field_master => set_field_master!,
  :integrated_master => set_integrated_master!,

  :rf_frequency => set_cavity_frequency!,
  :harmonic_number => set_cavity_frequency!,
)
