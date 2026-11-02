module BeamlinesGTPSAExt
using GTPSA
using Beamlines: Species, massof, chargeof, C_LIGHT, DefExpr
import Beamlines: R_to_E, E_to_R, pc_to_R, R_to_pc, E_to_pc, pc_to_E, R_to_v, scalarize

# DefExpr
for t = (:unit, :sincu, :sinhc, :sinhcu, :asinc, :asincu, :asinhc, :asinhcu, :erf, 
         :erfc, :erfcx, :erfi, :wf, :rect)
@eval begin
GTPSA.$t(d::DefExpr) = DefExpr(()-> ($t)(d()))
end
end

# Scalarize
scalarize(t::TPS) = scalar(t)

end