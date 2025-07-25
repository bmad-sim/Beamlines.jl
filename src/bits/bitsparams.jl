#=

Defines the parameters for the BitsLineElementView 
type.

=#

abstract type AbstractBitsParams end

struct BitsUniversalParams{T} <: AbstractBitsParams
  L::T
end

Base.eltype(::BitsUniversalParams{T}) where {T} = T
Base.eltype(::Type{BitsUniversalParams{T}}) where {T} = T

BitsUniversalParams{T}() where {T} = BitsUniversalParams{T}(T(NaN))

# BMultipoleParams
struct BitsBMultipole{T<:Number,normalized}
  n::T
  s::T      
  tilt::T          
  order::Int       
  # normalized::Bool # normalization stored in type
  # integrated::Bool # tobits conversion always gives integrated
  function BitsBMultipole{T,normalized}(n, s, tilt, order) where {T,normalized}
    normalized isa Bool || error("Second type parameter must be a Bool specifying if this multipole is normalized or not. Received $normalized")
    return new{T,normalized}(T(n),T(s),T(tilt),order)
  end
end

function BMultipole(bbm::BitsBMultipole{T,normalized}) where {T,normalized}
  return BMultipole(bbm.n, bbm.s, bbm.tilt, bbm.order, normalized, true)
end

function Base.getproperty(bm::BitsBMultipole{T,normalized}, key::Symbol) where {T,normalized}
  if key == :normalized
    return normalized
  elseif key == :integrated
    return true
  else
    return getfield(bm, key)
  end
end

Base.eltype(::BitsBMultipole{T,normalized}) where {T,normalized} = T
Base.eltype(::Type{BitsBMultipole{T,normalized}}) where {T,normalized} = T

# Default:
function BitsBMultipole{T,normalized}() where {T <: Number,normalized}
  return BitsBMultipole{T,normalized}(T(NaN), T(NaN), T(NaN), -1)
end

struct BitsBMultipoleParams{T,N,normalized} <: AbstractBitsParams
  n::SVector{N,T}    
  s::SVector{N,T}    
  tilt::SVector{N,T} 
  order::SVector{N,Int}            
  normalized::SVector{N,Bool}      
  integrated::SVector{N,Bool}      
end

o2i(b::BitsBMultipoleParams, ord::Int) = findfirst(t->t==ord, b.order)

# Make it easy to get BMultipole by order:
function Base.getindex(b::BitsBMultipoleParams{T,N,normalized}, order::Integer) where {T,N,normalized}
  i = o2i(b, order)
  if isnothing(i)
    error("Order $order BMultipole not found in BitsBMultipoleParams $b")
  end
  return BitsBMultipole{T,normalized}(b.n[i], b.s[i], b.tilt[i], order) 
end

# and build iterator
function Base.iterate(b::BitsBMultipoleParams, state=1)
  if state > length(b) || b.order[state] == -1
    return nothing
  else
    return BMultipole(b.n[state], b.s[state], b.tilt[state], b.order[state], b.normalized[state], b.integrated[state]), state+1
  end
end

Base.eltype(::BitsBMultipoleParams{T,N}) where {T,N} = T
Base.eltype(::Type{<:BitsBMultipoleParams{T,N}}) where {T,N} = T

Base.length(::BitsBMultipoleParams{T,N}) where {T,N} = N
Base.length(::Type{<:BitsBMultipoleParams{T,N}}) where {T,N} = N

isnormalized(::BitsBMultipoleParams{T,N,normalized}) where {T,N,normalized} = normalized
isnormalized(::Type{<:BitsBMultipoleParams{T,N,normalized}}) where {T,N,normalized} = normalized

isactive(bbm::BitsBMultipoleParams) = !(all(bbm.order .== -1))

# Default:
function BitsBMultipoleParams{T,N,normalized}() where {T,N,normalized}
  n = StaticArrays.sacollect(SVector{N,T}, T(NaN) for i in 1:N)
  s = StaticArrays.sacollect(SVector{N,T}, T(NaN) for i in 1:N)
  tilt = StaticArrays.sacollect(SVector{N,T}, T(NaN) for i in 1:N)
  order = StaticArrays.sacollect(SVector{N,Int}, -1 for i in 1:N)
  nrm = StaticArrays.sacollect(SVector{N,Bool}, normalized for i in 1:N)
  intg = StaticArrays.sacollect(SVector{N,Bool}, true for i in 1:N)
  return BitsBMultipoleParams{T,N,normalized}(n, s, tilt, order, nrm, intg)
end

function BitsBMultipoleParams{T,N,normalized}(n, s, tilt, order) where {T,N,normalized}
  nrm = StaticArrays.sacollect(SVector{N,Bool}, normalized for i in 1:N)
  intg = StaticArrays.sacollect(SVector{N,Bool}, true for i in 1:N)
  return BitsBMultipoleParams{T,N,normalized}(n, s, tilt, order, nrm, intg)
end

# To regular:
function BMultipoleParams(bbm::Union{Nothing,BitsBMultipoleParams{T}}) where {T}
  if !isactive(bbm)
    return nothing
  end
  N = findfirst(t->t==-1, bbm.order)
  if isnothing(N)
    N = length(bbm)
  else
    N -= 1
  end
  n = SizedVector{N,T,Vector{T}}(bbm.n[1:N])
  s = SizedVector{N,T,Vector{T}}(bbm.s[1:N])
  tilt = SizedVector{N,T,Vector{T}}(bbm.tilt[1:N])
  order = SVector{N,Int}(bbm.order[1:N])
  normalized = SVector{N,Bool}(bbm.normalized[1:N])
  integrated = SVector{N,Bool}(bbm.integrated[1:N])
  return BMultipoleParams(n, s, tilt, order, normalized, integrated)
end

# BendParams
struct BitsBendParams{T<:Number} <: AbstractBitsParams
  g_ref::T      
  tilt_ref::T
  e1::T     
  e2::T     
end

Base.eltype(::BitsBendParams{T}) where {T} = T
Base.eltype(::Type{BitsBendParams{T}}) where {T} = T

isactive(bbp::BitsBendParams) = !isnan(bbp.g_ref)

function BitsBendParams{T}() where {T<:Number}
  return BitsBendParams{T}(T(NaN), T(NaN), T(NaN), T(NaN))
end

function BendParams(bbp::Union{Nothing,BitsBendParams})
  if !isactive(bbp)
    return nothing
  else
    return BendParams(bbp.g_ref,bbp.tilt_ref,bbp.e1,bbp.e2)
  end
end

# AlignmentParams
struct BitsAlignmentParams{T<:Number} <: AbstractBitsParams
  x_offset::T 
  y_offset::T 
  z_offset::T
  x_rot::T    
  y_rot::T    
  tilt::T     
end

Base.eltype(::BitsAlignmentParams{T}) where {T} = T
Base.eltype(::Type{BitsAlignmentParams{T}}) where {T} = T

isactive(bap::BitsAlignmentParams) = !isnan(bap.x_offset)

function BitsAlignmentParams{T}() where T <: Number
  return BitsAlignmentParams{T}(T(NaN), T(NaN), T(NaN), T(NaN), T(NaN), T(NaN))
end

function AlignmentParams(bap::Union{Nothing,BitsAlignmentParams})
  if !isactive(bap)
    return nothing
  else
    return AlignmentParams(bap.x_offset, bap.y_offset, bap.z_offset, bap.x_rot, bap.y_rot, bap.tilt)
  end
end

# PatchParams
struct BitsPatchParams{T<:Number} <: AbstractBitsParams
  dt::T     
  dx::T     
  dy::T     
  dz::T     
  dx_rot::T 
  dy_rot::T 
  dz_rot::T   
end

Base.eltype(::BitsPatchParams{T}) where {T} = T
Base.eltype(::Type{BitsPatchParams{T}}) where {T} = T

isactive(bpp::BitsPatchParams) = !isnan(bpp.dt)

function BitsPatchParams{T}() where T <: Number
  return BitsPatchParams{T}(T(NaN), T(NaN), T(NaN), T(NaN), T(NaN), T(NaN), T(NaN))
end

function PatchParams(bpp::Union{Nothing,BitsPatchParams})
  if !isactive(bpp)
    return nothing
  else
    return PatchParams(bpp.dt, bpp.dx, bpp.dy, bpp.dz, bpp.dx_rot, bpp.dy_rot, bpp.dz_rot)
  end
end

