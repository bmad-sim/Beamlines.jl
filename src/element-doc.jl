

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

## The `pdict` field

A `LineElement` struct has a single field, `pdict`, which is a `ParamDict` (an alias for
`Dict{Type{<:AbstractParams}, AbstractParams}`). It stores the element's parameter groups,
each keyed by its own type, e.g. `pdict[BendParams]` is a `BendParams`. Setting an entry
whose value is not of the key type throws an error. An element only holds the parameter
groups that have been set, so e.g. a `Drift` has no `BMultipoleParams`. Every element
constructed with the default `LineElement` constructor starts with a `UniversalParams`.

All properties are stored in, or computed from, the parameter groups in `pdict`:

- Getting a parameter group that is not in `pdict` (e.g. `ele.BendParams`) returns
  `nothing`, and setting a parameter group to `nothing` removes it from `pdict`.
- Getting a property whose parameter group is not in `pdict` returns the default value
  of that property, and setting the property adds the parameter group to `pdict`.
- The elements in a `Beamline` are separate `LineElement`s whose `pdict` holds only an
  `InheritParams`, pointing to the original element, and a `BeamlineParams`. Any other
  parameter group is read from and written to the `pdict` of the original element.

`pdict` should not be accessed directly: `ele.pdict` throws an error. Use
`ele.<parameter group name>` to get or set a whole parameter group instead. Internal code
that needs the dictionary itself uses `getfield(ele, :pdict)`, which bypasses `ProtectParams`
and `InheritParams`.

`fieldnames(LineElement)` is therefore just `(:pdict,)`, while `propertynames(ele)` lists
every name that can be used as `ele.<name>`, i.e. the parameter groups and all of their
properties, including virtual properties such as `Kn1L`.
"""
LineElement