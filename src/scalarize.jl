scalarize(t) = t
scalarize(t::AbstractArray) = scalarize.(t)