module BeamlinesReverseDiffExt
using ReverseDiff
import Beamlines: scalarize, scalarize_all

# Scalarize
scalarize(t::Union{ReverseDiff.TrackedArray,ReverseDiff.TrackedReal}) = ReverseDiff.value(t)
scalarize_all(t::ReverseDiff.TrackedReal) = scalarize_all(
    ReverseDiff.value(t))
scalarize_all(t::ReverseDiff.TrackedArray) = scalarize_all(
    ReverseDiff.value(t))

end