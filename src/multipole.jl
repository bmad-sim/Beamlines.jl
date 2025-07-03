@kwdef struct BMultipoleParams{T,N} <: AbstractParams
  n::SizedVector{N,T}         = SizedVector{0,Float32}()
  s::SizedVector{N,T}         = SizedVector{0,Float32}()
  tilt::SizedVector{N,T}      = SizedVector{0,Float32}()
  order::SVector{N,Int}       = SVector{0,Float32}()
  normalized::SVector{N,Bool} = SVector{0,Float32}()
  integrated::SVector{N,Bool} = SVector{0,Float32}()
  function BMultipoleParams(n, s, tilt, order, normalized, integrated)
    if !issorted(order)
      error("Something went very wrong: BMultipoleParams not sorted by order. Please submit an issue to Beamlines.jl")
    end
    return new{promote_type(eltype(n),eltype(s), eltype(tilt)),length(n)}(n, s, tilt, order, normalized, integrated)
  end
end

o2i(b::BMultipoleParams, ord::Int) = findfirst(t->t==ord, b.order)

function BMultipoleParams{T}(b::BMultipoleParams) where {T}
  n = T.(b.n)
  s = T.(b.s)
  tilt = T.(b.tilt)
  return BMultipoleParams(n,s,tilt,b.order,b.normalized,b.integrated)
end

# Allow access to tilts, tilt0, etc. at this level. This WILL be used 
# at the element level!
# Technically we could allow access to e.g. K1 (if normalized nonintegrated) 
# at this level, like we did up to v0.3, but that is a pain AND it is not 
# used at the element level, so I will leave it out for now unless there 
# is a burning desire to have it.
function Base.hasproperty(b::BMultipoleParams, key::Symbol)
  if key in fieldnames(BMultipoleParams)
    return true
  elseif haskey(BMULTIPOLE_TILT_MAP, key) && BMULTIPOLE_TILT_MAP[key] in b.order
    return true
  else
    return false
  end
end

function Base.getproperty(b::BMultipoleParams{T}, key::Symbol) where {T}
  if key in fieldnames(BMultipoleParams)
    return getfield(b, key)
  elseif haskey(BMULTIPOLE_TILT_MAP, key)
    ord = BMULTIPOLE_TILT_MAP[key]
    if ord in b.order
      return deval(b.tilt[o2i(b,ord)])
    else
      error("Unable to get $key: BMultipoleParams $b does not have a multipole of order $ord")
    end
  end
  error("BMultipoleParams $b does not have property $key")
end

function Base.setproperty!(b::BMultipoleParams{T}, key::Symbol, value) where {T}
  if key in fieldnames(BMultipoleParams)
    return setfield!(b, key, value) # Will error because immutable struct
  elseif haskey(BMULTIPOLE_TILT_MAP, key)
    ord = BMULTIPOLE_TILT_MAP[key]
    if ord in b.order
      return b.tilt[o2i(b,ord)] = value
    else
      error("Unable to set $key: BMultipoleParams $b does not have a multipole of order $ord")
    end
  end
  error("BMultipoleParams $b does not have property $key")
end

Base.eltype(::BMultipoleParams{T}) where {T} = T
Base.eltype(::Type{BMultipoleParams{T}}) where {T} = T
Base.length(b::BMultipoleParams{T,N}) where {T,N} = N

# Replace is ONLY here for tilt, which is accessible at this level
function replace(b1::BMultipoleParams{T0,N0}, key::Symbol, value) where {T0,N0} 
  if !haskey(BMULTIPOLE_TILT_MAP, key)
    error("Unreachable! `replace` with BMultipoleParams should only be called when the tilt of a bmultipole is being set such that the number type must be promoted. Please submit an issue to Beamlines.jl")
  end

  # tilt is first value of this multipole being set
  # This is kind of weird, but we can allow it.
  # default normalized to true, and integrated to true
  ord = BMULTIPOLE_TILT_MAP[key]
  if hasproperty(b1, key)
    # NOT adding new multipole
    i = o2i(b1,ord)
    normalized = b1.normalized[i]
    integrated = b1.integrated[i]
    T = promote_type(T0,typeof(value))
    b = BMultipoleParams{T}(b1)
    return setproperty!(b, key, value)
  else
    # adding new multipole
    T = promote_type(T0,typeof(value))
    b = addord(BMultipoleParams{T}(b1), ord)
    i = o2i(b, ord)
    b.tilt[i] = value
    return b
  end
end

function addord(b1::BMultipoleParams{T,N0}, ord, nrm=true, intg=true) where {T,N0}
  if length(b1.order) == 0
    i = 1
  elseif ord in b1.order
    error("Multipole order $ord already in BMultipoleParams $b1")
  else
    i = findfirst(t->t>ord, b1.order)
    if isnothing(i)
      i = length(b1.order) + 1
    end
  end
  n = StaticArrays.insert(b1.n, i, T(0))
  s = StaticArrays.insert(b1.s, i, T(0))
  tilt = StaticArrays.insert(b1.tilt, i, T(0))
  order = StaticArrays.insert(b1.order, i, ord)
  normalized = StaticArrays.insert(b1.normalized, i, nrm)
  integrated = StaticArrays.insert(b1.integrated, i, intg)
  return BMultipoleParams(n, s, tilt, order, normalized, integrated)
end


function Base.isapprox(a::BMultipoleParams, b::BMultipoleParams)
  return a.n          ≈ b.n &&
         a.s          ≈ b.s &&
         a.order      ≈ b.order &&
         a.normalized ≈ b.normalized &&
         a.integrated ≈ b.integrated
end


# Solenoid only stores strength in n
# First bool is if normal (true) or skew (false)
# then order, normalized, integrated
const BMULTIPOLE_STRENGTH_MAP = Dict{Symbol,Tuple{Bool,Int,Bool,Bool}}(
  :Bs   => (true, 0,  false, false),
  :Bn0  => (true, 1 , false, false),
  :Bn1  => (true, 2 , false, false),
  :Bn2  => (true, 3 , false, false),
  :Bn3  => (true, 4 , false, false),
  :Bn4  => (true, 5 , false, false),
  :Bn5  => (true, 6 , false, false),
  :Bn6  => (true, 7 , false, false),
  :Bn7  => (true, 8 , false, false),
  :Bn8  => (true, 9 , false, false),
  :Bn9  => (true, 10, false, false),
  :Bn10 => (true, 11, false, false),
  :Bn11 => (true, 12, false, false),
  :Bn12 => (true, 13, false, false),
  :Bn13 => (true, 14, false, false),
  :Bn14 => (true, 15, false, false),
  :Bn15 => (true, 16, false, false),
  :Bn16 => (true, 17, false, false),
  :Bn17 => (true, 18, false, false),
  :Bn18 => (true, 19, false, false),
  :Bn19 => (true, 20, false, false),
  :Bn20 => (true, 21, false, false),
  :Bn21 => (true, 22, false, false),

  :Ks   => (true, 0,  true, false),
  :Kn0  => (true, 1 , true, false),
  :Kn1  => (true, 2 , true, false),
  :Kn2  => (true, 3 , true, false),
  :Kn3  => (true, 4 , true, false),
  :Kn4  => (true, 5 , true, false),
  :Kn5  => (true, 6 , true, false),
  :Kn6  => (true, 7 , true, false),
  :Kn7  => (true, 8 , true, false),
  :Kn8  => (true, 9 , true, false),
  :Kn9  => (true, 10, true, false),
  :Kn10 => (true, 11, true, false),
  :Kn11 => (true, 12, true, false),
  :Kn12 => (true, 13, true, false),
  :Kn13 => (true, 14, true, false),
  :Kn14 => (true, 15, true, false),
  :Kn15 => (true, 16, true, false),
  :Kn16 => (true, 17, true, false),
  :Kn17 => (true, 18, true, false),
  :Kn18 => (true, 19, true, false),
  :Kn19 => (true, 20, true, false),
  :Kn20 => (true, 21, true, false),
  :Kn21 => (true, 22, true, false),

  :BsL   => (true, 0,  false, true),
  :Bn0L  => (true, 1 , false, true),
  :Bn1L  => (true, 2 , false, true),
  :Bn2L  => (true, 3 , false, true),
  :Bn3L  => (true, 4 , false, true),
  :Bn4L  => (true, 5 , false, true),
  :Bn5L  => (true, 6 , false, true),
  :Bn6L  => (true, 7 , false, true),
  :Bn7L  => (true, 8 , false, true),
  :Bn8L  => (true, 9 , false, true),
  :Bn9L  => (true, 10, false, true),
  :Bn10L => (true, 11, false, true),
  :Bn11L => (true, 12, false, true),
  :Bn12L => (true, 13, false, true),
  :Bn13L => (true, 14, false, true),
  :Bn14L => (true, 15, false, true),
  :Bn15L => (true, 16, false, true),
  :Bn16L => (true, 17, false, true),
  :Bn17L => (true, 18, false, true),
  :Bn18L => (true, 19, false, true),
  :Bn19L => (true, 20, false, true),
  :Bn20L => (true, 21, false, true),
  :Bn21L => (true, 22, false, true),

  :KsL   => (true, 0,  true, true),
  :Kn0L  => (true, 1 , true, true),
  :Kn1L  => (true, 2 , true, true),
  :Kn2L  => (true, 3 , true, true),
  :Kn3L  => (true, 4 , true, true),
  :Kn4L  => (true, 5 , true, true),
  :Kn5L  => (true, 6 , true, true),
  :Kn6L  => (true, 7 , true, true),
  :Kn7L  => (true, 8 , true, true),
  :Kn8L  => (true, 9 , true, true),
  :Kn9L  => (true, 10, true, true),
  :Kn10L => (true, 11, true, true),
  :Kn11L => (true, 12, true, true),
  :Kn12L => (true, 13, true, true),
  :Kn13L => (true, 14, true, true),
  :Kn14L => (true, 15, true, true),
  :Kn15L => (true, 16, true, true),
  :Kn16L => (true, 17, true, true),
  :Kn17L => (true, 18, true, true),
  :Kn18L => (true, 19, true, true),
  :Kn19L => (true, 20, true, true),
  :Kn20L => (true, 21, true, true),
  :Kn21L => (true, 22, true, true),

  :Bs0  => (false, 1 , false, false),
  :Bs1  => (false, 2 , false, false),
  :Bs2  => (false, 3 , false, false),
  :Bs3  => (false, 4 , false, false),
  :Bs4  => (false, 5 , false, false),
  :Bs5  => (false, 6 , false, false),
  :Bs6  => (false, 7 , false, false),
  :Bs7  => (false, 8 , false, false),
  :Bs8  => (false, 9 , false, false),
  :Bs9  => (false, 10, false, false),
  :Bs10 => (false, 11, false, false),
  :Bs11 => (false, 12, false, false),
  :Bs12 => (false, 13, false, false),
  :Bs13 => (false, 14, false, false),
  :Bs14 => (false, 15, false, false),
  :Bs15 => (false, 16, false, false),
  :Bs16 => (false, 17, false, false),
  :Bs17 => (false, 18, false, false),
  :Bs18 => (false, 19, false, false),
  :Bs19 => (false, 20, false, false),
  :Bs20 => (false, 21, false, false),
  :Bs21 => (false, 22, false, false),

  :Ks0  => (false, 1 , true, false),
  :Ks1  => (false, 2 , true, false),
  :Ks2  => (false, 3 , true, false),
  :Ks3  => (false, 4 , true, false),
  :Ks4  => (false, 5 , true, false),
  :Ks5  => (false, 6 , true, false),
  :Ks6  => (false, 7 , true, false),
  :Ks7  => (false, 8 , true, false),
  :Ks8  => (false, 9 , true, false),
  :Ks9  => (false, 10, true, false),
  :Ks10 => (false, 11, true, false),
  :Ks11 => (false, 12, true, false),
  :Ks12 => (false, 13, true, false),
  :Ks13 => (false, 14, true, false),
  :Ks14 => (false, 15, true, false),
  :Ks15 => (false, 16, true, false),
  :Ks16 => (false, 17, true, false),
  :Ks17 => (false, 18, true, false),
  :Ks18 => (false, 19, true, false),
  :Ks19 => (false, 20, true, false),
  :Ks20 => (false, 21, true, false),
  :Ks21 => (false, 22, true, false),

  :Bs0L  => (false, 1 , false, true),
  :Bs1L  => (false, 2 , false, true),
  :Bs2L  => (false, 3 , false, true),
  :Bs3L  => (false, 4 , false, true),
  :Bs4L  => (false, 5 , false, true),
  :Bs5L  => (false, 6 , false, true),
  :Bs6L  => (false, 7 , false, true),
  :Bs7L  => (false, 8 , false, true),
  :Bs8L  => (false, 9 , false, true),
  :Bs9L  => (false, 10, false, true),
  :Bs10L => (false, 11, false, true),
  :Bs11L => (false, 12, false, true),
  :Bs12L => (false, 13, false, true),
  :Bs13L => (false, 14, false, true),
  :Bs14L => (false, 15, false, true),
  :Bs15L => (false, 16, false, true),
  :Bs16L => (false, 17, false, true),
  :Bs17L => (false, 18, false, true),
  :Bs18L => (false, 19, false, true),
  :Bs19L => (false, 20, false, true),
  :Bs20L => (false, 21, false, true),
  :Bs21L => (false, 22, false, true),

  :Ks0L  => (false, 1 , true, true),
  :Ks1L  => (false, 2 , true, true),
  :Ks2L  => (false, 3 , true, true),
  :Ks3L  => (false, 4 , true, true),
  :Ks4L  => (false, 5 , true, true),
  :Ks5L  => (false, 6 , true, true),
  :Ks6L  => (false, 7 , true, true),
  :Ks7L  => (false, 8 , true, true),
  :Ks8L  => (false, 9 , true, true),
  :Ks9L  => (false, 10, true, true),
  :Ks10L => (false, 11, true, true),
  :Ks11L => (false, 12, true, true),
  :Ks12L => (false, 13, true, true),
  :Ks13L => (false, 14, true, true),
  :Ks14L => (false, 15, true, true),
  :Ks15L => (false, 16, true, true),
  :Ks16L => (false, 17, true, true),
  :Ks17L => (false, 18, true, true),
  :Ks18L => (false, 19, true, true),
  :Ks19L => (false, 20, true, true),
  :Ks20L => (false, 21, true, true),
  :Ks21L => (false, 22, true, true),
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
