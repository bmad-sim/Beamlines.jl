#---------------------------------------------------------------------------------------------------

"""
    Branch

Structure containing a vector of `Beamline`s, where currently each follows in-order, 
one after the other. 

## Properties
- `beamlines`: Vector of the beamlines in the `Branch`
- `lattice`: `Lattice` that the branch is placed in, if any
- `lattice_index`: Index of the branch in the `Lattice`, if in a `Lattice`
"""
const Branch = _Branch{Beamline}

#---------------------------------------------------------------------------------------------------

"""
    Lattice

Structure containing a vector of `Branch`es. 

## Properties
- `branches`: Vector of the branches in the `Lattice`
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
  name = :Inferred
  try 
    species_ref = branch.species_ref
    name = nameof(species_ref)
  catch
  end
  println(io, " species_ref", " = ", name)
  lines_used += 1
  ref = :Inferred 
  ref_meaning = refmeaning_to_sym(getfield(InitialBeamlineParams(), :ref_meaning)) # Default
  try
    ibp = first(branch.line).InitialBeamlineParams
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
    Branch(beamlines)

Constructs a `Branch` given the vector of beamlines `beamlines`.

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
    return Branch([Beamline(elements; species_ref=species_ref0, kwarg_sym=>kwarg_val)])
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

Base.propertynames(::Branch) = (:beamlines, :lattice, :lattice_index, :context)

function Base.getproperty(b::Branch, key::Symbol)
  prop = trygetproperty(b, key)
  if prop isa GetError
    error(prop.msg)
  end
  return prop
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
  elseif key in (:beamlines, :lattice, :lattice_index)
    error("Unable to set property $key: this field is protected")
  else
    error("Unable to set property $key of Branch: Branch does not have this property")
  end
end

#---------------------------------------------------------------------------------------------------

"""
    Lattice(branches)

Constructs a `Lattice` given the vector of branches `branches`.

## Example
```julia
bl1 = Beamline([Marker(E_ref=10e9, species_ref=Species("electron")), Drift(L=1)])
bl2 = Beamline([Drift(L=2)])

lattice = Lattice([Branch([bl1]), Branch([bl2])])
```

---

    Lattice(beamlines)

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

function Base.show(io::IO, lat::Lattice)
  println(io, "Lattice: $(lat.name)")

  N_br = length(lat.branches)
  branch_table = Matrix{Any}(nothing, 1+N_br, 4)
  branch_table[1,:] = ["Index", "Name", "# Eles", "Length"]
  for (ix, branch) in enumerate(lat.branches)
    nele = length(branch)
    branch_table[ix+1,:] = [ix, branch.name, nele, branch[nele].s_downstream]
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