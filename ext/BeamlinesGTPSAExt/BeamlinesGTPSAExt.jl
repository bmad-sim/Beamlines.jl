module BeamlinesGTPSAExt
using GTPSA
using Beamlines: Species, massof, chargeof, C_LIGHT, DefExpr
import Beamlines: R_to_E, E_to_R, pc_to_R, R_to_pc, E_to_pc, pc_to_E, scalarize

# Overrides for TPSA:
R_to_E(species_ref::Species, R::TPS) = @FastGTPSA sign(R)*sign(chargeof(species_ref))*sqrt((R*C_LIGHT*chargeof(species_ref))^2 + massof(species_ref)^2)
E_to_R(species_ref::Species, E::TPS) = @FastGTPSA sign(E)*massof(species_ref)*sinh(acosh(abs(E)/massof(species_ref)))/C_LIGHT/chargeof(species_ref)  # sqrt(E^2-massof(species_ref)^2)/C_LIGHT/chargeof(species_ref)
pc_to_R(species_ref::Species, pc::TPS) = @FastGTPSA pc/C_LIGHT/chargeof(species_ref)
R_to_pc(species_ref::Species, R::TPS) = @FastGTPSA R*chargeof(species_ref)*C_LIGHT
E_to_pc(species_ref::Species, E::TPS) = @FastGTPSA sign(E)*massof(species_ref)*sinh(acosh(abs(E)/massof(species_ref)))
pc_to_E(species_ref::Species, pc::TPS) = @FastGTPSA sign(pc)*sqrt((pc)^2 + massof(species_ref)^2)

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