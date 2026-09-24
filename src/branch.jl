#---------------------------------------------------------------------------------------------------

"""
    Branch

Structure containing a vector of `Beamline`s, where currently each follows in-order, 
one after the other. 

## Properties
- `name`: Name of the `Branch`. Default is `""` if not in a lattice and if in a lattice,
  the default is `"bN"` where `N` is the index of the branch in `lattice.branches[]`
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
- `branches`: Vector of the branches in the `Lattice`
- `context`: `Context` shared by the `Lattice`, all of its `Branch`es, and all of their
    `Beamline`s. Setting the `context` of any of them sets it for all of them.
"""
const Lattice = _Lattice{Branch}

#---------------------------------------------------------------------------------------------------

# NULL_LATTICE must be defined before NULL_BRANCH: the `_Branch` constructor references it. 
# Both are constructed from empty vectors.

const NULL_LATTICE = Lattice(Branch[])
const NULL_BRANCH = Branch(Beamline[])

Base.show(io::IO, ::Type{Branch}) = print(io, "Branch")
Base.show(io::IO, ::Type{Lattice}) = print(io, "Lattice")

#---------------------------------------------------------------------------------------------------

function Base.show(io::IO, branch::Branch)
  println(io, "Branch: $(branch.name)")
  lines_used = 1
  # The reference species and energy shown are those at the start of the Branch.
  name = :Inferred
  try
    species_ref = first(branch.beamlines).species_ref
    name = nameof(species_ref)
  catch
  end
  println(io, " species_ref", " = ", name)
  lines_used += 1
  ref = :Inferred
  ref_meaning = refmeaning_to_sym(getfield(InitialBeamlineParams(), :ref_meaning)) # Default
  try
    ibp = first(first(branch.beamlines).line).InitialBeamlineParams
    ref_meaning = refmeaning_to_sym(ibp.ref_meaning)
    ref = ibp.ref 
  catch
  end
  println(io, " "*String(ref_meaning), " = ", param_repr(ref))
  lines_used += 1

  lattice_index = getfield(branch, :lattice_index)
  if lattice_index != -1
    println(io, " lattice_index", " = ", lattice_index)
    lines_used += 1
  end

  offset = 6

  N_ele = length(branch)
  # Index, Name, Kind, s
  ele_table = Matrix{Any}(nothing, 1+N_ele, 6)
  ele_table[1,:] = ["Index", "Name", "Kind", "L [m]", "s [m]", "s_exit [m]"]

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

Copy of `branch` that is not in any `Lattice`. Since a `line` can only be in one `Branch`,
each `Beamline` of the copy has a new `line` whose `LineElement`s are children of those in 
`branch`. The `Context` is copied.
"""
Base.copy(branch::Branch) = Branch(Beamline[Beamline(collect(bl.line)) for bl in branch.beamlines]; 
                                   name = branch.name, context = copy(branch.context))

#---------------------------------------------------------------------------------------------------

"""
    _set_context!(branch::_Branch, context::Context)

Set the context for a branch and sets the contexts in the beamlines of the branch to `NULL_CONTEXT`. 
"""
function _set_context!(branch::_Branch, context::Context)
  setfield!(branch, :context, context)
  for bl in getfield(branch, :beamlines)
    setfield!(bl, :context, NULL_CONTEXT)
  end
  return
end

#---------------------------------------------------------------------------------------------------

"""
    Branch(beamlines; name = "", context = Context())

Constructs a `Branch` given the vector of beamlines `beamlines`. The `Branch` holds shallow
copies (see `copy(::Beamline)`) of the `Beamline`s: each copy shares the `line` of the 
corresponding `Beamline` in `beamlines`, and the `LineElement`s of that line are set to point 
to the copy. A `line` can only be in one `Branch`. The contexts of the `Beamline`s and 
`context` are merged into a single `Context` shared by the `Branch` and all of its `Beamline`s. 
Variables in `context` take precedence over those in the `Beamline`s.

## Example
```julia
ele = LineElement()
bl1 = Beamline([ele], E_ref=2e9, species_ref=Species("electron"))
bl2 = Beamline([ele], dE_ref=1e9)

branch = Branch([bl1, bl2])
```

---

    Branch(elements; kwargs...)

Constructs a `Branch` given the vector of `LineElement`s `elements`. This will 
automatically partition the given vector into separate `Beamline`s, which each 
have a uniform reference species and reference energy.

## Example
```julia
beginning = Marker(E_ref=10e9, species_ref=Species("electron"))
rf0 = RFCavity(dE_ref=1e9)
next = LineElement()

branch = Branch([beginning, rf0, next]) # Partitioned into 2 `Beamline`s
```
"""
function Branch(
  elements::AbstractArray{<:LineElement};
  species_ref0::Species=Species(),
  E_ref0=nothing,
  p_over_q_ref0=nothing,
  pc_ref0=nothing,
  context = Context(),
)
  kwargs = (p_over_q_ref0, E_ref0, pc_ref0)
  kwarg_syms = (:p_over_q_ref, :E_ref, :pc_ref)
  c = count(t->!isnothing(t), kwargs)
  if c > 1
    error("Only one of E_ref0, pc_ref0, p_over_q_ref0 can be specified")
  end
  kwarg_idx = findfirst(t->!isnothing(t), kwargs)
  kwarg_val = isnothing(kwarg_idx) ? nothing : kwargs[kwarg_idx]
  kwarg_sym = isnothing(kwarg_idx) ? :p_over_q_ref : kwarg_syms[kwarg_idx] 
  
  # Determine all indices with InitialBeamlineParams
  idxs = findall(t->haskey(getfield(t, :pdict), InitialBeamlineParams), elements)
  # If none, then only single Beamline
  if length(idxs) == 0
    return Branch([Beamline(elements; species_ref=species_ref0, kwarg_sym=>kwarg_val, context = context)], context = context)
  end

  n_beamlines = length(idxs)
  beamlines = Vector{Beamline}(undef, n_beamlines)
  for i in 1:n_beamlines
    idx0 = idxs[i]
    if i == n_beamlines
      idxf = length(elements)
    else
      idxf = idxs[i+1]-1
    end

    if i == 1
      beamlines[i] = Beamline(elements[idx0:idxf]; species_ref=species_ref0, kwarg_sym=>kwarg_val, context = context)
    else
      beamlines[i] = Beamline(elements[idx0:idxf], context = context)
    end
  end
  return Branch(beamlines, context = context)
end

#---------------------------------------------------------------------------------------------------

Base.propertynames(::Branch) = (:name, :beamlines, :lattice, :lattice_index, :context)

function Base.getproperty(branch::Branch, key::Symbol)
  if key == :context
    if getfield(branch, :lattice_index) == -1
      return getfield(branch, :context)
    else
      lat = getfield(branch, :lattice)
      return getfield(lat, :context)
    end

  else
    prop = trygetproperty(branch, key)
    if prop isa GetError
      error(prop.msg)
    end
    return prop
  end
end

function trygetproperty(b::Branch, key::Symbol)
  if key in (:beamlines, :lattice, :lattice_index, :name, :context)
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
      _set_context!(b, value)
    else 
      lat = getfield(b, :lattice)
      setfield!(lat, :context, value)
      for br in lat.branches
        _set_context!(br, value)
      end
    end
  elseif key in (:beamlines, :lattice, :lattice_index)
    error("Unable to set property $key: this field is protected")
  else
    error("Unable to set property $key of Branch: Branch does not have this property")
  end
end

#---------------------------------------------------------------------------------------------------

"""
    Lattice(branches; name = "", context = Context())

Constructs a `Lattice` given the vector of branches `branches`. Branches without a name
are named `"b<i>"`, where `<i>` is the index of the branch. The contexts of the `Branch`es
and `context` are merged into a single `Context` shared by the `Lattice`, all of its
`Branch`es, and all of their `Beamline`s. Variables in `context` take precedence over those
in the `Branch`es.

## Example
```julia
bl1 = Beamline([Marker(E_ref=10e9, species_ref=Species("electron")), Drift(L=1)])
bl2 = Beamline([Drift(L=2)])

lattice = Lattice([Branch([bl1]), Branch([bl2])])
```

---

    Lattice(beamlines; name = "", context = Context())

Constructs a `Lattice` containing a single `Branch` made up of the vector of
`Beamline`s `beamlines`.

## Example
```julia
bl1 = Beamline([Marker(E_ref=10e9, species_ref=Species("electron")), Drift(L=1)])
bl2 = Beamline([Drift(L=2)])

lattice = Lattice([bl1, bl2]) # Equivalent to Lattice([Branch([bl1, bl2])])
```
"""
function Lattice(beamlines::Vector{Beamline}; name = "", context = Context())
  return Lattice([Branch(beamlines)], name = name, context = context)
end

#---------------------------------------------------------------------------------------------------

function Base.setproperty!(lat::Lattice, key::Symbol, value)
  if key == :name
    setfield!(lat, key, value)
  elseif key == :context
    setfield!(lat, :context, value) # Branches and Beamlines in the Lattice use this Context
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