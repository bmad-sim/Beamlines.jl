abstract type _AbstractBeamline end # Only subtype is Beamline

struct _Branch{T<:_AbstractBeamline}
  beamlines::ReadOnlyVector{T,Vector{T}}
  function _Branch{T}(beamlines::Vector{T}) where {T<:_AbstractBeamline}
    branch = new(ReadOnlyVector(beamlines))
    for i in eachindex(beamlines)
      bl = beamlines[i]
      if getfield(bl, :branch_index) != -1
        error("Beamline $i is already in another Branch!")
      end
      setfield!(bl, :branch, branch)
      setfield!(bl, :branch_index, i)
    end
    return branch
  end
end

@enumx RefMeaning p_over_q_ref E_ref pc_ref dp_over_q_ref dE_ref dpc_ref

@inline function refmeaning_to_sym(ref_meaning::RefMeaning.T)
  if ref_meaning == RefMeaning.p_over_q_ref
    return :p_over_q_ref
  elseif ref_meaning == RefMeaning.E_ref
    return :E_ref
  elseif ref_meaning == RefMeaning.pc_ref
    return :pc_ref
  elseif ref_meaning == RefMeaning.dp_over_q_ref
    return :dp_over_q_ref
  elseif ref_meaning == RefMeaning.dE_ref
    return :dE_ref
  else
    return :dpc_ref
  end
end

@inline function sym_to_refmeaning(sym::Symbol)
  if sym == :p_over_q_ref
    return RefMeaning.p_over_q_ref
  elseif sym == :E_ref
    return RefMeaning.E_ref
  elseif sym == :pc_ref
    return RefMeaning.pc_ref
  elseif sym == :dp_over_q_ref
    return RefMeaning.dp_over_q_ref
  elseif sym == :dE_ref
    return RefMeaning.dE_ref
  else
    return RefMeaning.dpc_ref
  end
end

mutable struct Beamline <: _AbstractBeamline
  const line::ReadOnlyVector{LineElement, Vector{LineElement}}
  branch::_Branch{Beamline} # This should be HARD to change, not allowed easily
  branch_index::Int         # This should be HARD to change, not allowed easily
  context::Context 
  @doc"""
      Beamline(line; kwargs...)

  Constructs a `Beamline` out of the `LineElement`s in the vector `line`. The `LineElement`s 
  in the `Beamline` will be automatically constructed as children of those `LineElement`s in 
  `line`, inheriting all of their properties. 
  
  The reference energy of the beamline may be optionally specified using one of the keyword 
  arguments: `E_ref`, `pc_ref`, `p_over_q_ref`, `dE_ref`, `dpc_ref`, or `dp_over_q_ref`.
  Whichever of these is specified will be the independent variable. The species of 
  the beamline may be optionally specified using the `species_ref` keyword argument.
  Specifying either of these keyword arguments will permanently override both the reference 
  species and energy defined in the first `LineElement` -- see the warning below.

  ## Examples
  ```julia
  qf = Quadrupole(Kn1=0.36, L=0.5)
  d = Drift(L=1)
  qd = Quadrupole(Kn1=-0.36, L=0.5)

  fodo = Beamline([qf, d, qd, d], species_ref=Species("electron"), E_ref=18e9)
  ```
  
  Alternatively, one can specify the reference species/energy in the first element:

  ```julia
  qf = Quadrupole(Kn1=0.36, L=0.5, species_ref=Species("electron"), E_ref=18e9)
  d = Drift(L=1)
  qd = Quadrupole(Kn1=-0.36, L=0.5)

  fodo = Beamline([qf, d, qd, d])
  ```

  ## Keyword arguments
  - `context`: A `Context` struct containing variables that can be stored in the beamline 
      for convenience
  - `species_ref`: Reference species of the beamline. 
  - `E_ref`: Total reference energy [eV]
  - `pc_ref`: Reference momentum [eV/c]
  - `p_over_q_ref`: A *signed* reference magnetic rigidity [T * m]
  - `dE_ref`: Change in total reference energy w.r.t. the directly-upstream beamline in 
      units [eV]
  - `dpc_ref`: Change in reference momentum w.r.t. the directly-upstream beamline in 
      units [eV/c]
  - `dp_over_q_ref`: Change in *signed* reference magnetic rigidty w.r.t. the directly 
      upstream beamline [T * m]

  !!! warning
      Keyword arguments specified to the `Beamline` constructor will permanently override any 
      corresponding properties specified in the first `LineElement` of the beamline. E.g., 
      ```julia
      beg = Marker(species_ref=Species("electron"), E_ref=18e9)

      a = Beamline([beg])
      b = Beamline([beg], species_ref=Species("proton"), E_ref=1e9)

      a.E_ref == beg.E_ref == 18e9 # true
      b.E_ref == 1e9               # true
      b.E_ref != beg.E_ref         # true

      # If `beg` is reset:
      beg.species_ref = Species("positron")

      # `a` will still inherit it, but `b` will not:
      a.species_ref == beg.species_ref   # true
      b.species_ref == Species("proton") # true
      b.species_ref != beg.species_ref   # true
      ```
  """
  function Beamline(
    line;
    species_ref::Union{Species,DefExpr{Species}}=Species(),  
    p_over_q_ref=nothing, 
    E_ref=nothing, 
    pc_ref=nothing,
    dp_over_q_ref=nothing, 
    dE_ref=nothing, 
    dpc_ref=nothing,
    context=Context(),
  )
    kwargs = (p_over_q_ref, E_ref, pc_ref, dp_over_q_ref, dE_ref, dpc_ref)
    kwarg_syms = (:p_over_q_ref, :E_ref, :pc_ref, :dp_over_q_ref, :dE_ref, :dpc_ref)
    c = count(t->!isnothing(t), kwargs)
    if c > 1
      error("Only one of $(kwarg_syms) can be specified")
    end
    
    if (c == 1 || !isnullspecies(species_ref)) # set occurring at Beamline ctor
      if length(line) < 1
        error("At least one LineElement must be included in the Beamline to specify a reference species/energy.")
      end
    end

    # For Python sanity and linear-indexing guarantee
    line = convert(Vector{LineElement}, vec(line))

    bl = new(ReadOnlyVector(Vector{LineElement}(undef, length(line))), NULL_BRANCH, -1, context)

    for i in eachindex(bl.line)
      if i != 1 && haskey(getfield(line[i], :pdict), InitialBeamlineParams)
        error("
          Cannot construct Beamline: element $i contains an InitialBeamlineParams 
          which can only be placed in the first element of a Beamline. To include 
          reference energy/species changes in the middle of an accelerator, use the 
          Branch constructor instead which will automatically construct separate 
          Beamlines for each InitialBeamlineParams.
        ")
      end
      bl.line.parent[i] = LineElement(ParamDict(InheritParams=>InheritParams(line[i])))
      getfield(bl.line[i], :pdict)[BeamlineParams] = BeamlineParams(bl, i)
    end

    if (c == 1 || !isnullspecies(species_ref)) # set occurring at Beamline ctor
      pdict1 = getfield(first(bl.line), :pdict)
      ibp = InitialBeamlineParams()
      pdict1[InitialBeamlineParams] = ibp # then override the parent
      # Initialize with values from parent if parent has it
      if haskey(pdict1, InheritParams)
        ppdict = getfield((pdict1[InheritParams]::InheritParams).parent, :pdict)
        if haskey(ppdict, InitialBeamlineParams)
          pibp = ppdict[InitialBeamlineParams]::InitialBeamlineParams
          setfield!(ibp, :ref_meaning, getfield(pibp, :ref_meaning))
          setfield!(ibp, :ref,         getfield(pibp, :ref))
          setfield!(ibp, :species_ref, getfield(pibp, :species_ref))
        end
      end
    end

    if c == 1 
      idx = findfirst(t->!isnothing(t), kwargs)
      sym = (:p_over_q_ref, :E_ref, :pc_ref, :dp_over_q_ref, :dE_ref, :dpc_ref)[idx]
      ref = (p_over_q_ref, E_ref, pc_ref, dp_over_q_ref, dE_ref, dpc_ref)[idx]
      setproperty!(first(bl.line), sym, ref)
    end

    if !isnullspecies(species_ref)
      setproperty!(first(bl.line), :species_ref, species_ref)
    end
    
    return bl
  end
end

PROPS(::Type{Beamline}) = OrderedDict{String,String}(
  "line"         => "A read-only array of `LineElements` in the beamline, in order",
  "context"     => "`Context` struct containing control variables associated with the beamline",
  "branch"       => "`Branch` that the beamline is placed in, if any",
  "branch_index" => "Index of the beamline in the `Branch`, if in a `Branch`",
)

"""
    Beamline

Structure containing a vector of `LineElement`s in an ordered sequence, and optionally 
a `Context` struct containing conrol variables associated with the beamline for 
convenience. The reference species (specified as `species_ref` and reference energy 
(specified as one of `E_ref`, `pc_ref`, `p_over_q_ref`, `dE_ref`, `dpc_ref`, or 
`dp_over_q_ref`) is uniform over the entire beamline. The most-recently specified of 
these reference energy quantites will be stored as the independent variable, in the 
first `LineElement` of the `Beamline`.

## Properties
$(PROPSDOC(Beamline))
"""
Beamline

"""
    empty!(::Beamline)

Removes `BeamlineParams` from all elements in the `Beamline` and empties 
the array of `LineElement`s.

WARNING: this is irreversible.
"""
function Base.empty!(bl::Beamline)
  for ele in bl.line
    delete!(getfield(ele, :pdict), BeamlineParams)
  end
  empty!(bl.line.parent)
  return bl
end

#show(io::IO, ::MIME"text/plain", bl::Beamline) = show(io, bl)
function Base.show(io::IO, bl::Beamline)
  println(io, "Beamline:")
  lines_used = 1
  name = :Inferred
  try 
    species_ref = bl.species_ref
    name = species_ref.name
  catch
  end
  println(io, " species_ref", " = ", name)
  lines_used += 1
  ref = :Inferred 
  ref_meaning = refmeaning_to_sym(getfield(InitialBeamlineParams(), :ref_meaning)) # Default
  try
    ibp = first(bl.line).InitialBeamlineParams
    ref_meaning = refmeaning_to_sym(ibp.ref_meaning)
    ref = ibp.ref 
  catch
  end
  println(io, " "*String(ref_meaning), " = ", param_repr(ref))
  lines_used += 1

  branch_index = getfield(bl, :branch_index)
  if branch_index != -1
    println(io, " branch_index", " = ", branch_index)
    lines_used += 1
  end

  offset = 6

  N_ele = length(bl.line)
  # Index, Name, Kind, s
  ele_table = Matrix{Any}(nothing, 1+N_ele, 5)
  ele_table[1,:] = ["Index", "Name", "Kind", "s [m]", "L [m]"]
  lines_used
  for i in 1:N_ele
    ele = bl.line[i]
    ele_table[i+1,:] = [ele.beamline_index, ele.name, ele.kind, param_repr(ele.s), param_repr(ele.L)]
    lines_used += 1
    if get(io, :limit, false) && lines_used > displaysize(io)[1]-offset
      break
    end
  end

  println(io)
  pretty_table(io, ele_table;
    limit_printing=get(io, :limit, false),
    alignment=:l,
    show_column_labels=false,
    fit_table_in_display_horizontally=get(io, :limit, false),
    fit_table_in_display_vertically=get(io, :limit, false),
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

"""
    Branch

Structure containing a vector of `Beamline`s, where currently each follows in-order, 
one after the other. 

## Properties
- `beamlines`: Vector of the beamlines in the `Branch`
"""
const Branch = _Branch{Beamline}
const NULL_BRANCH = Branch(Beamline[])

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
      beamlines[i] = Beamline(elements[idx0:idxf]; species_ref=species_ref0, kwarg_sym=>kwarg_val)
    else
      beamlines[i] = Beamline(elements[idx0:idxf])
    end
  end
  return Branch(beamlines)
end

Base.propertynames(::Beamline) = (:line, :branch, :branch_index, :context, :p_over_q_ref, :E_ref, :pc_ref, :dp_over_q_ref, :dE_ref, :dpc_ref, :species_ref)

function Base.getproperty(b::Beamline, key::Symbol)
  prop = trygetproperty(b, key)
  if prop isa GetError
    error(prop.msg)
  end
  return prop
end

function trygetproperty(b::Beamline, key::Symbol)
  # Fast gets first, hopefully constant prop
  if key in (:line, :branch, :branch_index, :context)
    field = getfield(b, key)
    if key in (:branch, :branch_index) && (field == -1 || field === NULL_BRANCH)
      return GetError("Unable to get $key: Beamline is not in a Branch")
    else
      return field
    end
  elseif key in (:E_ref, :pc_ref, :p_over_q_ref, :dE_ref, :dpc_ref, :dp_over_q_ref, :species_ref)
    if length(b.line) < 1
      branch_index = getfield(b, :branch_index)
      if branch_index == -1 || branch_index == 1
        return GetError("Unable to get $key: $key of the Beamline is not set nor inferrable")
      else
        return trygetproperty(getfield(b, :branch).beamlines[branch_index-1], key)
      end
    else
      return try_get_bl_params(first(b.line), key, getfield(b, :context))
    end
  else
    error("Unable to get property $key from Beamline: Beamline does not have this property")
  end
end

function Base.setproperty!(b::Beamline, key::Symbol, value)
  if key in (:line, :branch, :branch_index)
    error("Unable to set property $key: this field is protected")
  elseif key == :context
    setfield!(b, key, value)
  elseif key in (:E_ref, :pc_ref, :p_over_q_ref, :dE_ref, :dpc_ref, :dp_over_q_ref, :species_ref)
    if length(b.line) < 1
      error("Unable to set $key of Beamline with no elements")
    else
      return setproperty!(first(b.line), key, value)
    end
  else
    error("Unable to set property $key of Beamline: Beamline does not have this property")
  end
end

struct BeamlineParams <: AbstractParams
  beamline::Beamline
  beamline_index::Int
end

PROPS(::Type{BeamlineParams}) = OrderedDict{String,String}(
  "beamline"       => "`Beamline` that this `LineElement` is in",
  "beamline_index" => "Index of the `line` array of the `Beamline` that this element is at",
  "s"              => "Longitudinal position from the start of the `Beamline` at the entrance of the element [m]",
  "s_downstream"   => "Longitudinal position from the start of the `Beamline` at the exit of the element [m]",
  PROPS(Beamline)...,
)

"""
    BeamlineParams

Defines information for `LineElement`s that are in a `Beamline`.

## Properties
$(PROPSDOC(BeamlineParams))
"""
BeamlineParams


function Base.show(io::IO, bp::BeamlineParams)
  println(io, typeof(bp))
  width = length(" beamline_index") # longest String
  println(io, rpad(" beamline_index", width), " = ", bp.beamline_index)
  println(io, rpad(" s",width), " = ", param_repr(bp.s))
  println(io, rpad(" s_downstream",width), " = ", param_repr(bp.s_downstream))

  branch_index = getfield(bp.beamline, :branch_index)
  if branch_index != -1
    println(io, rpad(" branch_index", width), " = ", branch_index)
  end

  return
end

# Make E_ref and p_over_q_ref (in beamline) be properties
# Also make s a property of BeamlineParams
# Note that because BeamlineParams is immutable, not setting rn
Base.propertynames(::BeamlineParams) = (:beamline, :beamline_index, :s, :s_downstream, :p_over_q_ref, :E_ref, :pc_ref, :dp_over_q_ref, :dE_ref, :dpc_ref, :species_ref, :branch, :branch_index)

function Base.setproperty!(bp::BeamlineParams, key::Symbol, value)
  # only settable at first element
  if key in (:p_over_q_ref, :E_ref, :pc_ref, :dp_over_q_ref, :dE_ref, :dpc_ref)
    if bp.beamline_index == 1 # && !any(t->haskey(getfield(t, :pdict), InheritParams) && getfield(t, :pdict)[InheritParams].parent === ele, bp.beamline.line)
      return setproperty!(bp.beamline, key, value)
    else
      error("
        Property $key is a Beamline property, and therefore is only settable at 
        at the first element in a Beamline Consider setting $key at the Beamline 
        level (e.g. beamline.$key = $value), or setting this parameter in an element 
        prior to Branch construction to automatically generate a separate Beamline.
      ")
    end
  else
    return setproperty!(bp.beamline, key, value)
  end
end

function Base.getproperty(bp::BeamlineParams, key::Symbol)
  if key in (:p_over_q_ref, :E_ref, :pc_ref, :species_ref, :branch, :branch_index, :ref)
    return deval(getproperty(bp.beamline, key), getfield(bp.beamline, :context))
  elseif key in (:dp_over_q_ref, :dE_ref, :dpc_ref)
    if bp.beamline_index != 1
      return 0
    else
      return deval(getproperty(bp.beamline, key), getfield(bp.beamline, :context))
    end
  elseif key in (:s, :s_downstream)
    if key == :s
      n = bp.beamline_index - 1
      if n == 0
        return 0
      end
    else
      n = bp.beamline_index
    end
    # s is the sum of the lengths of all preceding elements
    line = bp.beamline.line
    return deval(sum(line[i].L for i in 1:n), getfield(bp.beamline, :context))
  else
    return getfield(bp, key)
  end
end

@kwdef mutable struct InitialBeamlineParams <: AbstractParams
  species_ref::Species       = Species()
  ref_meaning::RefMeaning.T  = RefMeaning.p_over_q_ref
  ref                        = nothing
end


PROPS(::Type{InitialBeamlineParams}) = OrderedDict{String,String}(
  "species_ref"   => "Reference species of the beamline",
  "E_ref"         => "Total reference energy [eV]",
  "pc_ref"        => "Reference momentum [eV/c]",
  "p_over_q_ref"  => "A *signed* reference magnetic rigidity [T * m]",
  "dE_ref"        => "Change in total reference energy w.r.t. the directly-upstream beamline [eV]",
  "dpc_ref"       => "Change in reference momentum w.r.t. the directly-upstream beamline [eV/c]",
  "dp_over_q_ref" => "Change in *signed* reference magnetic rigidty w.r.t. the directly-upstream beamline [T * m]",
)

"""
    InitialBeamlineParams

Defines the reference species and energy of the beamline. These parameters may be "set" in the 
first element of the beamline or at the `Beamline` level, and retrieved at any element in the 
beamline. If the reference species or energy is not set, then it will inherit that quantity from 
an upstream beamline if in a `Branch`.

## Properties
$(PROPSDOC(InitialBeamlineParams))
"""
InitialBeamlineParams

function Base.isapprox(a::InitialBeamlineParams, b::InitialBeamlineParams)
  return getfield(a, :ref) ≈ getfield(b, :ref) &&
          getfield(a, :ref_meaning) == getfield(b, :ref_meaning) &&
          getfield(a, :species_ref) == getfield(b, :species_ref) 
end

function Base.show(io::IO, ibp::InitialBeamlineParams)
  println(io, typeof(ibp))
  width = length(" species_ref") # longest String

  name = :Inferred
  try 
    species_ref = ibp.species_ref
    name = species_ref.name
  catch
  end
  println(io, rpad(" species_ref", width), " = ", name)

  ref = :Inferred
  try
    ref = ibp.ref
  catch
  end
  ref_meaning = refmeaning_to_sym(ibp.ref_meaning)
  println(io, rpad((" "*String(ref_meaning)), width), " = ", param_repr(ref))
  return
end

function Base.setproperty!(ibp::InitialBeamlineParams, key::Symbol, value)
  if key in (:E_ref, :p_over_q_ref, :pc_ref, :dE_ref, :dp_over_q_ref, :dpc_ref)
    setfield!(ibp, :ref_meaning, sym_to_refmeaning(key))
    setfield!(ibp, :ref, value)
  else
    setfield!(ibp, key, value)
  end
  return value
end

function Base.getproperty(ibp::InitialBeamlineParams, key::Symbol)
  prop = trygetproperty(ibp, key)
  if prop isa GetError
    error(prop.msg)
  end
  return prop
end

function trygetproperty(ibp::InitialBeamlineParams, key::Symbol)
  if key in (:ref, :species_ref, :ref_meaning)
    field = deval(getfield(ibp, key))
    if key == :ref && isnothing(field)
      return GetError("Unable to get ref: ref has not been set")
    elseif key == :species_ref && isnullspecies(field)
      return GetError("Unable to get species_ref: species_ref has not been set")
    end
    return field
  else
    ref_meaning = refmeaning_to_sym(getfield(ibp, :ref_meaning))
    if key == ref_meaning
      ref = trygetproperty(ibp, :ref)
      if ref isa GetError
        return GetError("Unable to get $key: $key has not be set.")
      end
      return ref
    elseif key in (:p_over_q_ref, :E_ref, :pc_ref) && ref_meaning in (:p_over_q_ref, :E_ref, :pc_ref)
      species_ref = trygetproperty(ibp, :species_ref)
      if species_ref isa GetError
        # Make it more informative:
        return GetError("
          Unable to get $key: stored is $ref_meaning and computing $key requires a species_ref,
          which has not been set.
        ")
      end
      ref = trygetproperty(ibp, :ref)
      if ref isa GetError
        return GetError("Unable to get $key: $ref_meaning has not be set.")
      end
      return ref_abs_convert(key, ref, ref_meaning, species_ref)
    else
      return GetError("
        Unable to get property $key: InitialBeamlineParams has stored $(ibp.ref_meaning), and
        so property $key depends on an upstream Branch which has not been constructed yet.
      ")
    end
  end
end

function scalarize(a::InitialBeamlineParams)
  return InitialBeamlineParams(
    scalarize(getfield(a, :species_ref)),
    scalarize(getfield(a, :ref_meaning)),
    scalarize(getfield(a, :ref)),
  )
end