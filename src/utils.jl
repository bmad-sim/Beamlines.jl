# Sign is included to ensure that values could be dE_ref, dp_over_q_ref, for example
R_to_E(species_ref::Species, R) = sign(R)*sign(chargeof(species_ref))*sqrt((R*C_LIGHT*chargeof(species_ref))^2 + massof(species_ref)^2)
E_to_R(species_ref::Species, E) = sign(E)*massof(species_ref)*sinh(acosh(abs(E)/massof(species_ref)))/C_LIGHT/chargeof(species_ref)  # sqrt(E^2-massof(species_ref)^2)/C_LIGHT/chargeof(species_ref)
pc_to_R(species_ref::Species, pc) = pc/C_LIGHT/chargeof(species_ref)
R_to_pc(species_ref::Species, R) = R*chargeof(species_ref)*C_LIGHT
E_to_pc(species_ref::Species, E) = sign(E)*massof(species_ref)*sinh(acosh(abs(E)/massof(species_ref)))
pc_to_E(species_ref::Species, pc) = sign(pc)*sqrt((pc)^2 + massof(species_ref)^2)
R_to_v(species::Species, R) = chargeof(species)*C_LIGHT / sqrt(1+(massof(species)/(R*C_LIGHT))^2)


