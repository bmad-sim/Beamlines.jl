# Particle energy conversions =============================================================
# Absolute conversions ------------------------------------------------------------------
R_to_pc(species::Species, R)  = R*chargeof(species)*C_LIGHT
pc_to_R(species::Species, pc) = pc/C_LIGHT/chargeof(species)

R_to_E(species::Species, R)   = sqrt((R*C_LIGHT*chargeof(species))^2 + massof(species)^2)
pc_to_E(species::Species, pc) = sqrt(pc^2 + massof(species)^2)

# (E-m)(E+m) avoids cancellation at low kinetic energy
function E_to_pc(species::Species, E)
  if E < massof(species)
    throw(DomainError(E, "E must be ≥ mass"))
  else
    return sqrt((E - massof(species))*(E + massof(species)))
  end
end
function E_to_R(species::Species, E)
  if E < massof(species)
    throw(DomainError(E, "E must be ≥ mass"))
  else
    return sqrt((E - massof(species))*(E + massof(species)))/C_LIGHT/chargeof(species)
  end
end

E_to_v(species::Species, E)   = sqrt((E - massof(species))*(E + massof(species))) * C_LIGHT / E
R_to_v(species::Species, R)   = R*C_LIGHT*chargeof(species) * C_LIGHT / sqrt((R*C_LIGHT*chargeof(species))^2 + massof(species)^2)
R_to_gamma(species::Species, R)      = sqrt((R*C_LIGHT*chargeof(species)/massof(species))^2 + 1)
R_to_beta_gamma(species::Species, R) = R*chargeof(species)*C_LIGHT/massof(species)

# Delta conversions ---------------------------------------------------------------------
# Linear: only the delta is needed.
dR_to_dpc(species::Species, dR)  = dR*chargeof(species)*C_LIGHT
dpc_to_dR(species::Species, dpc) = dpc/C_LIGHT/chargeof(species)

# Nonlinear: need the reference value (R0, pc0, E0). Uses a^2 - b^2 = (a-b)(a+b) so small
# deltas don't suffer cancellation.
dpc_to_dE(species::Species, pc0, dpc) =
  dpc*(2*pc0 + dpc) / (sqrt((pc0 + dpc)^2 + massof(species)^2) + sqrt(pc0^2 + massof(species)^2))

dE_to_dpc(species::Species, E0, dE) =
  dE*(2*E0 + dE) / (sqrt((E0 + dE - massof(species))*(E0 + dE + massof(species))) +
                               sqrt((E0 - massof(species))*(E0 + massof(species))))

dR_to_dE(species::Species, R0, dR) = dpc_to_dE(species, R_to_pc(species, R0), dR_to_dpc(species, dR))
dE_to_dR(species::Species, E0, dE) = dpc_to_dR(species, dE_to_dpc(species, E0, dE))
