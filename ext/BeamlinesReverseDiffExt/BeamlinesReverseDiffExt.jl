module BeamlinesReverseDiffExt
using ReverseDiff
import Beamlines: scalarize

# Scalarize
scalarize(t::Union{ReverseDiff.TrackedArray,ReverseDiff.TrackedReal}) = ReverseDiff.value(t)

end