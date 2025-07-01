mutable struct BMultipole{T<:Number}
  strength::T # field strength in T/m^order, normalized by Brho_ref if normalized == true
  tilt::T # direction (in xy plane) of directional-derivative defining strength
  const order::Int # Cyclic group order=0 solenoid, order=1 dipole, order=2 Quadrupole, ... 
  const normalized::Bool # if quantities are normalized
  const integrated::Bool # if quantities are integrated
  function BMultipole(args...)
    return new{promote_type(typeof(args[1]),typeof(args[2]))}(args...)
  end
  BMultipole{T}(args...) where {T} = new{T}(args...)
end

Base.eltype(::BMultipole{T}) where {T} = T
Base.eltype(::Type{BMultipole{T}}) where {T} = T

function Base.isapprox(a::BMultipole, b::BMultipole)
  return a.strength   ≈ b.strength &&
         a.tilt       ≈ b.tilt &&
         a.order      == b.order &&
         a.normalized == b.normalized &&
         a.integrated == b.integrated

end

function Base.hasproperty(bm::BMultipole, key::Symbol)
  if key in fieldnames(BMultipole)
    return true
  elseif haskey(BMULTIPOLE_STRENGTH_MAP, key)
    order, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[key]
    return order == bm.order  && normalized == bm.normalized && integrated == bm.integrated
  elseif haskey(BMULTIPOLE_TILT_MAP, key)
    return true
  else
    return false
  end
end

function Base.getproperty(bm::BMultipole, key::Symbol)
  if key in fieldnames(BMultipole)
    return deval(getfield(bm, key))
  elseif haskey(BMULTIPOLE_STRENGTH_MAP, key)
    order, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[key]
    if order == bm.order  && normalized == bm.normalized && integrated == bm.integrated
      return deval(bm.strength)
    else
      correctkey = BMULTIPOLE_STRENGTH_INVERSE_MAP[(bm.order,bm.normalized,bm.integrated)]
      error("BMultipole does not have property $key: did you mean $correctkey?")
    end
  elseif haskey(BMULTIPOLE_TILT_MAP, key)
    return deval(bm.tilt)
  end
  error("BMultipole $bm does not have property $key")
end

function Base.setproperty!(bm::BMultipole{T}, key::Symbol, value) where {T}
  if key in (:strength,:tilt) 
    return setfield!(bm, key, T(value))
  elseif key in fieldnames(BMultipole)
    return setfield!(bm, key, value)
  elseif haskey(BMULTIPOLE_STRENGTH_MAP, key)
    order, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[key]
    if order == bm.order  && normalized == bm.normalized && integrated == bm.integrated
      return setfield!(bm, :strength, T(value))
    else
      error("BMultipole $bm does not have property $key")
    end
  elseif haskey(BMULTIPOLE_TILT_MAP, key)
    return setfield!(bm, :tilt, T(value))
  end
  error("BMultipole $bm does not have property $key")
end

const BMULTIPOLE_STRENGTH_MAP = Dict{Symbol,Tuple{Int,Bool,Bool}}(
  :Bs  => (0,  false, false),
  :B0  => (1 , false, false),
  :B1  => (2 , false, false),
  :B2  => (3 , false, false),
  :B3  => (4 , false, false),
  :B4  => (5 , false, false),
  :B5  => (6 , false, false),
  :B6  => (7 , false, false),
  :B7  => (8 , false, false),
  :B8  => (9 , false, false),
  :B9  => (10, false, false),
  :B10 => (11, false, false),
  :B11 => (12, false, false),
  :B12 => (13, false, false),
  :B13 => (14, false, false),
  :B14 => (15, false, false),
  :B15 => (16, false, false),
  :B16 => (17, false, false),
  :B17 => (18, false, false),
  :B18 => (19, false, false),
  :B19 => (20, false, false),
  :B20 => (21, false, false),
  :B21 => (22, false, false),

  :Ks  => (0,  true, false),
  :K0  => (1 , true, false),
  :K1  => (2 , true, false),
  :K2  => (3 , true, false),
  :K3  => (4 , true, false),
  :K4  => (5 , true, false),
  :K5  => (6 , true, false),
  :K6  => (7 , true, false),
  :K7  => (8 , true, false),
  :K8  => (9 , true, false),
  :K9  => (10, true, false),
  :K10 => (11, true, false),
  :K11 => (12, true, false),
  :K12 => (13, true, false),
  :K13 => (14, true, false),
  :K14 => (15, true, false),
  :K15 => (16, true, false),
  :K16 => (17, true, false),
  :K17 => (18, true, false),
  :K18 => (19, true, false),
  :K19 => (20, true, false),
  :K20 => (21, true, false),
  :K21 => (22, true, false),

  :BsL  => (0,  false, true),
  :B0L  => (1 , false, true),
  :B1L  => (2 , false, true),
  :B2L  => (3 , false, true),
  :B3L  => (4 , false, true),
  :B4L  => (5 , false, true),
  :B5L  => (6 , false, true),
  :B6L  => (7 , false, true),
  :B7L  => (8 , false, true),
  :B8L  => (9 , false, true),
  :B9L  => (10, false, true),
  :B10L => (11, false, true),
  :B11L => (12, false, true),
  :B12L => (13, false, true),
  :B13L => (14, false, true),
  :B14L => (15, false, true),
  :B15L => (16, false, true),
  :B16L => (17, false, true),
  :B17L => (18, false, true),
  :B18L => (19, false, true),
  :B19L => (20, false, true),
  :B20L => (21, false, true),
  :B21L => (22, false, true),

  :KsL  => (0,  true, true),
  :K0L  => (1 , true, true),
  :K1L  => (2 , true, true),
  :K2L  => (3 , true, true),
  :K3L  => (4 , true, true),
  :K4L  => (5 , true, true),
  :K5L  => (6 , true, true),
  :K6L  => (7 , true, true),
  :K7L  => (8 , true, true),
  :K8L  => (9 , true, true),
  :K9L  => (10, true, true),
  :K10L => (11, true, true),
  :K11L => (12, true, true),
  :K12L => (13, true, true),
  :K13L => (14, true, true),
  :K14L => (15, true, true),
  :K15L => (16, true, true),
  :K16L => (17, true, true),
  :K17L => (18, true, true),
  :K18L => (19, true, true),
  :K19L => (20, true, true),
  :K20L => (21, true, true),
  :K21L => (22, true, true),
)

const BMULTIPOLE_STRENGTH_INVERSE_MAP = Dict(value => key for (key, value) in BMULTIPOLE_STRENGTH_MAP)

const BMULTIPOLE_TILT_MAP = Dict{Symbol,Int}(
  :tilts =>   0, 
  :tilt0 =>   1,
  :tilt1 =>   2,
  :tilt2 =>   3,
  :tilt3 =>   4,
  :tilt4 =>   5,
  :tilt5 =>   6,
  :tilt6 =>   7,
  :tilt7 =>   8,
  :tilt8 =>   9,
  :tilt9 =>  10,
  :tilt10 => 11,
  :tilt11 => 12,
  :tilt12 => 13,
  :tilt13 => 14,
  :tilt14 => 15,
  :tilt15 => 16,
  :tilt16 => 17,
  :tilt17 => 18,
  :tilt18 => 19,
  :tilt19 => 20,
  :tilt20 => 21, 
  :tilt21 => 22, 
)

# Key == order
# Note we require all multipoles to have same number type
const BMultipoleDict{T} = Dict{Int, BMultipole{T}} where {T<:Number}

# Note the repetitive code - this means we can likely coalesce ParamDict and BMultipoleDict 
# Into some single new restricted Dict type.
function Base.setindex!(h::BMultipoleDict, v::BMultipole, key::Int)
  v.order == key || error("Key $key does not match multipole order $(v.order)")
  # The following is copy-pasted directly from Base dict.jl ==========
  index, sh = Base.ht_keyindex2_shorthash!(h, key)

  if index > 0
      h.age += 1
      @inbounds h.keys[index] = key
      @inbounds h.vals[index] = v
  else
      @inbounds Base._setindex!(h, v, key, -index, sh)
  end

  return h
  # ==================================================================
end

function Base.isapprox(l::BMultipoleDict, r::BMultipoleDict)
  L_l = length(l)
  L_r = length(r)
  L_l != L_r && return false
  anymissing = false
  for pair in l
      isin = in(pair, r, ≈)
      if ismissing(isin)
          anymissing = true
      elseif !isin
          return false
      end
  end
  return anymissing ? missing : true
end

@kwdef struct BMultipoleParams{T<:Number} <: AbstractParams
  bdict::BMultipoleDict{T} = BMultipoleDict{Float32}() # multipole coefficients
  BMultipoleParams(bdict::BMultipoleDict{T}) where {T} = new{T}(bdict)
  function BMultipoleParams{T}(b::BMultipoleParams) where {T} 
    bdict = BMultipoleDict{T}()
    for (order, bm) in b.bdict
      bdict[order] = BMultipole{T}(bm.strength, bm.tilt, order, bm.normalized, bm.integrated)
    end
    return new{T}(bdict)
  end
end

Base.eltype(::BMultipoleParams{T}) where {T} = T
Base.eltype(::Type{BMultipoleParams{T}}) where {T} = T

Base.length(b::BMultipoleParams) = length(b.bdict)

Base.isapprox(a::BMultipoleParams, b::BMultipoleParams) = a.bdict ≈ b.bdict

function Base.hasproperty(b::BMultipoleParams, key::Symbol)
  if key in fieldnames(BMultipoleParams)
    return true
  end
  
  if haskey(BMULTIPOLE_STRENGTH_MAP, key)
    order = first(BMULTIPOLE_STRENGTH_MAP[key])
  elseif haskey(BMULTIPOLE_TILT_MAP, key)
    order = first(BMULTIPOLE_TILT_MAP[key])
  else
    return false
  end

  return haskey(b.bdict, order) && hasproperty(b.bdict[order], key)
end

function Base.getproperty(b::BMultipoleParams, key::Symbol)
  if key in fieldnames(BMultipoleParams)
    return getfield(b, key)
  end

  if haskey(BMULTIPOLE_STRENGTH_MAP, key)
    order = first(BMULTIPOLE_STRENGTH_MAP[key])
  elseif haskey(BMULTIPOLE_TILT_MAP, key)
    order = first(BMULTIPOLE_TILT_MAP[key])
  else
    error("BMultipoleParams does not have property $key")
  end

  if haskey(b.bdict, order)
    return getproperty(b.bdict[order], key)
  else
    error("BMultipoleParams does not have property $key")
  end
end

function Base.setproperty!(b::BMultipoleParams{T}, key::Symbol, value) where {T}
  if key in fieldnames(BMultipoleParams)
    return setfield!(b, key, value) # This will error because immutable
  end

  if haskey(BMULTIPOLE_STRENGTH_MAP, key)
    order, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[key]
  elseif haskey(BMULTIPOLE_TILT_MAP, key)
    order = BMULTIPOLE_TILT_MAP[key]
    normalized = true
    integrated = false
  else
    error("BMultipoleParams does not have property $key")
  end

  if !haskey(b.bdict, order)
    b.bdict[order] = BMultipole{T}(0, 0, order, normalized, integrated)
  end
  return setproperty!(b.bdict[order], key, value)
end

function replace(b1::BMultipoleParams{S}, key::Symbol, value) where {S} 
  T = promote_type(S,typeof(value))
  b = BMultipoleParams{T}(b1)

  if haskey(BMULTIPOLE_STRENGTH_MAP, key)
    ord, normalized, integrated = BMULTIPOLE_STRENGTH_MAP[key]
  elseif haskey(BMULTIPOLE_TILT_MAP, key)
    # tilt is first value of this multipole being set
    # This is kind of weird, but we can allow it.
    # default normalized to false, and integrated to true 
    ord = BMULTIPOLE_TILT_MAP[key]
    normalized = false
    integrated = true
  else
    error("Unreachable! Replace should only be called when the strength or tilt of a BMultipole is being set such that the number type must be promoted. Please submit an issue to Beamlines.jl")
  end

  if !haskey(b.bdict, ord)
    # First set of this value determines if normalized and/or integrated
    b.bdict[ord] = BMultipole{T}(0, 0, ord, normalized, integrated)
  end
  setproperty!(b.bdict[ord], key, value)
  return b
end