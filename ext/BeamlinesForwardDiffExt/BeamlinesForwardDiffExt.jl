module BeamlinesForwardDiffExt
using ForwardDiff
import Beamlines: scalarize

# Scalarize
scalarize(t::ForwardDiff.Dual) = scalarize(ForwardDiff.value(t))

end