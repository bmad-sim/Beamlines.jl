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

function _get_BM_strength(ele, b, key)
  order, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[key]
  if isnothing(b) || !haskey(b.bdict, order)
    return nothing
  end
  bm = b.bdict[order]
  strength = bm.strength
  # Yes there is a simpler way to write the below but this 
  # way minimizes type instability.
  if bm.normalized == normalized
    if bm.integrated == integrated
      return strength
    else
      L = ele.L
      if bm.integrated == false 
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
      if bm.normalized == true
        error("Unable to get $key of LineElement: Normalized multipole is stored, but the element is not within a Beamline with a set Brho_ref")
      else
        error("Unable to get $key of LineElement: Unnormalized multipole is stored, but the element is not within a Beamline with a set Brho_ref")
      end
    end
    Brho_ref = ele.Brho_ref
    if bm.integrated == integrated
      if bm.normalized == false
        # user asking for normalized strength of unnormalized BMultipole
        return strength/Brho_ref
      else
        # user asking for unnormalized strength of normalized BMultipole
        return strength*Brho_ref
      end
    else
      L = ele.L
      if bm.normalized == false
        if bm.integrated == false
          return strength/Brho_ref*L
        else
          if L == 0
            error("Unable to get $key of LineElement: Integrated multipole is stored, but the element length L = 0")
          end
          return strength/Brho_ref/L
        end
      else
        if bm.integrated == false
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
  order, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[key]
  
  if !haskey(b.bdict, order) # first set
    return value
  else
    bm = b.bdict[order]
    if bm.normalized == normalized
      if bm.integrated == integrated
        return value
      else
        L = ele.L
        if bm.integrated == false 
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
      if bm.integrated == integrated
        if bm.normalized == false
          # user setting normalized strength of unnormalized BMultipole
          return value*Brho_ref
        else
          # user setting unnormalized strength of normalized BMultipole
          return value/Brho_ref
        end
      else
        L = ele.L
        if bm.normalized == false
          if bm.integrated == false
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
          if bm.integrated == false
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
  order, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[key]

  T = promote_type(S,typeof(strength))
  if T != S
    b = BMultipoleParams{T}(b1)
    ele.BMultipoleParams = b
  else
    b = b1
  end

  # If first set, this now defines normalized + integrated.
  if !haskey(b.bdict, order)
    b.bdict[order] = BMultipole{T}(strength, 0, order, normalized, integrated)
  else
    b.bdict[order].strength = strength
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
  K0 = value/L
  setproperty!(ele, :K0, K0)
  setproperty!(ele, :g, K0)
  return value
end

function get_BM_independent(ele::LineElement, ::Symbol)
  b = ele.BMultipoleParams
  return @noinline _get_BM_independent(b)
end

function _get_BM_independent(b)
  if isnothing(b)
    return nothing
  end
  v = Vector{Symbol}(undef, length(b.bdict))
  i = 1
  for (order, bm) in b.bdict  
    v[i] = BMULTIPOLE_STRENGTH_INVERSE_MAP[(order, bm.normalized, bm.integrated)]
    i += 1
  end
  return v
end

function set_BM_independent!(ele::LineElement, ::Symbol, value)
  eltype(value) == Symbol || error("Please provide a list/array/tuple of the multipole properties you want to set as independent variables.")
  b = ele.BMultipoleParams
  if isnothing(b)
    return value
  end
  for sym in value
    order, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[sym]
    if haskey(b.bdict, order)
      oldbm = b.bdict[order]
      oldstrength = oldbm.strength
      strength = oldstrength
      if oldbm.normalized != normalized
        if oldbm.normalized == true
          strength *= ele.Brho_ref
        else
          strength /= ele.Brho_ref
        end
      end

      if oldbm.integrated != integrated
        if oldbm.integrated == true
          ele.L != 0 || error("Unable to set change multipole order $order to have independent variable $sym: element length L = 0")
          strength /= ele.L
        else
          strength *= ele.L
        end
      end
      T = promote_type(typeof(oldstrength),typeof(strength))
      if T != typeof(oldstrength)
        b = BMultipoleParams{T}(b)
        ele.BMultipoleParams = b
      end
      newbm = BMultipole{T}(strength,oldbm.tilt,order,normalized,integrated)
      b.bdict[order] = newbm
    else
      b.bdict[order] = BMultipole{eltype(b)}(0,0,order,normalized,integrated)
    end
  end
  return value
end

# When field_master = true, the B fields are the independent variables
# If false, the normalized strengths are the independent variables
# so field_master = !normalized in my BMultipole structure
function set_field_master!(ele::LineElement, ::Symbol, value::Bool)
  BM_independent = _get_BM_independent(ele.BMultipoleParams)
  c = map(t->BMULTIPOLE_STRENGTH_MAP[t], BM_independent)
  newsyms = map(t->BMULTIPOLE_STRENGTH_INVERSE_MAP[(t[1],!value,t[3])], c)

  return set_BM_independent!(ele, :nothing, newsyms)
end

function set_integrated_master!(ele::LineElement, ::Symbol, value::Bool)
  BM_independent = _get_BM_independent(ele.BMultipoleParams)
  c = map(t->BMULTIPOLE_STRENGTH_MAP[t], BM_independent)
  newsyms = map(t->BMULTIPOLE_STRENGTH_INVERSE_MAP[(t[1],t[2],value)], c)

  return set_BM_independent!(ele, :nothing, newsyms)
end

function get_field_master(ele::LineElement, ::Symbol)
  b = ele.BMultipoleParams
  return @noinline _get_field_master(b)
end

function _get_field_master(b)
  if isnothing(b)
    return nothing
  end
  bms = values(b.bdict)
  check = first(bms).normalized
  if !all(t->t.normalized==check, bms)
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
    return nothing
  end
  bms = values(b.bdict)
  check = first(bms).integrated
  if !all(t->t.integrated==check, bms)
    error("Unable to get integrated_master: BMultipoleParams contains at least one BMultipole with the integrated strength as the independent variable and at least one other BMultipole with the non-integrated strength as the independent variable")
  end
  return check
end

const VIRTUAL_GETTER_MAP = Dict{Symbol,Function}(
  :Bs   => get_BM_strength,
  :B0   => get_BM_strength,
  :B1   => get_BM_strength,
  :B2   => get_BM_strength,
  :B3   => get_BM_strength,
  :B4   => get_BM_strength,
  :B5   => get_BM_strength,
  :B6   => get_BM_strength,
  :B7   => get_BM_strength,
  :B8   => get_BM_strength,
  :B9   => get_BM_strength,
  :B10  => get_BM_strength,
  :B11  => get_BM_strength,
  :B12  => get_BM_strength,
  :B13  => get_BM_strength,
  :B14  => get_BM_strength,
  :B15  => get_BM_strength,
  :B16  => get_BM_strength,
  :B17  => get_BM_strength,
  :B18  => get_BM_strength,
  :B19  => get_BM_strength,
  :B20  => get_BM_strength,
  :B21  => get_BM_strength,
  :Ks   => get_BM_strength,
  :K0   => get_BM_strength,
  :K1   => get_BM_strength,
  :K2   => get_BM_strength,
  :K3   => get_BM_strength,
  :K4   => get_BM_strength,
  :K5   => get_BM_strength,
  :K6   => get_BM_strength,
  :K7   => get_BM_strength,
  :K8   => get_BM_strength,
  :K9   => get_BM_strength,
  :K10  => get_BM_strength,
  :K11  => get_BM_strength,
  :K12  => get_BM_strength,
  :K13  => get_BM_strength,
  :K14  => get_BM_strength,
  :K15  => get_BM_strength,
  :K16  => get_BM_strength,
  :K17  => get_BM_strength,
  :K18  => get_BM_strength,
  :K19  => get_BM_strength,
  :K20  => get_BM_strength,
  :K21  => get_BM_strength,
  :BsL  => get_BM_strength,
  :B0L  => get_BM_strength,
  :B1L  => get_BM_strength,
  :B2L  => get_BM_strength,
  :B3L  => get_BM_strength,
  :B4L  => get_BM_strength,
  :B5L  => get_BM_strength,
  :B6L  => get_BM_strength,
  :B7L  => get_BM_strength,
  :B8L  => get_BM_strength,
  :B9L  => get_BM_strength,
  :B10L => get_BM_strength,
  :B11L => get_BM_strength,
  :B12L => get_BM_strength,
  :B13L => get_BM_strength,
  :B14L => get_BM_strength,
  :B15L => get_BM_strength,
  :B16L => get_BM_strength,
  :B17L => get_BM_strength,
  :B18L => get_BM_strength,
  :B19L => get_BM_strength,
  :B20L => get_BM_strength,
  :B21L => get_BM_strength,
  :KsL  => get_BM_strength,
  :K0L  => get_BM_strength,
  :K1L  => get_BM_strength,
  :K2L  => get_BM_strength,
  :K3L  => get_BM_strength,
  :K4L  => get_BM_strength,
  :K5L  => get_BM_strength,
  :K6L  => get_BM_strength,
  :K7L  => get_BM_strength,
  :K8L  => get_BM_strength,
  :K9L  => get_BM_strength,
  :K10L => get_BM_strength,
  :K11L => get_BM_strength,
  :K12L => get_BM_strength,
  :K13L => get_BM_strength,
  :K14L => get_BM_strength,
  :K15L => get_BM_strength,
  :K16L => get_BM_strength,
  :K17L => get_BM_strength,
  :K18L => get_BM_strength,
  :K19L => get_BM_strength,
  :K20L => get_BM_strength,
  :K21L => get_BM_strength,

  :BM_independent => get_BM_independent,
  :field_master => get_field_master,
  :integrated_master => get_integrated_master,

  :voltage => get_voltage,
)

const VIRTUAL_SETTER_MAP = Dict{Symbol,Function}(
  :Bs   => set_BM_strength!,
  :B0   => set_BM_strength!,
  :B1   => set_BM_strength!,
  :B2   => set_BM_strength!,
  :B3   => set_BM_strength!,
  :B4   => set_BM_strength!,
  :B5   => set_BM_strength!,
  :B6   => set_BM_strength!,
  :B7   => set_BM_strength!,
  :B8   => set_BM_strength!,
  :B9   => set_BM_strength!,
  :B10  => set_BM_strength!,
  :B11  => set_BM_strength!,
  :B12  => set_BM_strength!,
  :B13  => set_BM_strength!,
  :B14  => set_BM_strength!,
  :B15  => set_BM_strength!,
  :B16  => set_BM_strength!,
  :B17  => set_BM_strength!,
  :B18  => set_BM_strength!,
  :B19  => set_BM_strength!,
  :B20  => set_BM_strength!,
  :B21  => set_BM_strength!,
  :Ks   => set_BM_strength!,
  :K0   => set_BM_strength!,
  :K1   => set_BM_strength!,
  :K2   => set_BM_strength!,
  :K3   => set_BM_strength!,
  :K4   => set_BM_strength!,
  :K5   => set_BM_strength!,
  :K6   => set_BM_strength!,
  :K7   => set_BM_strength!,
  :K8   => set_BM_strength!,
  :K9   => set_BM_strength!,
  :K10  => set_BM_strength!,
  :K11  => set_BM_strength!,
  :K12  => set_BM_strength!,
  :K13  => set_BM_strength!,
  :K14  => set_BM_strength!,
  :K15  => set_BM_strength!,
  :K16  => set_BM_strength!,
  :K17  => set_BM_strength!,
  :K18  => set_BM_strength!,
  :K19  => set_BM_strength!,
  :K20  => set_BM_strength!,
  :K21  => set_BM_strength!,
  :BsL  => set_BM_strength!,
  :B0L  => set_BM_strength!,
  :B1L  => set_BM_strength!,
  :B2L  => set_BM_strength!,
  :B3L  => set_BM_strength!,
  :B4L  => set_BM_strength!,
  :B5L  => set_BM_strength!,
  :B6L  => set_BM_strength!,
  :B7L  => set_BM_strength!,
  :B8L  => set_BM_strength!,
  :B9L  => set_BM_strength!,
  :B10L => set_BM_strength!,
  :B11L => set_BM_strength!,
  :B12L => set_BM_strength!,
  :B13L => set_BM_strength!,
  :B14L => set_BM_strength!,
  :B15L => set_BM_strength!,
  :B16L => set_BM_strength!,
  :B17L => set_BM_strength!,
  :B18L => set_BM_strength!,
  :B19L => set_BM_strength!,
  :B20L => set_BM_strength!,
  :B21L => set_BM_strength!,
  :KsL  => set_BM_strength!,
  :K0L  => set_BM_strength!,
  :K1L  => set_BM_strength!,
  :K2L  => set_BM_strength!,
  :K3L  => set_BM_strength!,
  :K4L  => set_BM_strength!,
  :K5L  => set_BM_strength!,
  :K6L  => set_BM_strength!,
  :K7L  => set_BM_strength!,
  :K8L  => set_BM_strength!,
  :K9L  => set_BM_strength!,
  :K10L => set_BM_strength!,
  :K11L => set_BM_strength!,
  :K12L => set_BM_strength!,
  :K13L => set_BM_strength!,
  :K14L => set_BM_strength!,
  :K15L => set_BM_strength!,
  :K16L => set_BM_strength!,
  :K17L => set_BM_strength!,
  :K18L => set_BM_strength!,
  :K19L => set_BM_strength!,
  :K20L => set_BM_strength!,
  :K21L => set_BM_strength!,

  :angle => set_bend_angle!,

  :BM_independent => set_BM_independent!,
  :field_master => set_field_master!,
  :integrated_master => set_integrated_master!,

  :voltage => set_voltage!
)
