

struct _ParamInfo
  pg::Type{<:AbstractParams}
end

function Base.show(io::IO, pi::_ParamInfo)
  pg = pi.pg
  props = keys(PROPS(pg))
  width = maximum(length, props)
  println(io, nameof(pg))
  for prop in props
    println(io, " ", rpad(prop, width))
  end
  return
end

function _param_table_str()
  io = IOBuffer()
  ks = collect(keys(PARAMS_MAP))
  vs = collect(values(PARAMS_MAP))
  idxs = sortperm(String.(ks)) # Sort alphabetically

  # Put it all in a matrix
  ncols = 3 #displaysize(io)[2] < 100 ? 2 : 3
  nrows = div(length(vs), ncols, RoundUp)
  pgs = Matrix{Any}(nothing, ncols, nrows)

  idx = 1
  for v in vs[idxs]
    pgs[idx] =  _ParamInfo(v)
    idx += 1
  end

  pretty_table(io, permutedims(pgs);
    show_column_labels=false,
    line_breaks=true,
    alignment=:l,
    fit_table_in_display_horizontally=get(io, :limit, false),
    fit_table_in_display_vertically=get(io, :limit, false),
    table_format = TextTableFormat(borders = text_table_borders__borderless),
    new_line_at_end=false,
    formatters=[(v, i, j)-> isnothing(v) ? "" : v],
    backend=:text,
  )
  return String(take!(io))
end


"""
    LineElement
    
The basic building block which makes up a `Beamline`. May be something physical like a 
quadrupole magnet, or something non-physical like a point in the accelerator you want 
to mark. A `LineElement` may define a region in space distinguished by the presence of 
(possibly time-varying) electromagnetic fields, materials, apertures and other possible 
properties.

`LineElement` properties are split into "parameter groups" for convenient organization:
~~~text
$(_param_table_str())
~~~

To set a property, use the natural syntax:

```julia
ele = LineElement()
ele.L = 1   # Length 
ele.Kn1 = 2 # Normal quadrupole strength
ele.rf_frequency = 1e6 
```

For detailed descriptions of properties in a given parameter group, see the documentation 
for that parameter group.

## Ignoring parameter groups with `ignore_parameters`

The `ignore_parameters` property of a `LineElement`, part of its `UniversalParams`, is a
list of symbols. Any parameter group whose name is in this list is ignored in tracking,
without having to remove it from the element. This makes it easy to switch parameter groups
on and off:

```julia
ele = Quadrupole(L=0.5, Kn1=0.3, x_offset=1e-3)
ele.ignore_parameters = [:AlignmentParams] # Track as if the quadrupole were not misaligned
push!(ele.ignore_parameters, :BMultipoleParams) # Also ignore the multipoles
ele.ignore_parameters = []                 # Use all parameter groups again
```

`ignore_parameters` can also be set as a keyword argument, e.g.
`Quadrupole(L=0.5, Kn1=0.3, ignore_parameters=[:BMultipoleParams])`. A single symbol, or
strings, may also be given when setting `ignore_parameters`, e.g.
`ele.ignore_parameters = :AlignmentParams`.

When an element is placed in a `Beamline`, all instances of that element in the `Beamline`
share the `UniversalParams` of the original element, and therefore also its
`ignore_parameters` list. Setting `ignore_parameters` on the original element, or on any of
its instances in a `Beamline`, affects every instance.

Only symbols in `Beamlines.IGNORE_PARAMETERS_SYMBOLS` are allowed in `ignore_parameters`,
so that misspellings throw an error. By default, the allowed symbols are the names of the
parameter groups used in tracking: `:AlignmentParams`, `:ApertureParams`, `:BendParams`,
`:BMultipoleParams`, `:EMFieldParams`, `:EMultipoleParams`, `:FourPotentialParams`,
`:MapParams`, `:PatchParams`, and `:RFParams`. Custom symbols can be added with e.g.
`push!(Beamlines.IGNORE_PARAMETERS_SYMBOLS, :MyParams)`. The list is checked when it is
set, and again at the start of tracking through each element, which catches invalid symbols
added with e.g. `push!`.

Tracking code handles the list when unpacking an element: each parameter group whose name is
in `ignore_parameters` is replaced with `nothing` before tracking, exactly as if the element
did not have that parameter group.
"""
LineElement