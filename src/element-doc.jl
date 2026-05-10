

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

```jldoctest
ele = LineElement()
ele.L = 1   # Length 
ele.Kn1 = 2 # Normal quadrupole strength
ele.rf_frequency = 1e6 
```

For detailed descriptions of properties in a given parameter group, see the documentation 
for that parameter group.

"""
LineElement