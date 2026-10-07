#---------------------------------------------------------------------------------------------------
# Survey: floor (global) positions and orientations of the branch and element body coordinate
# systems at the ends of the elements of a Branch or Lattice.
#
# The branch coordinate calculation follows the PALS standard ("Branch Coordinates Construction"
# and "Floor Coordinates" in pals/source/coordinates.md), which is the same as Bmad and the PALS
# parsers. The body coordinate calculation follows "Transformation Between Branch and Element Body
# Coordinates" in the same document, which is what BeamTracking uses.
#
# Orientations are unit quaternions stored as `SVector{4}` in the order (q0, qx, qy, qz), the
# same order used for spin quaternions. A quaternion `q` maps vectors in the local (branch or body)
# frame to the floor frame, so the columns of the matrix form of `q` (the matrix W in PALS) are the
# local x, y, and z axes expressed in floor coordinates.

#---------------------------------------------------------------------------------------------------

"""
    FloorCoords{T}

Position and orientation of a coordinate frame (branch or element body) in the floor (global)
coordinate system.

## Fields
- `r`: Position `SVector(x, y, z)` of the frame origin in floor coordinates [m]
- `q`: Orientation of the frame as a unit quaternion `SVector(q0, qx, qy, qz)`. Rotating a
  vector expressed in the frame by `q` gives the vector in floor coordinates.

## Properties
Besides the fields, these properties can be read:
- `x`, `y`, `z`: Components of `r` [m]
- `theta`, `phi`, `psi`: The PALS (and Bmad) floor orientation angles (azimuth, pitch, roll) [rad].
  The orientation is `Ry(theta) * Rx(phi) * Rz(psi)`.

---

    FloorCoords(r = (0, 0, 0), q = (1, 0, 0, 0))

Constructs a `FloorCoords`. `r` and `q` may be any length 3 and length 4 collections. The default
is at the origin with the frame axes aligned with the floor axes.

    FloorCoords(r, theta, phi, psi)

Constructs a `FloorCoords` from a position and the floor orientation angles.
"""
struct FloorCoords{T}
  r::SVector{3,T}
  q::SVector{4,T}
  function FloorCoords{T}(r, q) where {T}
    return new{T}(SVector{3,T}(r...), SVector{4,T}(q...))
  end
end

function FloorCoords(r = (0.0, 0.0, 0.0), q = (1.0, 0.0, 0.0, 0.0))
  T = promote_type(map(typeof, Tuple(r))..., map(typeof, Tuple(q))...)
  return FloorCoords{T}(r, q)
end

FloorCoords(r, theta, phi, psi) = FloorCoords(r, _quat_from_floor_angles(theta, phi, psi))

FloorCoords{T}(f::FloorCoords) where {T} = FloorCoords{T}(f.r, f.q)
Base.convert(::Type{FloorCoords{T}}, f::FloorCoords) where {T} = FloorCoords{T}(f)
Base.convert(::Type{FloorCoords{T}}, f::FloorCoords{T}) where {T} = f

Base.eltype(::FloorCoords{T}) where {T} = T
Base.eltype(::Type{FloorCoords{T}}) where {T} = T

Base.propertynames(::FloorCoords) = (:r, :q, :x, :y, :z, :theta, :phi, :psi)

function Base.getproperty(f::FloorCoords, key::Symbol)
  if key == :x
    return getfield(f, :r)[1]
  elseif key == :y
    return getfield(f, :r)[2]
  elseif key == :z
    return getfield(f, :r)[3]
  elseif key in (:theta, :phi, :psi)
    return getproperty(_floor_angles(getfield(f, :q)), key)
  else
    return getfield(f, key)
  end
end

Base.isapprox(a::FloorCoords, b::FloorCoords; kwargs...) =
  isapprox(a.r, b.r; kwargs...) && _quat_isapprox(a.q, b.q; kwargs...)

# `q` and `-q` are the same rotation.
_quat_isapprox(a, b; kwargs...) = isapprox(a, b; kwargs...) || isapprox(a, -b; kwargs...)

function Base.show(io::IO, f::FloorCoords)
  print(io, "FloorCoords(r = ", Tuple(f.r), ", q = ", Tuple(f.q), ")")
end

#---------------------------------------------------------------------------------------------------
# Quaternion and frame helpers. A frame transformation is a pair (L, S): the displacement L of the
# new frame origin, expressed in the old frame, and the rotation S of the new frame relative to the
# old one. Applying (L, S) to a frame (r, q) gives (r + q*L, q*S) (Eq. wws in PALS).

# Hamilton product: `_qmul(a, b)` rotates by `b` and then by `a`.
function _qmul(a, b)
  return SVector(a[1]*b[1] - a[2]*b[2] - a[3]*b[3] - a[4]*b[4],
                 a[1]*b[2] + a[2]*b[1] + a[3]*b[4] - a[4]*b[3],
                 a[1]*b[3] - a[2]*b[4] + a[3]*b[1] + a[4]*b[2],
                 a[1]*b[4] + a[2]*b[3] - a[3]*b[2] + a[4]*b[1])
end

# Rotate the 3-vector `v` by the quaternion `q`.
function _qrot(q, v)
  w, x, y, z = q
  return SVector((1 - 2*(y*y + z*z))*v[1] + 2*(x*y - w*z)*v[2]       + 2*(x*z + w*y)*v[3],
                 2*(x*y + w*z)*v[1]       + (1 - 2*(x*x + z*z))*v[2] + 2*(y*z - w*x)*v[3],
                 2*(x*z - w*y)*v[1]       + 2*(y*z + w*x)*v[2]       + (1 - 2*(x*x + y*y))*v[3])
end

_qnormalize(q) = q / sqrt(sum(abs2, q))

_qrotx(a) = SVector(cos(a/2), sin(a/2), zero(a), zero(a))
_qroty(a) = SVector(cos(a/2), zero(a), sin(a/2), zero(a))
_qrotz(a) = SVector(cos(a/2), zero(a), zero(a), sin(a/2))

# Ry(y_rot) * Rx(x_rot) * Rz(z_rot): the rotation convention of the floor angles, patches, and
# misalignments.
_qrot_yxz(x_rot, y_rot, z_rot) = _qmul(_qroty(y_rot), _qmul(_qrotx(x_rot), _qrotz(z_rot)))

_quat_from_floor_angles(theta, phi, psi) = _qrot_yxz(phi, theta, psi)

# Floor angles (theta, phi, psi) of the orientation `q`. At the phi = ±π/2 singularity, psi is
# taken to be zero.
function _floor_angles(q)
  w, x, y, z = _qnormalize(q)
  r02 = 2*(x*z + w*y)
  r12 = 2*(y*z - w*x)
  r22 = 1 - 2*(x*x + y*y)
  cos_phi = sqrt(r02*r02 + r22*r22)
  phi = atan(-r12, cos_phi)
  if cos_phi > 1e-12
    theta = atan(r02, r22)
    psi = atan(2*(x*y + w*z), 1 - 2*(x*x + z*z))
  else
    theta = atan(-2*(x*z - w*y), 1 - 2*(y*y + z*z))
    psi = zero(theta)
  end
  return (theta = theta, phi = phi, psi = psi)
end

# Apply the frame transformation (L, S) to `f`.
function _transform(f::FloorCoords, L, S)
  return FloorCoords(f.r + _qrot(f.q, L), _qnormalize(_qmul(f.q, S)))
end

_translate(f::FloorCoords, L) = FloorCoords(f.r + _qrot(f.q, L), f.q)

_rotate(f::FloorCoords, S) = FloorCoords(f.r, _qnormalize(_qmul(f.q, S)))

# Transformation (L, S) along a reference curve of arc length `ds` and curvature `g` in the plane
# rotated by `tilt_ref` about z (Eqs. ustt and lrztt in PALS). `ds` may be negative.
function _arc_LS(ds, g, tilt_ref)
  angle = g * ds
  if iszero(angle)
    return SVector(zero(ds), zero(ds), ds), SVector(one(ds), zero(ds), zero(ds), zero(ds))
  end
  # rho*(cos(angle) - 1) and rho*sin(angle) with rho = ds/angle. Written so that nothing
  # is lost when the angle is small.
  x = -2 * sin(angle/2)^2 / g
  z = sin(angle) / g
  st, ct = sincos(tilt_ref)
  L = SVector(ct * x, st * x, z)
  # Rotation by `angle` around the axis (sin(tilt_ref), -cos(tilt_ref), 0)
  sa, ca = sincos(angle/2)
  S = SVector(ca, st * sa, -ct * sa, zero(sa))
  return L, S
end

#---------------------------------------------------------------------------------------------------
# Geometry of a single element

# Branch coordinates at the exit of `ele` given the branch coordinates `f0` at the entrance.
function _branch_exit(f0::FloorCoords, ele::LineElement)
  if !isnothing(ele.PatchParams)
    if !isnothing(ele.BendParams)
      error("Unable to survey element $(_ele_location_repr(ele)): an element cannot have both PatchParams and BendParams")
    end
    return _transform(f0, SVector(ele.dx, ele.dy, ele.dz), _qrot_yxz(ele.dx_rot, ele.dy_rot, ele.dz_rot))
  elseif !isnothing(ele.BendParams)
    return _transform(f0, _arc_LS(ele.L, ele.g_ref, ele.tilt_ref)...)
  else
    return _translate(f0, SVector(zero(ele.L), zero(ele.L), ele.L))
  end
end

# Body coordinates at the entrance and exit of `ele` given the branch coordinates `f0` at the
# entrance and `f1` at the exit. Without misalignments, and except for bends with a non-zero
# `tilt_ref`, the body coordinates are the branch coordinates.
function _body_ends(f0::FloorCoords, f1::FloorCoords, ele::LineElement)
  has_align = !isnothing(ele.AlignmentParams)
  has_bend = !isnothing(ele.BendParams)
  # Patches do not have misalignments.
  if !isnothing(ele.PatchParams) || !(has_align || has_bend)
    return f0, f1
  end

  if !has_align
    # Bend without misalignment: the body coordinates are rotated by tilt_ref.
    tilt_ref = ele.tilt_ref
    iszero(tilt_ref) && return f0, f1
    return _rotate(f0, _qrotz(tilt_ref)), _rotate(f1, _qrotz(tilt_ref))
  end

  L = ele.L
  S_mis = _qrot_yxz(ele.x_rot, ele.y_rot, ele.tilt)
  offset = SVector(ele.x_offset, ele.y_offset, ele.z_offset)

  if !has_bend
    # Straight element: the misalignment is about the element center.
    mid = _translate(f0, SVector(zero(L), zero(L), L/2))
    emid = _transform(mid, offset, S_mis)
    return _translate(emid, SVector(zero(L), zero(L), -L/2)),
           _translate(emid, SVector(zero(L), zero(L),  L/2))
  end

  # Bend: The misalignment is about the center of the chord. `tilt_ref` rotates the body
  # coordinates so that the bend is in the body x-z plane.
  g = ele.g_ref
  tilt_ref = ele.tilt_ref
  angle = g * L
  # rho*(cos(angle/2) - 1): displacement from the arc center to the chord center along the
  # direction of bending.
  f = iszero(angle) ? zero(angle) : -2 * sin(angle/4)^2 / g
  st, ct = sincos(tilt_ref)
  mid = _transform(f0, _arc_LS(L/2, g, tilt_ref)...)
  chord_mid = _translate(mid, SVector(f * ct, f * st, zero(f)))
  emid = _translate(_rotate(_transform(chord_mid, offset, S_mis), _qrotz(tilt_ref)), SVector(-f, zero(f), zero(f)))
  return _transform(emid, _arc_LS(-L/2, g, zero(tilt_ref))...),
         _transform(emid, _arc_LS( L/2, g, zero(tilt_ref))...)
end

#---------------------------------------------------------------------------------------------------

"""
    ElementSurvey{T}

Survey of one element in a `Branch`: the floor positions and orientations of the branch
and element body coordinate systems at the entrance and exit ends of the element. See `survey`.

## Fields
- `name`: Name of the element
- `kind`: Kind of the element
- `index`: Index of the element in the `Branch` (as in `branch[index]`)
- `s`: Longitudinal position of the entrance end of the element [m]
- `s_downstream`: Longitudinal position of the exit end of the element [m]
- `branch_entrance`: `FloorCoords` of the branch coordinates at the entrance end
- `branch_exit`: `FloorCoords` of the branch coordinates at the exit end
- `body_entrance`: `FloorCoords` of the element body coordinates at the entrance end
- `body_exit`: `FloorCoords` of the element body coordinates at the exit end
"""
struct ElementSurvey{T}
  name::String
  kind::String
  index::Int
  s::T
  s_downstream::T
  branch_entrance::FloorCoords{T}
  branch_exit::FloorCoords{T}
  body_entrance::FloorCoords{T}
  body_exit::FloorCoords{T}
end

function ElementSurvey{T}(e::ElementSurvey) where {T}
  return ElementSurvey{T}(e.name, e.kind, e.index, e.s, e.s_downstream,
                          e.branch_entrance, e.branch_exit, e.body_entrance, e.body_exit)
end

Base.eltype(::ElementSurvey{T}) where {T} = T

function Base.show(io::IO, e::ElementSurvey)
  println(io, "ElementSurvey: ", repr(e.name), " (index ", e.index, ")")
  for key in fieldnames(ElementSurvey)
    key in (:name, :index) && continue
    println(io, " ", rpad(String(key), 16), " = ", repr(getfield(e, key)))
  end
end

"""
    BranchSurvey{T}

Survey of a `Branch`. Indexing gives the `ElementSurvey` of an element, with the same indices as
the `Branch`. See `survey`.

## Fields
- `name`: Name of the `Branch`
- `lattice_index`: Index of the `Branch` in the `Lattice`, or `-1` if the `Branch` is not in a `Lattice`
- `elements`: Vector of the `ElementSurvey`s of the elements in the `Branch`
"""
struct BranchSurvey{T}
  name::String
  lattice_index::Int
  elements::Vector{ElementSurvey{T}}
end

Base.eltype(::BranchSurvey{T}) where {T} = T
Base.getindex(b::BranchSurvey, i) = b.elements[i]
Base.length(b::BranchSurvey) = length(b.elements)
Base.firstindex(b::BranchSurvey) = 1
Base.lastindex(b::BranchSurvey) = length(b)
Base.iterate(b::BranchSurvey, state...) = iterate(b.elements, state...)

"""
    LatticeSurvey{T}

Survey of a `Lattice`. Indexing with an integer or a branch name gives the `BranchSurvey` of
a `Branch`. See `survey`.

## Fields
- `name`: Name of the `Lattice`
- `branches`: Vector of the `BranchSurvey`s of the branches in the `Lattice`
"""
struct LatticeSurvey{T}
  name::String
  branches::Vector{BranchSurvey{T}}
end

Base.eltype(::LatticeSurvey{T}) where {T} = T
Base.getindex(s::LatticeSurvey, i) = s.branches[i]
function Base.getindex(s::LatticeSurvey, name::AbstractString)
  i = findfirst(b -> b.name == name, s.branches)
  isnothing(i) && error("LatticeSurvey has no branch named $(repr(name))")
  return s.branches[i]
end
Base.length(s::LatticeSurvey) = length(s.branches)
Base.firstindex(s::LatticeSurvey) = 1
Base.lastindex(s::LatticeSurvey) = length(s)
Base.iterate(s::LatticeSurvey, state...) = iterate(s.branches, state...)

#---------------------------------------------------------------------------------------------------

"""
    survey(branch::Branch; floor0 = FloorCoords()) -> BranchSurvey
    survey(lat::Lattice; floor0 = FloorCoords()) -> LatticeSurvey

Computes the floor (global) positions and orientations of the branch and element body coordinate
systems at the entrance and exit ends of every element. The survey is a snapshot: it is not
stored in, or updated with, the `Branch` or `Lattice`.

The branch coordinates are constructed element by element (see the PALS standard):
- A straight element of length `L` moves the origin a distance `L` along the z-axis.
- An element with `BendParams` moves the origin along a circular arc with curvature `g_ref`,
  bending in the plane rotated by `tilt_ref` about the z-axis.
- An element with `PatchParams` moves the origin by `(dx, dy, dz)` and rotates the axes by
  `Ry(dy_rot) * Rx(dx_rot) * Rz(dz_rot)`.

The element body coordinates are the branch coordinates shifted by the `AlignmentParams` of
the element, with the offsets and rotations `Ry(y_rot) * Rx(x_rot) * Rz(tilt)` applied at the
element center (the center of the chord for a bend). For a bend, the body coordinates are also
rotated by `tilt_ref` about the z-axis, so that the bend is in the body x-z plane. Patches do not
have misalignments, so their body coordinates are the branch coordinates.

For a `Branch`, the branch coordinates at the entrance of the first element are `floor0`.
For a `Lattice`, the branches are surveyed in order. If the first element of a branch is
connected by a fork (see `ForkParams`) to an element in an earlier branch, the branch starts at
the position and orientation of that element, regardless of the `fork_orientation`. Otherwise
the branch starts at `floor0`.

## Example
```julia
lat = Lattice([Branch([Drift(L=1), SBend(L=2, angle=pi/4), Quadrupole(L=0.5, x_offset=1e-3)])])
sv = survey(lat)
sv[1][2].branch_exit.theta  # Azimuth angle at the exit of the bend
sv[1][3].body_entrance.x    # Floor x position of the entrance of the quadrupole body
```
"""
function survey(branch::Branch; floor0::FloorCoords = FloorCoords())
  lattice_index = getfield(branch, :lattice_index)
  return _survey(branch, floor0, lattice_index, nothing)
end

function survey(lat::Lattice; floor0::FloorCoords = FloorCoords())
  # Branch coordinates at each element with ForkParams, and at each element connected to by a
  # fork, at the element (zero length, so the entrance and exit are the same).
  fork_floors = IdDict{LineElement,FloorCoords}()
  bsurveys = BranchSurvey[]
  for (i, branch) in enumerate(lat.branches)
    start = floor0
    if length(branch) > 0
      ele1 = branch[1]
      # Any fork connection involving the first element is to an element at the same place.
      if haskey(fork_floors, ele1)
        start = fork_floors[ele1]
      else
        fp = ele1.ForkParams
        target = isnothing(fp) ? nothing : fp.fork_connect_element
        if !isnothing(target) && haskey(fork_floors, target)
          start = fork_floors[target]
        end
      end
    end
    push!(bsurveys, _survey(branch, start, i, fork_floors))
  end
  T = mapreduce(eltype, promote_type, bsurveys; init=Float64)
  return LatticeSurvey{T}(lat.name, [BranchSurvey{T}(b.name, b.lattice_index, ElementSurvey{T}.(b.elements)) for b in bsurveys])
end

function _survey(branch::Branch, floor0::FloorCoords, lattice_index, fork_floors)
  esurveys = ElementSurvey[]
  f0 = floor0
  index = 0
  for bl in branch.beamlines, ele in bl.line
    index += 1
    f1 = _branch_exit(f0, ele)
    b0, b1 = _body_ends(f0, f1, ele)
    s = ele.s
    T = promote_type(eltype(f0), eltype(f1), eltype(b0), eltype(b1), typeof(s), typeof(ele.L))
    push!(esurveys, ElementSurvey{T}(ele.name, ele.kind, index, s, s + ele.L, f0, f1, b0, b1))
    if !isnothing(fork_floors)
      fp = ele.ForkParams
      if !isnothing(fp)
        fork_floors[ele] = f1
        target = fp.fork_connect_element
        isnothing(target) || haskey(fork_floors, target) || (fork_floors[target] = f1)
      end
    end
    f0 = f1
  end
  T = mapreduce(eltype, promote_type, esurveys; init=promote_type(Float64, eltype(floor0)))
  return BranchSurvey{T}(branch.name, lattice_index, ElementSurvey{T}.(esurveys))
end

#---------------------------------------------------------------------------------------------------

_survey_repr(x::AbstractFloat) = round(x; sigdigits=8) + zero(x)  # + zero(x) turns -0.0 into 0.0
_survey_repr(x) = x

function Base.show(io::IO, b::BranchSurvey)
  println(io, "BranchSurvey: ", b.name)
  println(io, " Branch coordinates at the exit end of each element:")
  offset = 7
  N = length(b)
  table = Matrix{Any}(nothing, 1+N, 10)
  table[1,:] = ["Index", "Name", "Kind", "s_downstream [m]", "x [m]", "y [m]", "z [m]",
                "theta [rad]", "phi [rad]", "psi [rad]"]
  for (i, e) in enumerate(b.elements)
    f = e.branch_exit
    table[i+1,:] = [e.index, e.name, e.kind, _survey_repr.((e.s_downstream, f.x, f.y, f.z, f.theta, f.phi, f.psi))...]
    if get(io, :limit, false) && i > displaysize(io)[1] - offset
      break
    end
  end
  pretty_table(io, table;
    limit_printing=get(io, :limit, false),
    alignment = :l,
    show_column_labels = false,
    fit_table_in_display_horizontally = get(io, :limit, false),
    fit_table_in_display_vertically = get(io, :limit, false),
    table_format = TextTableFormat(
      borders = text_table_borders__borderless,
      horizontal_line_at_beginning=false,
    ),
    display_size=(displaysize(io)[1]-offset, displaysize(io)[2]),
    highlighters=[TextHighlighter((v,i,j)->i == 1, crayon"bold")],
    new_line_at_end=false,
    formatters=[(v, i, j)-> isnothing(v) ? "" : v]
  )
  return
end

function Base.show(io::IO, s::LatticeSurvey)
  println(io, "LatticeSurvey: ", s.name)
  for b in s.branches
    nele = length(b)
    print(io, " ", b.lattice_index, ": ", repr(b.name), ", ", nele, " elements")
    if nele > 0
      f = b[end].branch_exit
      print(io, ", end at (x, y, z) = ", _survey_repr.((f.x, f.y, f.z)))
    end
    println(io)
  end
end
