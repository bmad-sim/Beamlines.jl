module BeamlinesGTPSAExt
using GTPSA
using Beamlines: Species, massof, chargeof, C_LIGHT, DefExpr
import Beamlines: R_to_E, E_to_R, pc_to_R, R_to_pc, E_to_pc, pc_to_E, R_to_v, scalarize

# Particle energy conversions with @FastGTPSA
R_to_pc(species::Species, R::TPS)  = @FastGTPSA R*chargeof(species)*C_LIGHT
pc_to_R(species::Species, pc::TPS) = @FastGTPSA pc/C_LIGHT/chargeof(species)
R_to_E(species::Species, R::TPS)   = @FastGTPSA sqrt((R*C_LIGHT*chargeof(species))^2 + massof(species)^2)
pc_to_E(species::Species, pc::TPS) = @FastGTPSA sqrt(pc^2 + massof(species)^2)
function E_to_pc(species::Species, E::TPS)
  if E < massof(species)
    throw(DomainError(E, "E must be ≥ mass"))
  else
    return @FastGTPSA sqrt((E - massof(species))*(E + massof(species)))
  end
end
function E_to_R(species::Species, E::TPS)
  if E < massof(species)
    throw(DomainError(E, "E must be ≥ mass"))
  else
    return @FastGTPSA sqrt((E - massof(species))*(E + massof(species)))/C_LIGHT/chargeof(species)
  end
end
E_to_v(species::Species, E::TPS)   = @FastGTPSA sqrt((E - massof(species))*(E + massof(species))) * C_LIGHT / E
R_to_v(species::Species, R::TPS)   = @FastGTPSA R*C_LIGHT*chargeof(species) * C_LIGHT / sqrt((R*C_LIGHT*chargeof(species))^2 + massof(species)^2)
R_to_gamma(species::Species, R::TPS)      = @FastGTPSA sqrt((R*C_LIGHT*chargeof(species)/massof(species))^2 + 1)
R_to_beta_gamma(species::Species, R::TPS) = @FastGTPSA R*chargeof(species)*C_LIGHT/massof(species)
dR_to_dpc(species::Species, dR::TPS)  = @FastGTPSA dR*chargeof(species)*C_LIGHT
dpc_to_dR(species::Species, dpc::TPS) = @FastGTPSA dpc/C_LIGHT/chargeof(species)
dpc_to_dE(species::Species, pc0::TPS, dpc) =
  @FastGTPSA dpc*(2*pc0 + dpc) / (sqrt((pc0 + dpc)^2 + massof(species)^2) + sqrt(pc0^2 + massof(species)^2))
dpc_to_dE(species::Species, pc0, dpc::TPS) =
  @FastGTPSA dpc*(2*pc0 + dpc) / (sqrt((pc0 + dpc)^2 + massof(species)^2) + sqrt(pc0^2 + massof(species)^2))
dE_to_dpc(species::Species, E0::TPS, dE) =
  @FastGTPSA dE*(2*E0 + dE) / (sqrt((E0 + dE - massof(species))*(E0 + dE + massof(species))) +
                               sqrt((E0 - massof(species))*(E0 + massof(species))))
dE_to_dpc(species::Species, E0, dE::TPS) =
  @FastGTPSA dE*(2*E0 + dE) / (sqrt((E0 + dE - massof(species))*(E0 + dE + massof(species))) +
                               sqrt((E0 - massof(species))*(E0 + massof(species))))

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