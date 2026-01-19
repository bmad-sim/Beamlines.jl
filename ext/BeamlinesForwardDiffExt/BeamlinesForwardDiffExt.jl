module BeamlinesForwardDiffExt
using ForwardDiff
import Beamlines: scalarize

# Scalarize
scalarize(t::ForwardDiff.Dual) = ForwardDiff.value(t)

end