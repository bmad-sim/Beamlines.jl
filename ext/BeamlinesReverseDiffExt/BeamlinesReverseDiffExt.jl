module BeamlinesReverseDiffExt
using ReverseDiff
import Beamlines: scalarize

# Scalarize
scalarize(
  t::Union{ReverseDiff.TrackedArray,ReverseDiff.TrackedReal}
) = scalarize(ReverseDiff.value(t))

end