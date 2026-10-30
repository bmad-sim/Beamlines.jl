module BeamlinesForwardDiffExt
using ForwardDiff
import Beamlines: scalarize, scalarize_all

# Scalarize
scalarize(t::ForwardDiff.Dual) = ForwardDiff.value(t)
scalarize_all(t::ForwardDiff.Dual) = scalarize_all(ForwardDiff.value(t))

end