@kwdef struct EMultipoleParams{T,N} <: AbstractParams
  n::SizedVector{N,T,Vector{T}}     = SizedVector{0,Float32,Vector{Float32}}()   # Normal component
  s::SizedVector{N,T,Vector{T}}     = SizedVector{0,Float32,Vector{Float32}}()   # Skew
  etilt::SizedVector{N,T,Vector{T}} = SizedVector{0,Float32,Vector{Float32}}()
  order::SVector{N,Int}             = SVector{0,Int}()
  integrated::SVector{N,Bool}       = SVector{0,Bool}()
  function EMultipoleParams(n, s, etilt, order, integrated)
    if !issorted(order)
      error("Something went very wrong: EMultipoleParams not sorted by order. Please submit an issue to Beamlines.jl")
    end
    T = promote_type(eltype(n),eltype(s), eltype(etilt))
    return new{T,length(n)}(
      convert(Vector{T}, n),
      convert(Vector{T}, s),
      convert(Vector{T}, etilt), 
      order, integrated
    )
  end
end

PROPS(::Type{EMultipoleParams}) = OrderedDict{String,String}(
  "EnX"    => "Order X normal strength in [V/m^(X+1)] (nonintegrated)",
  "EsX"    => "Order X skew strength   in [V/m^(X+1)] (nonintegrated)",
  "EnXL"   => "Order X normal strength in [V/m^X] (integrated)",
  "EsXL"   => "Order X skew strength in [V/m^X] (integrated)",
  "etiltX" => "Tilt to only order X multipole",
)


"""
    EMultipoleParams

Defines electric (E) multipoles for an element. 

A given multipole can be set using any of the following:
$(PROPSDOC(EMultipoleParams))

!!! note
    The last *set* for a given multipole defines if both the normal and skew strengths 
    for a given multipole order are integrated. E.g.
    ```julia
    ele = LineElement(En1=0.1, Es1=0.2, L=0.4) # Order 1 is nonintegrated
    ele.En1L = 0.3         # Order 1 independent variables are now integrated
    ele.Es1L == 0.2*0.4    # true
    ```
"""
EMultipoleParams

function Base.show(io::IO, b::EMultipoleParams)
  println(io, EMultipoleParams)
  width = length(" En21L")
  for bm in b
    n = bm.n
    s = bm.s
    etilt = bm.etilt
    if n != 0
      sym = EMULTIPOLE_STRENGTH_INVERSE_MAP[(true, bm.order, bm.integrated)]
      println(io, rpad((" "*String(sym)), width), " = ", param_repr(n))
    end
    if s != 0
      sym = EMULTIPOLE_STRENGTH_INVERSE_MAP[(false, bm.order, bm.integrated)]
      println(io, rpad((" "*String(sym)), width), " = ", param_repr(s))
    end
    if etilt != 0
      sym = EMULTIPOLE_TILT_INVERSE_MAP[bm.order]
      println(io, rpad((" "*String(sym)), width), " = ", param_repr(etilt))
    end
  end
  return
end

o2i(b::EMultipoleParams, ord::Int) = findfirst(t->t==ord, b.order)

function EMultipoleParams{T}(b::EMultipoleParams=EMultipoleParams()) where {T}
  n = T.(b.n)
  s = T.(b.s)
  etilt = T.(b.etilt)
  return EMultipoleParams(n,s,etilt,b.order,b.integrated)
end

function Base.hasproperty(b::EMultipoleParams, key::Symbol)
  if key in (:n, :s, :etilt, :order, :integrated)
    return true
  elseif haskey(EMULTIPOLE_TILT_MAP, key) && EMULTIPOLE_TILT_MAP[key] in b.order
    return true
  else
    return false
  end
end

function Base.getproperty(b::EMultipoleParams{T}, key::Symbol) where {T}
  if key in (:n, :s, :etilt, :order, :integrated)
    return getfield(b, key)
  elseif haskey(EMULTIPOLE_TILT_MAP, key)
    ord = EMULTIPOLE_TILT_MAP[key]
    if ord in b.order
      return b.etilt[o2i(b,ord)]
    else
      # Default now
      return 0f0
      #error("Unable to get $key: EMultipoleParams $b does not have a multipole of order $ord")
    end
  end
  error("EMultipoleParams $b does not have property $key")
end

function Base.setproperty!(b::EMultipoleParams{T}, key::Symbol, value) where {T}
  if key in (:n, :s, :etilt, :order, :integrated)
    return setfield!(b, key, value) # Will error because immutable struct
  elseif haskey(EMULTIPOLE_TILT_MAP, key)
    ord = EMULTIPOLE_TILT_MAP[key]
    if ord in b.order
      return b.etilt[o2i(b,ord)] = value
    else
      error("Unable to set $key: EMultipoleParams $b does not have a multipole of order $ord")
    end
  end
  error("EMultipoleParams $b does not have property $key")
end

Base.eltype(::EMultipoleParams{T}) where {T} = T
Base.eltype(::Type{EMultipoleParams{T}}) where {T} = T
Base.length(b::EMultipoleParams{T,N}) where {T,N} = N

# Replace is ONLY here for etilt, which is accessible at this level
function param_replace(b1::EMultipoleParams{T0,N0}, key::Symbol, value) where {T0,N0} 
  if !haskey(EMULTIPOLE_TILT_MAP, key)
    error("Unreachable! `param_replace` with EMultipoleParams should only be called when the etilt of a emultipole is being set such that the number type must be promoted. Please submit an issue to Beamlines.jl")
  end

  # etilt is first value of this multipole being set
  # This is kind of weird, but we can allow it.
  # default integrated to true
  ord = EMULTIPOLE_TILT_MAP[key]
  if hasproperty(b1, key)
    # NOT adding new multipole
    i = o2i(b1,ord)
    integrated = b1.integrated[i]
    T = promote_type(T0,typeof(value))
    b = EMultipoleParams{T}(b1)
    return setproperty!(b, key, value)
  else
    # adding new multipole
    T = promote_type(T0,typeof(value))
    b = addord(EMultipoleParams{T}(b1), ord)
    i = o2i(b, ord)
    b.etilt[i] = value
    return b
  end
end

function addord(b1::EMultipoleParams{T,N0}, ord, intg=true) where {T,N0}
  if length(b1.order) == 0
    i = 1
  elseif ord in b1.order
    error("Multipole order $ord already in EMultipoleParams $b1")
  else
    i = findfirst(t->t>ord, b1.order)
    if isnothing(i)
      i = length(b1.order) + 1
    end
  end
  n = StaticArrays.insert(b1.n, i, T(0f0))
  s = StaticArrays.insert(b1.s, i, T(0f0))
  etilt = StaticArrays.insert(b1.etilt, i, T(0f0))
  order = StaticArrays.insert(b1.order, i, ord)
  integrated = StaticArrays.insert(b1.integrated, i, intg)
  return EMultipoleParams(n, s, etilt, order, integrated)
end

function Base.isapprox(a::EMultipoleParams, b::EMultipoleParams)
  return all(a.n          .≈ b.n) &&
         all(a.s          .≈ b.s) &&
         all(a.etilt      .≈ b.etilt) &&
         all(a.order      .≈ b.order) &&
         all(a.integrated .≈ b.integrated)
end

# To go from SoA to AoS:
struct EMultipole{T}
  n::T
  s::T
  etilt::T
  order::Int
  integrated::Bool
  function EMultipole(n, s, etilt, order, integrated)
    return new{promote_type(typeof(n),typeof(s),typeof(etilt))}(n, s, etilt, order, integrated)
  end
end

Base.eltype(::EMultipole{T}) where {T} = T
Base.eltype(::Type{EMultipole{T}}) where {T} = T

# Make it easy to get EMultipole by order:
function Base.getindex(b::EMultipoleParams, order::Integer)
  i = o2i(b, order)
  if isnothing(i)
    error("Order $order EMultipole not found in EMultipoleParams $b")
  end
  return EMultipole(b.n[i], b.s[i], b.etilt[i], order, b.integrated[i])
end

# and build iterator
function Base.iterate(b::EMultipoleParams, state=1)
  if state > length(b)
    return nothing
  else
    return EMultipole(b.n[state], b.s[state], b.etilt[state], b.order[state], b.integrated[state]), state+1
  end
end


# Setting is weirder/trickier because really only n, s, and etilt can be updated
# on EMultipoles already existing in the structure. For now just don't implement

# First bool is if normal (true) or skew (false)
# then order, integrated
const EMULTIPOLE_STRENGTH_MAP = Dict{Symbol,Tuple{Bool,Int,Bool}}(
  :En0  => (true, 1 , false),
  :En1  => (true, 2 , false),
  :En2  => (true, 3 , false),
  :En3  => (true, 4 , false),
  :En4  => (true, 5 , false),
  :En5  => (true, 6 , false),
  :En6  => (true, 7 , false),
  :En7  => (true, 8 , false),
  :En8  => (true, 9 , false),
  :En9  => (true, 10, false),
  :En10 => (true, 11, false),
  :En11 => (true, 12, false),
  :En12 => (true, 13, false),
  :En13 => (true, 14, false),
  :En14 => (true, 15, false),
  :En15 => (true, 16, false),
  :En16 => (true, 17, false),
  :En17 => (true, 18, false),
  :En18 => (true, 19, false),
  :En19 => (true, 20, false),
  :En20 => (true, 21, false),
  :En21 => (true, 22, false),

  :En0L  => (true, 1 , true),
  :En1L  => (true, 2 , true),
  :En2L  => (true, 3 , true),
  :En3L  => (true, 4 , true),
  :En4L  => (true, 5 , true),
  :En5L  => (true, 6 , true),
  :En6L  => (true, 7 , true),
  :En7L  => (true, 8 , true),
  :En8L  => (true, 9 , true),
  :En9L  => (true, 10, true),
  :En10L => (true, 11, true),
  :En11L => (true, 12, true),
  :En12L => (true, 13, true),
  :En13L => (true, 14, true),
  :En14L => (true, 15, true),
  :En15L => (true, 16, true),
  :En16L => (true, 17, true),
  :En17L => (true, 18, true),
  :En18L => (true, 19, true),
  :En19L => (true, 20, true),
  :En20L => (true, 21, true),
  :En21L => (true, 22, true),

  :Es0  => (false, 1 , false),
  :Es1  => (false, 2 , false),
  :Es2  => (false, 3 , false),
  :Es3  => (false, 4 , false),
  :Es4  => (false, 5 , false),
  :Es5  => (false, 6 , false),
  :Es6  => (false, 7 , false),
  :Es7  => (false, 8 , false),
  :Es8  => (false, 9 , false),
  :Es9  => (false, 10, false),
  :Es10 => (false, 11, false),
  :Es11 => (false, 12, false),
  :Es12 => (false, 13, false),
  :Es13 => (false, 14, false),
  :Es14 => (false, 15, false),
  :Es15 => (false, 16, false),
  :Es16 => (false, 17, false),
  :Es17 => (false, 18, false),
  :Es18 => (false, 19, false),
  :Es19 => (false, 20, false),
  :Es20 => (false, 21, false),
  :Es21 => (false, 22, false),

  :Es0L  => (false, 1 , true),
  :Es1L  => (false, 2 , true),
  :Es2L  => (false, 3 , true),
  :Es3L  => (false, 4 , true),
  :Es4L  => (false, 5 , true),
  :Es5L  => (false, 6 , true),
  :Es6L  => (false, 7 , true),
  :Es7L  => (false, 8 , true),
  :Es8L  => (false, 9 , true),
  :Es9L  => (false, 10, true),
  :Es10L => (false, 11, true),
  :Es11L => (false, 12, true),
  :Es12L => (false, 13, true),
  :Es13L => (false, 14, true),
  :Es14L => (false, 15, true),
  :Es15L => (false, 16, true),
  :Es16L => (false, 17, true),
  :Es17L => (false, 18, true),
  :Es18L => (false, 19, true),
  :Es19L => (false, 20, true),
  :Es20L => (false, 21, true),
  :Es21L => (false, 22, true),
)

const EMULTIPOLE_STRENGTH_INVERSE_MAP = Dict(value => key for (key, value) in EMULTIPOLE_STRENGTH_MAP)

const EMULTIPOLE_TILT_MAP = Dict{Symbol,Int}(
  :etilt0 =>   1,
  :etilt1 =>   2,
  :etilt2 =>   3,
  :etilt3 =>   4,
  :etilt4 =>   5,
  :etilt5 =>   6,
  :etilt6 =>   7,
  :etilt7 =>   8,
  :etilt8 =>   9,
  :etilt9 =>  10,
  :etilt10 => 11,
  :etilt11 => 12,
  :etilt12 => 13,
  :etilt13 => 14,
  :etilt14 => 15,
  :etilt15 => 16,
  :etilt16 => 17,
  :etilt17 => 18,
  :etilt18 => 19,
  :etilt19 => 20,
  :etilt20 => 21, 
  :etilt21 => 22, 
)

const EMULTIPOLE_TILT_INVERSE_MAP = Dict(value => key for (key, value) in EMULTIPOLE_TILT_MAP)