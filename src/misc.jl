@kwdef mutable struct MapParams{F<:Function, P} <: AbstractParams
  transport_map::F = (v, q, p=nothing) -> (v, q)
  transport_map_params::P = nothing
end

PROPS(::Type{MapParams}) = OrderedDict{String,String}(
  "transport_map" => 
  """
  Arbitrary function that transports particles' coordinates `v`, and optionally spin
    quaternions `q`.  Must have the signature `<your map name>(v, q, p=nothing)` and 
    returns the output as a tuple `(v, q)`""",
  "transport_map_params" =>
  "Parameters of the transport map that will be inputted as the `p` variable in `transport_map`",
)

"""
    MapParams

Defines any arbitrary function to transport particle coordinates' and optionally spin 
quaternions. This could be a matrix, a neural network, a phase trombone, etc.

The input for the `transport_map` must be `(v, q, p=nothing)`, where `v` is a tuple of the
input phase space coordinates `(x, px, y, py, z, pz)` and `q` is `nothing` is there is no 
spin tracking, else `q` is a tuple of the input quaternion `(q0, q1, q2, q3)`. `p` may be a
tuple of parameters that can be used inside of the `transport_map`. This might be neural 
network weights, for example, or perhaps phase evolutions for a phase trombone.

For GPU compatibility, it is necessary that your function `transport_map` is GPU compatible:
there should be no type instabilities. You should also try to make your `transport_map` be
branchless, so both the CPU and GPU can vectorize it. 

`transport_map_params` should contain the tuple that is passed into `p` at the time of tracking.
## Properties:
$(PROPSDOC(MapParams))

## Example
```julia
using StaticArrays
random_matrix = @SMatrix rand(6,6) # use StaticArrays for GPU compatibility

function matrix(v, q::Nothing, p) # `q::Nothing` -> no spin tracking
  # Vectorizable matrix multiplication by `p`:
  vx  = sum(p[1,:] .* v)
  vpx = sum(p[2,:] .* v)
  vy  = sum(p[3,:] .* v)
  vpy = sum(p[4,:] .* v)
  vz  = sum(p[5,:] .* v)
  vpz = sum(p[6,:] .* v)
  return ((vx, vpx, vy, vpy, vz, vpz), q)
end

m = LineElement(transport_map=matrix, transport_map_params=random_matrix)
```
"""
MapParams

function Base.isapprox(a::MapParams, b::MapParams)
  if xor(isnothing(a.transport_map_params), isnothing(b.transport_map_params))
    return false
  elseif isnothing(a.transport_map_params) && isnothing(b.transport_map_params)
    return a.transport_map == b.transport_map
  else
    return a.transport_map == b.transport_map && 
          all(a.transport_map_params .≈ b.transport_map_params)
  end
end


# === THIS BLOCK WAS PARTIALLY WRITTEN BY CLAUDE ===
# Generated function for arbitrary-length tuples
@generated function deval(mp::MapParams{F,P}, c::Context=NULL_CONTEXT) where {F,P<:Tuple}
    N = length(P.parameters)
    # Use getfield with literal integer arguments
    exprs = [:(deval(Base.getfield(mp.transport_map_params, $i), c)) for i in 1:N]
    return :(MapParams(mp.transport_map, tuple($(exprs...))))
end

@generated function scalarize(mp::MapParams{F,P}) where {F,P<:Tuple}
    N = length(P.parameters)
    # Use getfield with literal integer arguments
    exprs = [:(scalarize(Base.getfield(mp.transport_map_params, $i))) for i in 1:N]
    return :(MapParams(mp.transport_map, tuple($(exprs...))))
end
# === END CLAUDE ===


@kwdef mutable struct FourPotentialParams{F<:Function, P} <: AbstractParams
  four_potential::F = (x, y, s, t, p=nothing) -> ((0, 0, 0, 0), (0, 0, 0, 0,
                                                                 0, 0, 0, 0,
                                                                 0, 0, 0, 0,
                                                                 0, 0, 0, 0))
  four_potential_params::P = nothing
  four_potential_normalized::Bool = false
end

PROPS(::Type{FourPotentialParams}) = OrderedDict{String,String}(
  "four_potential"            => """Function with arguments `(x, y, s, t, p=nothing)` that returns a two component
  tuple `(C, D)` with both `C` and `D` being themselves tuples:\\
  `\u2800 C = (ϕ, Ax, Ay, As)`\\
  `\u2800 D = (∂ϕ/∂x,  ∂ϕ/∂y,  ∂ϕ/∂s, ∂ϕ/∂t,` \\
  `\u2800      ∂Ax/∂x, ∂Ax/∂y, ∂Ax/∂s, ∂Ax/∂t,` \\
  `\u2800      ∂Ay/∂x, ∂Ay/∂y, ∂Ay/∂s, ∂Ay/∂t,` \\
  `\u2800      ∂As/∂x, ∂As/∂y, ∂As/∂s, ∂As/∂t)` \\""",
  "four_potential_params"     => "Tuple of parameters passed to the `four_potential` function. Default is `nothing`",
  "four_potential_normalized" => "If `true`, then potential/derivatives returned are normalized by `p_over_q_ref`; default is `false`."
)

"""
    FourPotentialParams

Defines the electromagnetic four-potential of an element as a function 
`four_potential(x, y, s, t, p=nothing)` where `p` is a tuple of parameters that may be used 
inside the function.

## Properties:
$(PROPSDOC(FourPotentialParams))
"""
FourPotentialParams

@generated function deval(mp::FourPotentialParams{F,P}, c::Context=NULL_CONTEXT) where {F,P<:Tuple}
    N = length(P.parameters)
    # Use getfield with literal integer arguments
    exprs = [:(deval(Base.getfield(mp.four_potential_params, $i), c)) for i in 1:N]
    return :(FourPotentialParams(mp.four_potential, tuple($(exprs...)), mp.four_potential_normalized))
end

@generated function scalarize(mp::FourPotentialParams{F,P}) where {F,P<:Tuple}
    N = length(P.parameters)
    # Use getfield with literal integer arguments
    exprs = [:(scalarize(Base.getfield(mp.four_potential_params, $i))) for i in 1:N]
    return :(FourPotentialParams(mp.four_potential, tuple($(exprs...)), mp.four_potential_normalized))
end

function Base.isapprox(a::FourPotentialParams, b::FourPotentialParams)
  if xor(isnothing(a.four_potential_params), isnothing(b.four_potential_params))
    return false
  elseif isnothing(a.four_potential_params) && isnothing(b.four_potential_params)
    return (a.four_potential == b.four_potential && 
           a.four_potential_normalized == b.four_potential_normalized)
  else
    return (a.four_potential == b.four_potential && 
            a.four_potential_normalized == b.four_potential_normalized &&
            all(a.four_potential_params .≈ b.four_potential_params))
  end
end

@kwdef mutable struct EMFieldParams{F,P} <: AbstractParams
  em_field::F = (x, y, s, t, p=nothing) -> (0, 0, 0, 0, 0, 0)
  em_field_params::P = nothing
  em_field_normalized::Bool = false
end

PROPS(::Type{EMFieldParams}) = OrderedDict{String,String}(
  "em_field" => "Function with arguments (x, y, s, t, p) the returns a tuple of the EM field values (Ex, Ey, Ez, Bx, By, Bz) at the given point.",
  "em_field_params" => "Tuple of parameters passed to the `em_field` function. Default is `nothing`",
  "em_field_normalized" => "If `true`, then EM field values returned are normalized by `p_over_q_ref`; default is `false`.",
)

"""
    EMFieldParams

Defines the electromagnetic field of an element as a function 
`em_field(x, y, s, t, p=nothing)` where `p` is a tuple of parameters that may be used 
inside the function.

## Properties
$(PROPSDOC(EMFieldParams))
"""
EMFieldParams

@generated function deval(mp::EMFieldParams{F,P}, c::Context=NULL_CONTEXT) where {F,P<:Tuple}
    N = length(P.parameters)
    # Use getfield with literal integer arguments
    exprs = [:(deval(Base.getfield(mp.em_field_params, $i), c)) for i in 1:N]
    return :(EMFieldParams(mp.em_field, tuple($(exprs...)), mp.em_field_normalized))
end

@generated function scalarize(mp::EMFieldParams{F,P}) where {F,P<:Tuple}
    N = length(P.parameters)
    # Use getfield with literal integer arguments
    exprs = [:(scalarize(Base.getfield(mp.em_field_params, $i))) for i in 1:N]
    return :(EMFieldParams(mp.em_field, tuple($(exprs...)), mp.em_field_normalized))
end

function Base.isapprox(a::EMFieldParams, b::EMFieldParams)
  if xor(isnothing(a.em_field_params), isnothing(b.em_field_params))
    return false
  elseif isnothing(a.em_field_params) && isnothing(b.em_field_params)
    return (a.em_field == b.em_field && 
           a.em_field_normalized == b.em_field_normalized)
  else
    return (a.em_field == b.em_field && 
            a.em_field_normalized == b.em_field_normalized &&
            all(a.em_field_params .≈ b.em_field_params))
  end
end

@kwdef mutable struct MetaParams <: AbstractParams
  alias::String = ""
  label::String = ""
  description::String = ""
end

PROPS(::Type{MetaParams}) = OrderedDict{String,String}(
  "alias"       => "Alternate name for the element as a string",
  "label"       => "A label string",
  "description" => "A descriptive string",
)

"""
    MetaParams

Defines extra `String` properties that may be useful for pattern matching 
or storing extra information about a given element.

## Properties
$(PROPSDOC(MetaParams))
"""
MetaParams

# isapprox ignores MetaParams
Base.isapprox(a::MetaParams, b::MetaParams) = true