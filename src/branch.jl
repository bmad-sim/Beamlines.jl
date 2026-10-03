#---------------------------------------------------------------------------------------------------

"""
    Branch

Structure containing a vector of `Beamline`s, where currently each follows in-order, 
one after the other. 

## Properties
- `name`: Name of the `Branch`. Default is `""` if not in a lattice and if in a lattice,
  the default is `"bN"` where `N` is the index of the branch in `lattice.branches`
- `beamlines`: Vector of the beamlines in the `Branch`
- `lattice`: `Lattice` that the branch is placed in, if any
- `lattice_index`: Index of the branch in the `Lattice`, if in a `Lattice`
- `context`: `Context` shared by the `Branch` and all of its `Beamline`s, and by the whole
    `Lattice` if the `Branch` is in one. Setting the `context` of any of them sets it for
    all of them.
"""
const Branch = _Branch{Beamline}

#---------------------------------------------------------------------------------------------------

"""
    Lattice

Structure containing a vector of `Branch`es. 

## Properties
- `name`: Name of the `Lattice`. Defaults to blank `""`.
- `branches`: Vector of the branches in the `Lattice`. These are copies of the `Branch`es 
    the `Lattice` was constructed with, which are left unmodified
- `context`: `Context` shared by the `Lattice`, all of its `Branch`es, and all of their
    `Beamline`s. Setting the `context` of any of them sets it for all of them.
"""
const Lattice = _Lattice{Branch}

#---------------------------------------------------------------------------------------------------

# `_connect_forks!` must be defined before NULL_LATTICE: the `_Lattice` constructor calls it.

"""
    _connect_forks!(branches, sources)

Internal: used by the `Lattice` constructor. `branches` are the `Branch`es of the `Lattice` 
and `sources[i]` is the `Branch` that `branches[i]` was copied from (or `branches[i]` itself 
if it was not copied).

For each element in `branches` with a `fork_to_element`, the destination `Branch` is found:
- If the destination element is in the source of the fork's own `Branch`, the fork connects 
  within that `Branch`.
- Else if the destination is in a `Branch` (or the source of a `Branch`) of the `Lattice`, 
  the fork connects to that `Branch`.
- Else a copy of the destination `Branch` is appended to `branches`. Forks in the appended 
  `Branch` are processed in turn.

The fork element in the `Lattice` is then given its own `ForkParams` whose `fork_to_element` 
is the corresponding element in the `Lattice`. The elements the `Lattice` was constructed
from are not modified.
"""
function _connect_forks!(branches::AbstractVector{B}, sources::AbstractVector{B}) where {B<:_AbstractBranch}
  i = 1
  while i <= length(branches)  # `branches` may grow as forks add new Branches
    for bl in branches[i].beamlines, ele in bl.line
      fp = ele.ForkParams
      (isnothing(fp) || isnothing(fp.fork_to_element)) && continue
      dest = fp.fork_to_element
      dest_pdict = getfield(dest, :pdict)
      if !haskey(dest_pdict, BeamlineParams) || getfield((dest_pdict[BeamlineParams]::BeamlineParams).beamline, :branch_index) == -1
        error("""
          Unable to connect fork element $(repr(ele.name)) in branch $(repr(branches[i].name)): 
          fork_to_element $(repr(dest.name)) is not in a Branch. The fork_to_element must be an 
          element in a Branch, e.g. found using `findchildren`.
        """)
      end
      dest_bp = dest_pdict[BeamlineParams]::BeamlineParams
      dest_bl = dest_bp.beamline
      j = _fork_branch_index(branches, sources, i, getfield(dest_bl, :branch), ele)
      target = branches[j].beamlines[getfield(dest_bl, :branch_index)].line[dest_bp.beamline_index]
      # Set in the fork element's own pdict: setting the property would write through 
      # InheritParams to the element the Lattice was constructed from.
      getfield(ele, :pdict)[ForkParams] = ForkParams(target, fp.fork_direction, fp.fork_propagate_reference)
    end
    i += 1
  end
  return branches
end

# Index in `branches` of the Branch that a fork in `branches[i]` to an element in `dest_branch` 
# connects to. Appends a copy of `dest_branch` if it is not already in the Lattice.
function _fork_branch_index(branches, sources, i, dest_branch, ele)
  if dest_branch === sources[i] || dest_branch === branches[i]
    return i
  end
  js = findall(j -> sources[j] === dest_branch || branches[j] === dest_branch, eachindex(branches))
  if length(js) > 1
    error("""
      Unable to connect fork element $(repr(ele.name)) in branch $(repr(branches[i].name)): 
      the Branch containing the fork_to_element appears more than once in the Lattice 
      (at indices $js) so the destination is ambiguous.
    """)
  elseif length(js) == 1
    return only(js)
  end
  push!(sources, dest_branch)
  push!(branches, copy(dest_branch))
  return length(branches)
end

#---------------------------------------------------------------------------------------------------

# NULL_LATTICE must be defined before NULL_BRANCH: the `_Branch` constructor references it. 
# Both are constructed from empty vectors.

const NULL_LATTICE = Lattice(Branch[])
const NULL_BRANCH = Branch(Beamline[])

Base.show(io::IO, ::Type{Branch}) = print(io, "Branch")
Base.show(io::IO, ::Type{Lattice}) = print(io, "Lattice")

#---------------------------------------------------------------------------------------------------

function Base.show(io::IO, branch::Branch)
  lines_used = 1; println(io, "Branch:")
  # The reference species and energy shown are those at the start of the Branch.
  name = :Inferred
  try
    species_ref = first(branch.beamlines).species_ref
    name = nameof(species_ref)
  catch
  end
  lines_used += 1; println(io, " species_ref", " = ", name)
  lines_used += 1; println(io, " name", " = ", branch.name)
  ref = :Inferred
  ref_meaning = refmeaning_to_sym(getfield(InitialBeamlineParams(), :ref_meaning)) # Default
  try
    ibp = first(first(branch.beamlines).line).InitialBeamlineParams
    ref_meaning = refmeaning_to_sym(ibp.ref_meaning)
    ref = ibp.ref 
  catch
  end
  lines_used += 1; println(io, " "*String(ref_meaning), " = ", param_repr(ref))

  lattice_index = getfield(branch, :lattice_index)
  if lattice_index != -1
    lines_used += 1; println(io, " lattice_index", " = ", lattice_index)
  end

  offset = 6

  N_ele = length(branch)
  # Index, Name, Kind, s
  ele_table = Matrix{Any}(nothing, 1+N_ele, 6)
  ele_table[1,:] = ["Index", "Name", "Kind", "L [m]", "s [m]", "s_downstream [m]"]

  i = 0
  for bl in branch.beamlines
    for ele in bl.line
      i += 1
      ele_table[i+1,:] = [i, ele.name, ele.kind, param_repr(ele.L), param_repr(ele.s), param_repr(ele.s+ele.L)]
      lines_used += 1
      if get(io, :limit, false) && lines_used > displaysize(io)[1]-offset
        break
      end
    end
  end

  println(io)
  pretty_table(io, ele_table;
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

#---------------------------------------------------------------------------------------------------

"""
    Base.copy(branch::Branch)

Copy of `branch` that is not in any `Lattice`. The `Beamline`s are copied as with 
`copy(::Beamline)`, so the `LineElement`s of the copy are children of those in `branch`. The 
`Context` is copied.
"""
Base.copy(branch::Branch) = Branch(collect(branch.beamlines); name = branch.name, 
                                   context = copy(branch.context))

#---------------------------------------------------------------------------------------------------

"""
    Branch(beamlines; name = "", context = Context())

Constructs a `Branch` given the vector of beamlines `beamlines`. The `Branch` holds copies 
(see `copy(::Beamline)`) of the `Beamline`s, whose `LineElement`s are children of those of the 
corresponding `Beamline` in `beamlines`. The `Beamline`s in `beamlines` are not modified, so 
a `Beamline` may appear more than once and may also be used in other `Branch`es. The contexts 
of the `Beamline`s and `context` are merged into a single `Context` shared by the `Branch` and all of its `Beamline`s. 
Variables in `context` take precedence over those in the `Beamline`s.

## Example
```julia
ele = LineElement()
bl1 = Beamline([ele], E_ref=2e9, species_ref=Species("electron"))
bl2 = Beamline([ele], dE_ref=1e9)

branch = Branch([bl1, bl2])
```

---

    Branch(elements; species_ref0 = Species(), E_ref0 = nothing, pc_ref0 = nothing, 
           p_over_q_ref0 = nothing, name = "", context = Context())

Constructs a `Branch` given the vector `elements`, which may contain `LineElement`s, 
`Beamline`s, and `Branch`es, in any combination:

- Consecutive `LineElement`s are made into `Beamline`s. A new `Beamline` is started at each 
  `LineElement` that sets a reference species or energy (has an `InitialBeamlineParams`), so 
  each `Beamline` has a uniform reference species and energy.
- A `Beamline` is included as a copy (see `Branch(beamlines)`) whose `LineElement`s are 
  children of those of the `Beamline`. The same `Beamline` may appear more than once.
- For a `Branch`, each of its `Beamline`s is included as a copy whose `LineElement`s are 
  children of those in the `Branch` (as with `copy(::Branch)`). The same `Branch` may appear
  more than once.

The reference species and energy of the first `Beamline` can be set with `species_ref0` and 
one of `E_ref0`, `pc_ref0`, or `p_over_q_ref0`. These are only allowed if `elements` starts 
with a `LineElement`.

## Example
```julia
beginning = Marker(E_ref=10e9, species_ref=Species("electron"))
rf0 = RFCavity(dE_ref=1e9)
next = LineElement()

branch = Branch([beginning, rf0, next]) # Partitioned into 2 `Beamline`s

arc = Beamline([Drift(L=1.0), SBend(L=2.0)])
cell = Branch([Quadrupole(L=0.5), Drift(L=1.0)])
branch2 = Branch([beginning, arc, cell, cell, Marker()]) # 5 `Beamline`s
```
"""
# Defined for `_Branch{T}` rather than `Branch` so the inner constructor 
# `_Branch{T}(::Vector{T})` is more specific and `Branch(::Vector{Beamline})` is not ambiguous.
function _Branch{T}(
  elements::AbstractVector;
  species_ref0::Species=Species(),
  E_ref0=nothing,
  p_over_q_ref0=nothing,
  pc_ref0=nothing,
  name::String = "",
  context = Context(),
) where {T<:_AbstractBeamline}
  kwargs = (p_over_q_ref0, E_ref0, pc_ref0)
  kwarg_syms = (:p_over_q_ref, :E_ref, :pc_ref)
  c = count(t->!isnothing(t), kwargs)
  if c > 1
    error("Only one of E_ref0, pc_ref0, p_over_q_ref0 can be specified")
  end
  kwarg_idx = findfirst(t->!isnothing(t), kwargs)
  kwarg_val = isnothing(kwarg_idx) ? nothing : kwargs[kwarg_idx]
  kwarg_sym = isnothing(kwarg_idx) ? :p_over_q_ref : kwarg_syms[kwarg_idx] 

  if (c == 1 || !isnullspecies(species_ref0)) && (isempty(elements) || !(first(elements) isa LineElement))
    error("species_ref0, E_ref0, pc_ref0, and p_over_q_ref0 can only be used if the first entry of elements is a LineElement")
  end

  has_ibp(ele) = ele isa LineElement && haskey(getfield(ele, :pdict), InitialBeamlineParams)

  beamlines = Beamline[]
  i = firstindex(elements)
  while i <= lastindex(elements)
    item = elements[i]
    if item isa LineElement
      # Run of LineElements up to the next entry that is not a LineElement or that starts a new Beamline
      j = i
      while j < lastindex(elements) && elements[j+1] isa LineElement && !has_ibp(elements[j+1])
        j += 1
      end
      line = LineElement[elements[k] for k in i:j]
      if isempty(beamlines)
        push!(beamlines, Beamline(line; species_ref=species_ref0, kwarg_sym=>kwarg_val, context = context))
      else
        push!(beamlines, Beamline(line; context = context))
      end
      i = j + 1
    elseif item isa Beamline
      push!(beamlines, copy(item))
      i += 1
    elseif item isa Branch
      append!(beamlines, (copy(bl) for bl in item.beamlines))
      i += 1
    else
      error("Unable to construct Branch: entry $i of elements is a $(typeof(item)). Entries must be LineElements, Beamlines, or Branches.")
    end
  end

  # Every entry of `beamlines` was either constructed above or copied when it was added, so 
  # none is referenced elsewhere and the Branch takes them as-is rather than copying again.
  return Branch(beamlines; name = name, context = context, _adopt = true)
end

#---------------------------------------------------------------------------------------------------

"""
    _context(branch::Branch)

Return the `Context` of `branch`: the `Context` stored in the `Lattice` that `branch` is in, 
if any, else the `Context` stored in `branch` itself.

The `Context` of a `Lattice`, or of a `Branch` not in a `Lattice`, is stored only at that 
highest level. The `Branch`es and `Beamline`s below it store `NULL_CONTEXT`, which is set 
when they are put in the `Branch` or `Lattice`. Setting the `context` property at any level 
sets the field of the highest level only.
"""
@inline function _context(branch::Branch)
  if getfield(branch, :lattice_index) == -1
    return getfield(branch, :context)
  else
    return getfield(getfield(branch, :lattice), :context)
  end
end

#---------------------------------------------------------------------------------------------------

Base.propertynames(::Branch) = (:name, :beamlines, :lattice, :lattice_index, :context)

function Base.getproperty(branch::Branch, key::Symbol)
  prop = trygetproperty(branch, key)
  if prop isa GetError
    error(prop.msg)
  end
  return prop
end

function trygetproperty(b::Branch, key::Symbol)
  if key == :context
    return _context(b)
  elseif key in (:beamlines, :lattice, :lattice_index, :name)
    field = getfield(b, key)
    if key in (:lattice, :lattice_index) && (field == -1 || field === NULL_LATTICE)
      return GetError("Unable to get $key: Branch is not in a Lattice")
    else
      return field
    end
  else
    error("Unable to get property $key from Branch: Branch does not have this property")
  end
end

function Base.setproperty!(b::Branch, key::Symbol, value)
  if key == :name
    setfield!(b, key, value)
  elseif key == :context
    if getfield(b, :lattice_index) == -1
      setfield!(b, :context, value)
    else  # The Context is stored only in the Lattice
      setfield!(getfield(b, :lattice), :context, value)
    end
  elseif key in (:beamlines, :lattice, :lattice_index)
    error("Unable to set property $key: this field is protected")
  else
    error("Unable to set property $key of Branch: Branch does not have this property")
  end
end

#---------------------------------------------------------------------------------------------------

"""
    Lattice(branches::Vector{Branch}; name = "", context = Context())

Constructs a `Lattice` given the vector of branches `branches`. The `Lattice` holds copies 
(see `copy(::Branch)`) of the `Branch`es, whose `LineElement`s are children of those of the 
corresponding `Branch` in `branches`. The `Branch`es in `branches` are not modified, so a 
`Branch` may appear more than once and may also be used in other `Lattice`s. Branches without 
a name are named `"b<i>"`, where `<i>` is the index of the branch. The contexts of the 
`Branch`es and `context` are merged into a single `Context` shared by the `Lattice`, all of its
`Branch`es, and all of their `Beamline`s. Variables in `context` take precedence over those
in the `Branch`es.

Fork elements (elements with a `ForkParams` whose `fork_to_element` is set) add and connect
branches. The `fork_to_element` must be an element in a `Branch`. If that `Branch` is not
in `branches`, a copy of it is appended to the `Lattice`, and any forks in it are processed
in turn. Each fork element in the `Lattice` is given its own `ForkParams` whose
`fork_to_element` is the corresponding element in the `Lattice`. A fork to an element in
the fork's own `Branch` connects within that `Branch`, even if the `Branch` appears more
than once in `branches`. Otherwise, it is an error if the destination `Branch` appears more
than once.

## Example
```julia
bl1 = Beamline([Marker(E_ref=10e9, species_ref=Species("electron")), Drift(L=1)])
bl2 = Beamline([Drift(L=2)])

lattice = Lattice([Branch([bl1]), Branch([bl2])])
```

Forking from a ring to an extraction line:
```julia
extraction = Branch([Marker(name="ext_start"), Drift(L=3)]; name="extraction")
ring = Branch([Marker(E_ref=10e9, species_ref=Species("electron")), Drift(L=1),
               Fork(fork_to_element=extraction.beamlines[1].line[1]), Drift(L=1)]; name="ring")

lattice = Lattice([ring]) # Branches "ring" and "extraction"
```

---

    Lattice(beamlines::Vector{Beamline}; name = "", context = Context())

Constructs a `Lattice` containing a single `Branch` made up of the vector of
`Beamline`s `beamlines`. As with `Branch(beamlines)`, the `Branch` holds copies of the 
`Beamline`s and `beamlines` is not modified.

## Example
```julia
bl1 = Beamline([Marker(E_ref=10e9, species_ref=Species("electron")), Drift(L=1)])
bl2 = Beamline([Drift(L=2)])

lattice = Lattice([bl1, bl2]) # Equivalent to Lattice([Branch([bl1, bl2])])
```
"""
function Lattice(beamlines::Vector{Beamline}; name = "", context = Context())
  # The Branch is constructed here and referenced nowhere else, so the Lattice takes it as-is 
  # rather than copying it again: the Beamlines are already copied by the Branch constructor.
  return Lattice([Branch(beamlines)], name = name, context = context, _adopt = true)
end

#---------------------------------------------------------------------------------------------------

function Base.setproperty!(lat::Lattice, key::Symbol, value)
  if key == :name
    setfield!(lat, key, value)
  elseif key == :context
    setfield!(lat, :context, value)
  elseif key == :branches
    error("Unable to set property $key: this field is protected")
  else
    error("Unable to set property $key of Lattice: Lattice does not have this property")
  end
end

#---------------------------------------------------------------------------------------------------

function Base.show(io::IO, lat::Lattice)
  println(io, "Lattice: $(lat.name)")

  N_br = length(lat.branches)
  branch_table = Matrix{Any}(nothing, 1+N_br, 4)
  branch_table[1,:] = ["Index", "Name", "# Eles", "Length"]
  for (ix, branch) in enumerate(lat.branches)
    nele = length(branch)
    len = nele == 0 ? 0 : branch[nele].s_downstream
    branch_table[ix+1,:] = [ix, branch.name, nele, len]
  end

  offset = 6

  println(io, "Branches:")
  pretty_table(io, branch_table;
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