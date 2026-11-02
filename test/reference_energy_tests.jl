@testset "Reference params: standalone Beamline (not in a Branch)" begin
  # Stored absolute: absolute keys work (given species), all relative keys need an upstream Beamline
  bl = Beamline([Marker()]; E_ref=10e9, species_ref=Species("proton"))
  @test bl.E_ref == 10e9
  @test bl.pc_ref ≈ Beamlines.E_to_pc(Species("proton"), 10e9)
  @test bl.p_over_q_ref ≈ Beamlines.E_to_R(Species("proton"), 10e9)
  @test_throws ErrorException bl.dE_ref
  @test_throws ErrorException bl.dpc_ref
  @test_throws ErrorException bl.dp_over_q_ref

  bl = Beamline([Marker()]; pc_ref=9e9, species_ref=Species("electron"))
  @test bl.pc_ref == 9e9
  @test bl.E_ref ≈ Beamlines.pc_to_E(Species("electron"), 9e9)
  @test bl.p_over_q_ref ≈ Beamlines.pc_to_R(Species("electron"), 9e9)
  @test bl.p_over_q_ref < 0 # electron: negative charge
  @test_throws ErrorException bl.dE_ref
  @test_throws ErrorException bl.dpc_ref
  @test_throws ErrorException bl.dp_over_q_ref

  bl = Beamline([Marker()]; p_over_q_ref=30.0, species_ref=Species("proton"))
  @test bl.p_over_q_ref == 30.0
  @test bl.pc_ref ≈ Beamlines.R_to_pc(Species("proton"), 30.0)
  @test bl.E_ref ≈ Beamlines.R_to_E(Species("proton"), 30.0)
  @test_throws ErrorException bl.dE_ref
  @test_throws ErrorException bl.dpc_ref
  @test_throws ErrorException bl.dp_over_q_ref

  # Stored relative: only the stored key works, everything else needs a Branch
  bl = Beamline([Marker()]; dE_ref=-3e9, species_ref=Species("proton"))
  @test bl.dE_ref == -3e9
  @test_throws ErrorException bl.dpc_ref
  @test_throws ErrorException bl.dp_over_q_ref
  @test_throws ErrorException bl.E_ref
  @test_throws ErrorException bl.pc_ref
  @test_throws ErrorException bl.p_over_q_ref

  bl = Beamline([Marker()]; dpc_ref=-2e9, species_ref=Species("proton"))
  @test bl.dpc_ref == -2e9
  @test_throws ErrorException bl.dE_ref
  @test_throws ErrorException bl.dp_over_q_ref
  @test_throws ErrorException bl.E_ref
  @test_throws ErrorException bl.pc_ref
  @test_throws ErrorException bl.p_over_q_ref

  bl = Beamline([Marker()]; dp_over_q_ref=-5.0, species_ref=Species("proton"))
  @test bl.dp_over_q_ref == -5.0
  @test_throws ErrorException bl.dE_ref
  @test_throws ErrorException bl.dpc_ref
  @test_throws ErrorException bl.E_ref
  @test_throws ErrorException bl.pc_ref
  @test_throws ErrorException bl.p_over_q_ref

  # No species: the stored key works, conversions need a species
  bl = Beamline([Marker()]; E_ref=10e9)
  @test bl.E_ref == 10e9
  @test_throws ErrorException bl.pc_ref
  @test_throws ErrorException bl.p_over_q_ref

  bl = Beamline([Marker()]; pc_ref=9e9)
  @test bl.pc_ref == 9e9
  @test_throws ErrorException bl.E_ref
  @test_throws ErrorException bl.p_over_q_ref

  # Absolute from absolute for all species (standalone)
  for sp in (Species("electron"), Species("positron"), Species("proton"), Species("anti-proton"), Species("deuteron"))
    blE = Beamline([Marker()]; E_ref=10e9, species_ref=sp)
    blP = Beamline([Marker()]; pc_ref=9e9, species_ref=sp)
    blR = Beamline([Marker()]; p_over_q_ref=Beamlines.pc_to_R(sp, 8e9), species_ref=sp)
    @test blE.pc_ref ≈ Beamlines.E_to_pc(sp, 10e9)
    @test blE.p_over_q_ref ≈ Beamlines.E_to_R(sp, 10e9)
    @test blP.E_ref ≈ Beamlines.pc_to_E(sp, 9e9)
    @test blP.p_over_q_ref ≈ Beamlines.pc_to_R(sp, 9e9)
    @test blR.pc_ref ≈ 8e9
    @test blR.E_ref ≈ Beamlines.R_to_E(sp, Beamlines.pc_to_R(sp, 8e9))
    @test sign(blE.p_over_q_ref) == sign(Beamlines.chargeof(sp))
    @test sign(blP.p_over_q_ref) == sign(Beamlines.chargeof(sp))
  end
end

@testset "Reference params: first Beamline in a Branch (starts from rest)" begin
  # "Before" the first Beamline is a particle at rest: E = m, pc = 0, p_over_q = 0
  for sp in (Species("electron"), Species("positron"), Species("proton"), Species("anti-proton"), Species("deuteron"))
    m = Beamlines.massof(sp)

    # Stored E_ref
    bl = Beamline([Marker()]; E_ref=10e9, species_ref=sp)
    b, = Branch([bl]).beamlines
    @test b.E_ref == 10e9
    @test b.dE_ref ≈ 10e9 - m
    @test b.pc_ref ≈ Beamlines.E_to_pc(sp, 10e9)
    @test b.dpc_ref ≈ Beamlines.E_to_pc(sp, 10e9)
    @test b.p_over_q_ref ≈ Beamlines.E_to_R(sp, 10e9)
    @test b.dp_over_q_ref ≈ Beamlines.E_to_R(sp, 10e9)

    # Stored pc_ref
    bl = Beamline([Marker()]; pc_ref=9e9, species_ref=sp)
    b, = Branch([bl]).beamlines
    @test b.pc_ref == 9e9
    @test b.dpc_ref == 9e9
    @test b.E_ref ≈ Beamlines.pc_to_E(sp, 9e9)
    @test b.dE_ref ≈ Beamlines.pc_to_E(sp, 9e9) - m
    @test b.p_over_q_ref ≈ Beamlines.pc_to_R(sp, 9e9)
    @test b.dp_over_q_ref ≈ Beamlines.pc_to_R(sp, 9e9)

    # Stored p_over_q_ref
    R = Beamlines.pc_to_R(sp, 8e9)
    bl = Beamline([Marker()]; p_over_q_ref=R, species_ref=sp)
    b, = Branch([bl]).beamlines
    @test b.p_over_q_ref == R
    @test b.dp_over_q_ref == R
    @test b.pc_ref ≈ 8e9
    @test b.dpc_ref ≈ 8e9
    @test b.E_ref ≈ Beamlines.R_to_E(sp, R)
    @test b.dE_ref ≈ Beamlines.R_to_E(sp, R) - m

    # Stored dE_ref
    bl = Beamline([Marker()]; dE_ref=9e9, species_ref=sp)
    b, = Branch([bl]).beamlines
    @test b.dE_ref == 9e9
    @test b.E_ref ≈ m + 9e9
    @test b.pc_ref ≈ Beamlines.E_to_pc(sp, m + 9e9)
    @test b.dpc_ref ≈ Beamlines.E_to_pc(sp, m + 9e9)
    @test b.p_over_q_ref ≈ Beamlines.E_to_R(sp, m + 9e9)
    @test b.dp_over_q_ref ≈ Beamlines.E_to_R(sp, m + 9e9)

    # Stored dpc_ref
    bl = Beamline([Marker()]; dpc_ref=8e9, species_ref=sp)
    b, = Branch([bl]).beamlines
    @test b.dpc_ref == 8e9
    @test b.pc_ref == 8e9
    @test b.E_ref ≈ Beamlines.pc_to_E(sp, 8e9)
    @test b.dE_ref ≈ Beamlines.pc_to_E(sp, 8e9) - m
    @test b.p_over_q_ref ≈ Beamlines.pc_to_R(sp, 8e9)
    @test b.dp_over_q_ref ≈ Beamlines.pc_to_R(sp, 8e9)

    # Stored dp_over_q_ref
    bl = Beamline([Marker()]; dp_over_q_ref=R, species_ref=sp)
    b, = Branch([bl]).beamlines
    @test b.dp_over_q_ref == R
    @test b.p_over_q_ref == R
    @test b.pc_ref ≈ 8e9
    @test b.dpc_ref ≈ 8e9
    @test b.E_ref ≈ Beamlines.R_to_E(sp, R)
    @test b.dE_ref ≈ Beamlines.R_to_E(sp, R) - m
  end

  # Exactly at rest (this hits the 0/0 guard in the dE conversions)
  sp = Species("proton")
  m = Beamlines.massof(sp)
  bl = Beamline([Marker()]; E_ref=m, species_ref=sp)
  b, = Branch([bl]).beamlines
  @test b.E_ref == m
  @test b.dE_ref == 0
  @test b.pc_ref == 0
  @test b.dpc_ref == 0
  @test b.p_over_q_ref == 0
  @test b.dp_over_q_ref == 0

  bl = Beamline([Marker()]; dE_ref=0.0, species_ref=sp)
  b, = Branch([bl]).beamlines
  @test b.E_ref == m
  @test b.dE_ref == 0
  @test b.pc_ref == 0
  @test b.dpc_ref == 0
  @test b.p_over_q_ref == 0
  @test b.dp_over_q_ref == 0

  bl = Beamline([Marker()]; pc_ref=0.0, species_ref=sp)
  b, = Branch([bl]).beamlines
  @test b.E_ref == m
  @test b.dE_ref == 0
  @test b.dpc_ref == 0
  @test b.dp_over_q_ref == 0

  bl = Beamline([Marker()]; dpc_ref=0.0, species_ref=sp)
  b, = Branch([bl]).beamlines
  @test b.E_ref == m
  @test b.pc_ref == 0
  @test b.dE_ref == 0

  bl = Beamline([Marker()]; dp_over_q_ref=0.0, species_ref=sp)
  b, = Branch([bl]).beamlines
  @test b.E_ref == m
  @test b.pc_ref == 0
  @test b.dE_ref == 0

  # Charge signs
  for (name, sgn) in (("electron", -1), ("positron", 1), ("proton", 1), ("anti-proton", -1))
    bl = Beamline([Marker()]; E_ref=10e9, species_ref=Species(name))
    b, = Branch([bl]).beamlines
    @test sign(b.p_over_q_ref) == sgn
    @test sign(b.dp_over_q_ref) == sgn
    @test b.pc_ref > 0
    @test b.dpc_ref > 0
  end

  # Species required (energy family at rest needs the mass; conversions need species)
  bl = Beamline([Marker()]; dE_ref=1e9)
  b, = Branch([bl]).beamlines
  @test b.dE_ref == 1e9
  @test_throws ErrorException b.E_ref
  @test_throws ErrorException b.pc_ref
  @test_throws ErrorException b.dpc_ref

  bl = Beamline([Marker()]; dpc_ref=1e9)
  b, = Branch([bl]).beamlines
  @test b.dpc_ref == 1e9
  @test b.pc_ref == 1e9 # same family, no species needed
  @test_throws ErrorException b.E_ref
  @test_throws ErrorException b.p_over_q_ref
  @test_throws ErrorException b.dE_ref

  bl = Beamline([Marker()]; E_ref=10e9)
  b, = Branch([bl]).beamlines
  @test b.E_ref == 10e9
  @test_throws ErrorException b.pc_ref
  @test_throws ErrorException b.dE_ref # needs the rest mass, i.e. the species

  bl = Beamline([Marker()]; pc_ref=9e9)
  b, = Branch([bl]).beamlines
  @test b.pc_ref == 9e9
  @test b.dpc_ref == 9e9 # same family, no species needed
  @test_throws ErrorException b.E_ref
  @test_throws ErrorException b.dE_ref

  # Unphysical energy
  bl = Beamline([Marker()]; E_ref=0.5*Beamlines.massof(Species("proton")), species_ref=Species("proton"))
  b, = Branch([bl]).beamlines
  @test_throws DomainError b.pc_ref
  @test_throws DomainError b.p_over_q_ref
end

@testset "Reference params: two Beamlines, same species, every stored combination" begin
  for sp in (Species("electron"), Species("positron"), Species("proton"), Species("anti-proton"), Species("deuteron"))
    m = Beamlines.massof(sp)
    inits1 = (
      (:E_ref, 10e9), (:pc_ref, 9e9), (:p_over_q_ref, Beamlines.pc_to_R(sp, 8e9)),
      (:dE_ref, 9e9), (:dpc_ref, 8e9), (:dp_over_q_ref, Beamlines.pc_to_R(sp, 7e9)),
    )
    inits2 = (
      (:E_ref, 7e9), (:pc_ref, 6e9), (:p_over_q_ref, Beamlines.pc_to_R(sp, 6.5e9)),
      (:dE_ref, -3e9), (:dpc_ref, -2e9), (:dp_over_q_ref, Beamlines.pc_to_R(sp, -2.5e9)),
    )
    for (k1, v1) in inits1, (k2, v2) in inits2
      bl1 = Beamline([Marker()]; Dict(k1 => v1, :species_ref => sp)...)
      bl2 = Beamline([Marker()]; Dict(k2 => v2)...) # species inherited from bl1
      branch = Branch([bl1, bl2])
      b1, b2 = branch.beamlines

      # What was stored comes back exactly
      @test getproperty(b1, k1) == v1
      @test getproperty(b2, k2) == v2
      @test b1.species_ref == sp
      @test b2.species_ref == sp

      # All of E, pc, p_over_q are mutually consistent in each Beamline
      for b in (b1, b2)
        @test b.E_ref > m
        @test b.pc_ref ≈ Beamlines.E_to_pc(sp, b.E_ref)
        @test b.p_over_q_ref ≈ Beamlines.E_to_R(sp, b.E_ref)
        @test b.E_ref ≈ Beamlines.pc_to_E(sp, b.pc_ref)
        @test b.E_ref ≈ Beamlines.R_to_E(sp, b.p_over_q_ref)
        @test b.pc_ref ≈ Beamlines.R_to_pc(sp, b.p_over_q_ref)
        @test b.p_over_q_ref ≈ Beamlines.pc_to_R(sp, b.pc_ref)
      end

      # First Beamline: delta is from rest
      @test b1.dE_ref ≈ b1.E_ref - m
      @test b1.dpc_ref ≈ b1.pc_ref
      @test b1.dp_over_q_ref ≈ b1.p_over_q_ref

      # Second Beamline: delta is the change from the first Beamline
      @test b2.E_ref - b1.E_ref ≈ b2.dE_ref rtol=1e-8 atol=1e-14*abs(b1.E_ref)
      @test b2.pc_ref - b1.pc_ref ≈ b2.dpc_ref rtol=1e-8 atol=1e-14*abs(b1.pc_ref)
      @test b2.p_over_q_ref - b1.p_over_q_ref ≈ b2.dp_over_q_ref rtol=1e-8 atol=1e-14*abs(b1.p_over_q_ref)

      # Deltas are mutually consistent (dE = pc dpc / E style relation via absolutes)
      @test b2.dE_ref ≈ Beamlines.pc_to_E(sp, b2.pc_ref) - Beamlines.pc_to_E(sp, b1.pc_ref) rtol=1e-8 atol=1e-14*abs(b1.E_ref)
      @test b2.dpc_ref ≈ Beamlines.E_to_pc(sp, b2.E_ref) - Beamlines.E_to_pc(sp, b1.E_ref) rtol=1e-8 atol=1e-14*abs(b1.pc_ref)
      @test b2.dp_over_q_ref ≈ Beamlines.pc_to_R(sp, b2.dpc_ref) rtol=1e-12 # linear
    end
  end
end

@testset "Reference params: two Beamlines, species changes, every stored combination" begin
  for (sp1, sp2) in (
      (Species("electron"), Species("proton")),
      (Species("proton"), Species("electron")),
      (Species("proton"), Species("anti-proton")),
      (Species("electron"), Species("positron")),
      (Species("deuteron"), Species("proton")),
      (Species("positron"), Species("anti-proton")),
  )
    m1 = Beamlines.massof(sp1)
    m2 = Beamlines.massof(sp2)
    inits1 = (
      (:E_ref, 10e9), (:pc_ref, 9e9), (:p_over_q_ref, Beamlines.pc_to_R(sp1, 8e9)),
      (:dE_ref, 9e9), (:dpc_ref, 8e9), (:dp_over_q_ref, Beamlines.pc_to_R(sp1, 7e9)),
    )
    inits2 = (
      (:E_ref, 7e9), (:pc_ref, 6e9), (:p_over_q_ref, Beamlines.pc_to_R(sp2, 6.5e9)),
      (:dE_ref, -3e9), (:dpc_ref, -2e9), (:dp_over_q_ref, Beamlines.pc_to_R(sp2, -2.5e9)),
    )
    for (k1, v1) in inits1, (k2, v2) in inits2
      bl1 = Beamline([Marker()]; Dict(k1 => v1, :species_ref => sp1)...)
      bl2 = Beamline([Marker()]; Dict(k2 => v2, :species_ref => sp2)...)
      branch = Branch([bl1, bl2])
      b1, b2 = branch.beamlines

      @test getproperty(b1, k1) == v1
      @test getproperty(b2, k2) == v2
      @test b1.species_ref == sp1
      @test b2.species_ref == sp2

      # Each Beamline is self-consistent with ITS OWN species (sign-agnostic: a stored dp_over_q
      # added across a charge-sign change can legitimately give a backwards-moving particle)
      for (b, sp, m) in ((b1, sp1, m1), (b2, sp2, m2))
        @test b.E_ref > m
        @test abs(b.pc_ref) ≈ Beamlines.E_to_pc(sp, b.E_ref)
        @test abs(b.p_over_q_ref) ≈ abs(Beamlines.E_to_R(sp, b.E_ref))
        @test b.E_ref ≈ Beamlines.pc_to_E(sp, b.pc_ref)
        @test b.E_ref ≈ Beamlines.R_to_E(sp, b.p_over_q_ref)
        @test b.pc_ref ≈ Beamlines.R_to_pc(sp, b.p_over_q_ref)
        @test b.p_over_q_ref ≈ Beamlines.pc_to_R(sp, b.pc_ref)
      end

      # First Beamline: delta from rest
      @test b1.dE_ref ≈ b1.E_ref - m1
      @test b1.dpc_ref ≈ b1.pc_ref
      @test b1.dp_over_q_ref ≈ b1.p_over_q_ref

      # Delta is always the difference of the two absolute values, each with its own species
      @test b2.E_ref - b1.E_ref ≈ b2.dE_ref rtol=1e-8 atol=1e-14*abs(b1.E_ref)
      @test b2.pc_ref - b1.pc_ref ≈ b2.dpc_ref rtol=1e-8 atol=1e-14*abs(b1.pc_ref)
      @test b2.p_over_q_ref - b1.p_over_q_ref ≈ b2.dp_over_q_ref rtol=1e-8 atol=1e-14*abs(b1.p_over_q_ref)
    end
  end
end

@testset "Reference params: electron -> proton explicit values" begin
  bl1 = Beamline([Marker()]; E_ref=10e9, species_ref=Species("electron"))
  bl2 = Beamline([Marker()]; dE_ref=-3e9, species_ref=Species("proton"))
  branch = Branch([bl1, bl2])
  bl1, bl2 = branch.beamlines
  @test bl1.p_over_q_ref < 0
  @test bl2.p_over_q_ref > 0
  @test bl1.p_over_q_ref ≈ Beamlines.E_to_R(Species("electron"), 10e9)
  @test bl2.E_ref == 7e9
  @test bl2.p_over_q_ref ≈ Beamlines.E_to_R(Species("proton"), 7e9)
  @test bl2.pc_ref ≈ Beamlines.E_to_pc(Species("proton"), 7e9)
  @test bl2.dpc_ref ≈ Beamlines.E_to_pc(Species("proton"), 7e9) - Beamlines.E_to_pc(Species("electron"), 10e9)
  @test bl2.dp_over_q_ref ≈ Beamlines.E_to_R(Species("proton"), 7e9) - Beamlines.E_to_R(Species("electron"), 10e9)
  @test bl2.dE_ref == -3e9

  # Same thing but the stored delta is in a different family than the key
  bl1 = Beamline([Marker()]; pc_ref=9e9, species_ref=Species("electron"))
  bl2 = Beamline([Marker()]; dpc_ref=-1e9, species_ref=Species("proton"))
  bl1, bl2 = Branch([bl1, bl2]).beamlines
  @test bl2.pc_ref ≈ 8e9 # added in pc, species irrelevant
  @test bl2.E_ref ≈ Beamlines.pc_to_E(Species("proton"), 8e9) # converted with bl2's species
  @test bl2.p_over_q_ref ≈ Beamlines.pc_to_R(Species("proton"), 8e9)
  @test bl2.dE_ref ≈ Beamlines.pc_to_E(Species("proton"), 8e9) - Beamlines.pc_to_E(Species("electron"), 9e9)
  @test bl2.dp_over_q_ref ≈ Beamlines.pc_to_R(Species("proton"), 8e9) - Beamlines.pc_to_R(Species("electron"), 9e9)
  @test bl2.dpc_ref == -1e9
end

@testset "Reference params: same species, precise deltas and edge cases" begin
  sp = Species("proton")
  m = Beamlines.massof(sp)

  # Moderate delta in a different family
  bl1 = Beamline([Marker()]; E_ref=10e9, species_ref=sp)
  bl2 = Beamline([Marker()]; dpc_ref=-2e9)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.pc_ref ≈ Beamlines.E_to_pc(sp, 10e9) - 2e9
  @test b2.E_ref ≈ Beamlines.pc_to_E(sp, Beamlines.E_to_pc(sp, 10e9) - 2e9)
  @test b2.dE_ref ≈ b2.E_ref - 10e9
  @test b2.dE_ref ≈ Beamlines.dpc_to_dE(sp, Beamlines.E_to_pc(sp, 10e9), -2e9)
  @test b2.dp_over_q_ref ≈ Beamlines.dpc_to_dR(sp, -2e9)

  # Tiny delta: must NOT be subject to cancellation (naive E2 - E1 would be wrong at ~1e-4 relative)
  bl1 = Beamline([Marker()]; pc_ref=1e9, species_ref=sp)
  bl2 = Beamline([Marker()]; dpc_ref=1e-3)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.dpc_ref == 1e-3
  @test b2.dE_ref ≈ 1e-3 * 1e9 / sqrt(1e18 + m^2) rtol=1e-9
  @test b2.dp_over_q_ref ≈ 1e-3 / Beamlines.C_LIGHT rtol=1e-12

  bl1 = Beamline([Marker()]; E_ref=10e9, species_ref=sp)
  bl2 = Beamline([Marker()]; dE_ref=1e-3)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.dE_ref == 1e-3
  @test b2.dpc_ref ≈ 1e-3 * 10e9 / Beamlines.E_to_pc(sp, 10e9) rtol=1e-9
  @test b2.dp_over_q_ref ≈ b2.dpc_ref / Beamlines.C_LIGHT rtol=1e-12

  bl1 = Beamline([Marker()]; p_over_q_ref=30.0, species_ref=sp)
  bl2 = Beamline([Marker()]; dp_over_q_ref=1e-6)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.dp_over_q_ref == 1e-6
  @test b2.dpc_ref ≈ 1e-6 * Beamlines.C_LIGHT rtol=1e-12
  @test b2.dE_ref ≈ b2.dpc_ref * b1.pc_ref / b1.E_ref rtol=1e-9

  # Zero deltas away from rest
  for k in (:dE_ref, :dpc_ref, :dp_over_q_ref)
    bl1 = Beamline([Marker()]; E_ref=10e9, species_ref=sp)
    bl2 = Beamline([Marker()]; Dict(k => 0.0)...)
    b1, b2 = Branch([bl1, bl2]).beamlines
    @test b2.E_ref == b1.E_ref
    @test b2.pc_ref ≈ b1.pc_ref
    @test b2.p_over_q_ref ≈ b1.p_over_q_ref
    @test b2.dE_ref == 0
    @test b2.dpc_ref == 0
    @test b2.dp_over_q_ref == 0
  end

  # Stored absolute equal to upstream -> zero deltas
  bl1 = Beamline([Marker()]; E_ref=10e9, species_ref=sp)
  bl2 = Beamline([Marker()]; E_ref=10e9)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.dE_ref == 0
  @test b2.dpc_ref == 0
  @test b2.dp_over_q_ref == 0

  # Starting at rest in the second Beamline (0/0 guard in dE -> dpc, dE -> dp_over_q)
  bl1 = Beamline([Marker()]; E_ref=m, species_ref=sp)
  bl2 = Beamline([Marker()]; dE_ref=0.0)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.E_ref == m
  @test b2.dE_ref == 0
  @test b2.dpc_ref == 0
  @test b2.dp_over_q_ref == 0
  @test b2.pc_ref == 0

  bl1 = Beamline([Marker()]; E_ref=m, species_ref=sp)
  bl2 = Beamline([Marker()]; dE_ref=1e9)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.E_ref ≈ m + 1e9
  @test b2.pc_ref ≈ sqrt(1e9 * (2m + 1e9))
  @test b2.dpc_ref ≈ sqrt(1e9 * (2m + 1e9))
  @test b2.dp_over_q_ref ≈ sqrt(1e9 * (2m + 1e9)) / Beamlines.C_LIGHT

  bl1 = Beamline([Marker()]; pc_ref=0.0, species_ref=sp)
  bl2 = Beamline([Marker()]; dpc_ref=1e9)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b1.E_ref == m
  @test b2.pc_ref == 1e9
  @test b2.E_ref ≈ Beamlines.pc_to_E(sp, 1e9)
  @test b2.dE_ref ≈ Beamlines.pc_to_E(sp, 1e9) - m

  bl1 = Beamline([Marker()]; E_ref=m, species_ref=sp)
  bl2 = Beamline([Marker()]; dpc_ref=0.0)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.pc_ref == 0
  @test b2.E_ref == m
  @test b2.dE_ref == 0
end

@testset "Reference params: inheritance of unset references" begin
  sp = Species("proton")

  # Beamline with nothing set inherits everything, with zero deltas
  bl1 = Beamline([Marker()]; E_ref=10e9, species_ref=sp)
  bl2 = Beamline([Marker()])
  bl3 = Beamline([Marker()])
  b1, b2, b3 = Branch([bl1, bl2, bl3]).beamlines
  for b in (b2, b3)
    @test b.E_ref == b1.E_ref
    @test b.pc_ref ≈ b1.pc_ref
    @test b.p_over_q_ref ≈ b1.p_over_q_ref
    @test b.species_ref == sp
    @test b.dE_ref == 0
    @test b.dpc_ref == 0
    @test b.dp_over_q_ref == 0
  end

  # A delta after an inheriting Beamline is relative to the inherited value
  bl1 = Beamline([Marker()]; E_ref=10e9, species_ref=sp)
  bl2 = Beamline([Marker()])
  bl3 = Beamline([Marker()]; dpc_ref=-1e9)
  bl4 = Beamline([Marker()])
  b1, b2, b3, b4 = Branch([bl1, bl2, bl3, bl4]).beamlines
  @test b3.pc_ref ≈ b1.pc_ref - 1e9
  @test b3.E_ref ≈ Beamlines.pc_to_E(sp, b1.pc_ref - 1e9)
  @test b3.dpc_ref == -1e9
  @test b3.dE_ref ≈ b3.E_ref - b1.E_ref
  @test b3.dp_over_q_ref ≈ b3.p_over_q_ref - b2.p_over_q_ref
  @test b4.E_ref == b3.E_ref
  @test b4.pc_ref ≈ b3.pc_ref
  @test b4.dE_ref == 0
  @test b4.dpc_ref == 0
  @test b4.dp_over_q_ref == 0
  @test b4.species_ref == sp

  # Species inherited through several Beamlines, changing in the middle
  bl1 = Beamline([Marker()]; pc_ref=9e9, species_ref=Species("electron"))
  bl2 = Beamline([Marker()])
  bl3 = Beamline([Marker()]; species_ref=Species("proton"))
  bl4 = Beamline([Marker()])
  b1, b2, b3, b4 = Branch([bl1, bl2, bl3, bl4]).beamlines
  @test b1.species_ref == Species("electron")
  @test b2.species_ref == Species("electron")
  @test b3.species_ref == Species("proton")
  @test b4.species_ref == Species("proton")
  @test b2.pc_ref == 9e9
  @test b2.E_ref ≈ Beamlines.pc_to_E(Species("electron"), 9e9)
  @test b1.p_over_q_ref < 0
  # Species changed but no reference set: every reference key is ambiguous, here and downstream
  for k in (:E_ref, :pc_ref, :p_over_q_ref, :dE_ref, :dpc_ref, :dp_over_q_ref)
    @test_throws ErrorException getproperty(b3, k)
  end
  # b4 sets nothing: its absolute keys inherit b3's error, its deltas are zero (nothing changed in b4),
  # the same convention as an unset first Beamline
  for k in (:E_ref, :pc_ref, :p_over_q_ref)
    @test_throws ErrorException getproperty(b4, k)
  end
  @test b4.dE_ref == 0
  @test b4.dpc_ref == 0
  @test b4.dp_over_q_ref == 0
  @test b4.species_ref == Species("proton")

  # Species given but unchanged and no reference set: fine, everything inherited
  bl1 = Beamline([Marker()]; pc_ref=9e9, species_ref=Species("proton"))
  bl2 = Beamline([Marker()]; species_ref=Species("proton"))
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.species_ref == Species("proton")
  @test b2.pc_ref == 9e9
  @test b2.E_ref == b1.E_ref
  @test b2.p_over_q_ref ≈ b1.p_over_q_ref
  @test b2.dE_ref == 0
  @test b2.dpc_ref == 0
  @test b2.dp_over_q_ref == 0

  # Species changed AND a reference set: fine (reference defines everything)
  bl1 = Beamline([Marker()]; pc_ref=9e9, species_ref=Species("electron"))
  bl2 = Beamline([Marker()]; pc_ref=9e9, species_ref=Species("proton"))
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.pc_ref == 9e9
  @test b2.E_ref ≈ Beamlines.pc_to_E(Species("proton"), 9e9)
  @test b2.p_over_q_ref > 0
  @test b2.dpc_ref == 0
  @test b2.dE_ref ≈ Beamlines.pc_to_E(Species("proton"), 9e9) - Beamlines.pc_to_E(Species("electron"), 9e9)

  bl1 = Beamline([Marker()]; pc_ref=9e9, species_ref=Species("electron"))
  bl2 = Beamline([Marker()]; dE_ref=0.0, species_ref=Species("proton"))
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.E_ref == b1.E_ref # explicit "no change in E"
  @test b2.dE_ref == 0
  @test b2.pc_ref ≈ Beamlines.E_to_pc(Species("proton"), b1.E_ref)

  # First Beamline unset: absolute keys are not inferrable
  b1, = Branch([Beamline([Marker()])]).beamlines
  @test_throws ErrorException b1.E_ref
  @test_throws ErrorException b1.pc_ref
  @test_throws ErrorException b1.p_over_q_ref
  @test b1.dE_ref == 0 # documents current behavior: inherited relative keys are zero

  # Second Beamline has a delta but first is unset: the upstream absolute cannot be found
  bl1 = Beamline([Marker()])
  bl2 = Beamline([Marker()]; dE_ref=-3e9, species_ref=sp)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.dE_ref == -3e9
  @test_throws ErrorException b2.E_ref
  @test_throws ErrorException b2.pc_ref
  @test_throws ErrorException b2.dpc_ref

  # Second Beamline has an absolute, first is unset: absolute keys work, deltas don't
  bl1 = Beamline([Marker()])
  bl2 = Beamline([Marker()]; E_ref=7e9, species_ref=sp)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.E_ref == 7e9
  @test b2.pc_ref ≈ Beamlines.E_to_pc(sp, 7e9)
  @test_throws ErrorException b2.dE_ref
  @test_throws ErrorException b2.dpc_ref
end

@testset "Reference params: species missing in a Branch of two" begin
  bl1 = Beamline([Marker()]; E_ref=10e9)
  bl2 = Beamline([Marker()]; dE_ref=-3e9)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.E_ref == 7e9 # same family, no species needed
  @test b2.dE_ref == -3e9
  @test b1.E_ref == 10e9
  @test_throws ErrorException b2.pc_ref
  @test_throws ErrorException b2.dpc_ref
  @test_throws ErrorException b2.p_over_q_ref
  @test_throws ErrorException b1.dE_ref # needs rest mass

  bl1 = Beamline([Marker()]; pc_ref=9e9)
  bl2 = Beamline([Marker()]; dpc_ref=-2e9)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.pc_ref == 7e9
  @test b2.dpc_ref == -2e9
  @test b1.dpc_ref == 9e9
  @test_throws ErrorException b2.E_ref
  @test_throws ErrorException b2.dE_ref
  @test_throws ErrorException b2.p_over_q_ref

  bl1 = Beamline([Marker()]; pc_ref=9e9)
  bl2 = Beamline([Marker()]; dE_ref=-2e9)
  b1, b2 = Branch([bl1, bl2]).beamlines
  @test b2.dE_ref == -2e9
  @test_throws ErrorException b2.E_ref
  @test_throws ErrorException b2.pc_ref
  @test_throws ErrorException b2.dpc_ref
end

@testset "Reference params: chains of Beamlines" begin
  # Same species all along
  for sp in (Species("electron"), Species("proton"), Species("anti-proton"), Species("deuteron"))
    bl1 = Beamline([Marker()]; E_ref=10e9, species_ref=sp)
    bl2 = Beamline([Marker()]; dpc_ref=-1e9)
    bl3 = Beamline([Marker()]; dE_ref=-2e9)
    bl4 = Beamline([Marker()]; dp_over_q_ref=Beamlines.pc_to_R(sp, -1.5e9))
    bl5 = Beamline([Marker()]; p_over_q_ref=Beamlines.pc_to_R(sp, 3e9))
    bl6 = Beamline([Marker()])
    bs = Branch([bl1, bl2, bl3, bl4, bl5, bl6]).beamlines
    for i in 1:6
      @test bs[i].species_ref == sp
      @test bs[i].pc_ref ≈ Beamlines.E_to_pc(sp, bs[i].E_ref)
      @test bs[i].p_over_q_ref ≈ Beamlines.E_to_R(sp, bs[i].E_ref)
      @test bs[i].E_ref ≈ Beamlines.R_to_E(sp, bs[i].p_over_q_ref)
    end
    for i in 2:6
      @test bs[i].E_ref - bs[i-1].E_ref ≈ bs[i].dE_ref rtol=1e-8 atol=1e-14*abs(bs[i-1].E_ref)
      @test bs[i].pc_ref - bs[i-1].pc_ref ≈ bs[i].dpc_ref rtol=1e-8 atol=1e-14*abs(bs[i-1].pc_ref)
      @test bs[i].p_over_q_ref - bs[i-1].p_over_q_ref ≈ bs[i].dp_over_q_ref rtol=1e-8 atol=1e-14*abs(bs[i-1].p_over_q_ref)
    end
    @test bs[2].pc_ref ≈ bs[1].pc_ref - 1e9
    @test bs[3].E_ref ≈ bs[2].E_ref - 2e9
    @test bs[4].pc_ref ≈ bs[3].pc_ref - 1.5e9
    @test bs[5].pc_ref ≈ 3e9
    @test bs[6].E_ref == bs[5].E_ref
    @test bs[6].dE_ref == 0
    @test bs[6].dpc_ref == 0
    @test bs[6].dp_over_q_ref == 0
  end

  # Species changes along the chain
  for (spa, spb) in (
      (Species("electron"), Species("proton")),
      (Species("proton"), Species("electron")),
      (Species("proton"), Species("anti-proton")),
      (Species("positron"), Species("electron")),
      (Species("deuteron"), Species("proton")),
      (Species("proton"), Species("proton")),
  )
    bl1 = Beamline([Marker()]; E_ref=10e9, species_ref=spa)
    bl2 = Beamline([Marker()]; dE_ref=-1e9)
    bl3 = Beamline([Marker()]; dpc_ref=-1e9, species_ref=spb)
    bl4 = Beamline([Marker()]; dE_ref=-1e9)
    bl5 = Beamline([Marker()]; p_over_q_ref=Beamlines.pc_to_R(spa, 5e9), species_ref=spa)
    bs = Branch([bl1, bl2, bl3, bl4, bl5]).beamlines
    sps = (spa, spa, spb, spb, spa)
    for i in 1:5
      @test bs[i].species_ref == sps[i]
      @test abs(bs[i].pc_ref) ≈ Beamlines.E_to_pc(sps[i], bs[i].E_ref)
      @test bs[i].E_ref ≈ Beamlines.pc_to_E(sps[i], bs[i].pc_ref)
      @test bs[i].E_ref ≈ Beamlines.R_to_E(sps[i], bs[i].p_over_q_ref)
      @test bs[i].pc_ref ≈ Beamlines.R_to_pc(sps[i], bs[i].p_over_q_ref)
    end
    for i in 2:5
      @test bs[i].E_ref - bs[i-1].E_ref ≈ bs[i].dE_ref rtol=1e-8 atol=1e-14*abs(bs[i-1].E_ref)
      @test bs[i].pc_ref - bs[i-1].pc_ref ≈ bs[i].dpc_ref rtol=1e-8 atol=1e-14*abs(bs[i-1].pc_ref)
      @test bs[i].p_over_q_ref - bs[i-1].p_over_q_ref ≈ bs[i].dp_over_q_ref rtol=1e-8 atol=1e-14*abs(bs[i-1].p_over_q_ref)
    end
    @test bs[2].E_ref == 9e9
    @test bs[2].pc_ref ≈ Beamlines.E_to_pc(spa, 9e9)
    @test bs[3].pc_ref ≈ bs[2].pc_ref - 1e9 # added in pc, independent of the species change
    @test bs[3].E_ref ≈ Beamlines.pc_to_E(spb, bs[2].pc_ref - 1e9)
    @test bs[4].E_ref ≈ bs[3].E_ref - 1e9
    @test bs[5].pc_ref ≈ 5e9
  end
end

@testset "Reference params: Beamlines with several elements" begin
  sp = Species("proton")
  bl1 = Beamline([Marker(), Marker()]; E_ref=10e9, species_ref=sp)
  bl2 = Beamline([Marker(), Marker(), Marker()]; dE_ref=-3e9)
  b1, b2 = Branch([bl1, bl2]).beamlines
  for i in 1:2
    @test b1.line[i].E_ref == b1.E_ref
    @test b1.line[i].pc_ref ≈ b1.pc_ref
    @test b1.line[i].species_ref == sp
  end
  for i in 1:3
    @test b2.line[i].E_ref == 7e9
    @test b2.line[i].pc_ref ≈ b2.pc_ref
    @test b2.line[i].p_over_q_ref ≈ b2.p_over_q_ref
    @test b2.line[i].species_ref == sp
  end
  @test b2.line[1].dE_ref == -3e9
  @test b2.line[1].dpc_ref ≈ b2.dpc_ref
  @test b2.line[2].dE_ref == 0 # only the first element carries the change
  @test b2.line[3].dE_ref == 0
  @test b2.line[2].dpc_ref == 0
  @test b2.line[3].dp_over_q_ref == 0
end

@testset "Reference params: changing what is stored after construction" begin
  # Same species: setting each key in turn replaces the stored meaning; everything stays consistent
  sp = Species("proton")
  m = Beamlines.massof(sp)
  bl1 = Beamline([Marker()]; E_ref=10e9, species_ref=sp)
  bl2 = Beamline([Marker()]; dE_ref=-3e9)
  b1, b2 = Branch([bl1, bl2]).beamlines

  for (k2, v2) in (
      (:dpc_ref, -2e9), (:dp_over_q_ref, Beamlines.pc_to_R(sp, -2.5e9)), (:E_ref, 6e9),
      (:pc_ref, 5e9), (:p_over_q_ref, Beamlines.pc_to_R(sp, 5.5e9)), (:dE_ref, -1e9),
      (:dp_over_q_ref, -3.0), (:dpc_ref, 0.0), (:dE_ref, -3e9),
  )
    setproperty!(b2, k2, v2)
    @test getproperty(b2, k2) == v2
    @test b2.species_ref == sp
    @test b1.E_ref == 10e9
    @test b2.pc_ref ≈ Beamlines.E_to_pc(sp, b2.E_ref)
    @test b2.p_over_q_ref ≈ Beamlines.E_to_R(sp, b2.E_ref)
    @test b2.E_ref - b1.E_ref ≈ b2.dE_ref rtol=1e-8 atol=1e-14*abs(b1.E_ref)
    @test b2.pc_ref - b1.pc_ref ≈ b2.dpc_ref rtol=1e-8 atol=1e-14*abs(b1.pc_ref)
    @test b2.p_over_q_ref - b1.p_over_q_ref ≈ b2.dp_over_q_ref rtol=1e-8 atol=1e-14*abs(b1.p_over_q_ref)
  end

  for (k1, v1) in (
      (:pc_ref, 9e9), (:p_over_q_ref, Beamlines.pc_to_R(sp, 8e9)), (:dE_ref, 9e9),
      (:dpc_ref, 8e9), (:dp_over_q_ref, Beamlines.pc_to_R(sp, 7e9)), (:E_ref, 10e9),
  )
    setproperty!(b1, k1, v1)
    @test getproperty(b1, k1) == v1
    @test b1.pc_ref ≈ Beamlines.E_to_pc(sp, b1.E_ref)
    @test b1.p_over_q_ref ≈ Beamlines.E_to_R(sp, b1.E_ref)
    @test b1.dE_ref ≈ b1.E_ref - m
    @test b1.dpc_ref ≈ b1.pc_ref
    @test b1.dp_over_q_ref ≈ b1.p_over_q_ref
    @test b2.pc_ref ≈ Beamlines.E_to_pc(sp, b2.E_ref)
    @test b2.E_ref - b1.E_ref ≈ b2.dE_ref rtol=1e-8 atol=1e-14*abs(b1.E_ref)
    @test b2.pc_ref - b1.pc_ref ≈ b2.dpc_ref rtol=1e-8 atol=1e-14*abs(b1.pc_ref)
    @test b2.p_over_q_ref - b1.p_over_q_ref ≈ b2.dp_over_q_ref rtol=1e-8 atol=1e-14*abs(b1.p_over_q_ref)
  end

  # Species change: the user's original sequence, with extra checks along the way
  bl1 = Beamline([Marker()]; E_ref=10e9, species_ref=Species("electron"))
  bl2 = Beamline([Marker()]; dE_ref=-3e9, species_ref=Species("proton"))
  bl1, bl2 = Branch([bl1, bl2]).beamlines
  @test bl2.E_ref == 7e9
  @test bl2.dE_ref == -3e9
  @test bl1.dE_ref == 10e9 - Beamlines.massof(Species("electron"))

  bl2.dpc_ref = -2e9
  bl1.p_over_q_ref = -40
  @test bl2.dpc_ref == -2e9
  @test bl1.p_over_q_ref == -40
  @test bl1.pc_ref ≈ Beamlines.R_to_pc(Species("electron"), -40)
  @test bl1.pc_ref > 0
  @test bl2.pc_ref ≈ bl1.pc_ref - 2e9
  @test bl2.E_ref ≈ Beamlines.pc_to_E(Species("proton"), bl1.pc_ref - 2e9)
  @test bl2.p_over_q_ref ≈ Beamlines.pc_to_R(Species("proton"), bl1.pc_ref - 2e9)
  @test bl2.p_over_q_ref > 0
  @test bl2.pc_ref - bl1.pc_ref ≈ bl2.dpc_ref rtol=1e-8 atol=1e-14*abs(bl1.pc_ref)
  @test bl2.E_ref - bl1.E_ref ≈ bl2.dE_ref rtol=1e-8 atol=1e-14*abs(bl1.E_ref)
  @test bl2.p_over_q_ref - bl1.p_over_q_ref ≈ bl2.dp_over_q_ref rtol=1e-8 atol=1e-14*abs(bl1.p_over_q_ref)

  bl2.dp_over_q_ref = -5
  bl1.pc_ref = 9e9
  @test bl2.dp_over_q_ref == -5
  @test bl1.pc_ref == 9e9
  @test bl2.p_over_q_ref ≈ Beamlines.pc_to_R(Species("electron"), 9e9) - 5 # added in p_over_q
  @test bl2.pc_ref ≈ Beamlines.R_to_pc(Species("proton"), bl2.p_over_q_ref)
  @test bl2.E_ref ≈ Beamlines.R_to_E(Species("proton"), bl2.p_over_q_ref)
  @test bl2.pc_ref - bl1.pc_ref ≈ bl2.dpc_ref rtol=1e-8 atol=1e-14*abs(bl1.pc_ref)
  @test bl2.E_ref - bl1.E_ref ≈ bl2.dE_ref rtol=1e-8 atol=1e-14*abs(bl1.E_ref)
  @test bl2.p_over_q_ref - bl1.p_over_q_ref ≈ bl2.dp_over_q_ref rtol=1e-8 atol=1e-14*abs(bl1.p_over_q_ref)

  bl2.E_ref = 10e9
  @test bl2.E_ref == 10e9
  @test bl2.pc_ref ≈ Beamlines.E_to_pc(Species("proton"), 10e9)
  @test bl2.p_over_q_ref ≈ Beamlines.E_to_R(Species("proton"), 10e9)
  @test bl2.pc_ref - bl1.pc_ref ≈ bl2.dpc_ref rtol=1e-8 atol=1e-14*abs(bl1.pc_ref)
  @test bl2.E_ref - bl1.E_ref ≈ bl2.dE_ref rtol=1e-8 atol=1e-14*abs(bl1.E_ref)
  @test bl2.p_over_q_ref - bl1.p_over_q_ref ≈ bl2.dp_over_q_ref rtol=1e-8 atol=1e-14*abs(bl1.p_over_q_ref)

  bl2.pc_ref = 8e9
  @test bl2.pc_ref == 8e9
  @test bl2.E_ref ≈ Beamlines.pc_to_E(Species("proton"), 8e9)
  @test bl2.dpc_ref ≈ 8e9 - 9e9
  @test bl2.pc_ref - bl1.pc_ref ≈ bl2.dpc_ref rtol=1e-8 atol=1e-14*abs(bl1.pc_ref)
  @test bl2.E_ref - bl1.E_ref ≈ bl2.dE_ref rtol=1e-8 atol=1e-14*abs(bl1.E_ref)
  @test bl2.p_over_q_ref - bl1.p_over_q_ref ≈ bl2.dp_over_q_ref rtol=1e-8 atol=1e-14*abs(bl1.p_over_q_ref)

  bl2.p_over_q_ref = 20.0
  @test bl2.p_over_q_ref == 20.0
  @test bl2.pc_ref ≈ Beamlines.R_to_pc(Species("proton"), 20.0)
  @test bl2.pc_ref - bl1.pc_ref ≈ bl2.dpc_ref rtol=1e-8 atol=1e-14*abs(bl1.pc_ref)
  @test bl2.E_ref - bl1.E_ref ≈ bl2.dE_ref rtol=1e-8 atol=1e-14*abs(bl1.E_ref)
  @test bl2.p_over_q_ref - bl1.p_over_q_ref ≈ bl2.dp_over_q_ref rtol=1e-8 atol=1e-14*abs(bl1.p_over_q_ref)
end

@testset "Reference params: |Z|>1, same species, energies scaled to the mass" begin
  for sp in (
      Species("proton"), Species("electron"), Species("deuteron"), Species("helion"), Species("triton"),
      Species("#4He+2"), Species("Li+3"), Species("#12C+6"), Species("#208Pb+82"), Species("K-2"),
  )
    M = Beamlines.massof(sp)
    Z = Beamlines.chargeof(sp)
    inits1 = (
      (:E_ref, 10*M), (:pc_ref, 9*M), (:p_over_q_ref, Beamlines.pc_to_R(sp, 8*M)),
      (:dE_ref, 9*M), (:dpc_ref, 8*M), (:dp_over_q_ref, Beamlines.pc_to_R(sp, 7*M)),
    )
    inits2 = (
      (:E_ref, 7*M), (:pc_ref, 6*M), (:p_over_q_ref, Beamlines.pc_to_R(sp, 6.5*M)),
      (:dE_ref, -3*M), (:dpc_ref, -2*M), (:dp_over_q_ref, Beamlines.pc_to_R(sp, -2.5*M)),
    )
    for (k1, v1) in inits1, (k2, v2) in inits2
      bl1 = Beamline([Marker()]; Dict(k1 => v1, :species_ref => sp)...)
      bl2 = Beamline([Marker()]; Dict(k2 => v2)...)
      b1, b2 = Branch([bl1, bl2]).beamlines

      @test getproperty(b1, k1) == v1
      @test getproperty(b2, k2) == v2
      @test b2.species_ref == sp
      for b in (b1, b2)
        @test b.E_ref > M
        @test b.pc_ref ≈ Beamlines.E_to_pc(sp, b.E_ref)
        @test b.E_ref ≈ Beamlines.pc_to_E(sp, b.pc_ref)
        @test b.p_over_q_ref ≈ b.pc_ref / Beamlines.C_LIGHT / Z # rigidity = pc / (q c)
        @test sign(b.p_over_q_ref) == sign(Z)
        @test b.E_ref ≈ Beamlines.R_to_E(sp, b.p_over_q_ref)
        @test b.pc_ref ≈ Beamlines.R_to_pc(sp, b.p_over_q_ref)
      end
      @test b1.dE_ref ≈ b1.E_ref - M
      @test b1.dpc_ref ≈ b1.pc_ref
      @test b1.dp_over_q_ref ≈ b1.p_over_q_ref
      @test b2.E_ref - b1.E_ref ≈ b2.dE_ref rtol=1e-8 atol=1e-14*abs(b1.E_ref)
      @test b2.pc_ref - b1.pc_ref ≈ b2.dpc_ref rtol=1e-8 atol=1e-14*abs(b1.pc_ref)
      @test b2.p_over_q_ref - b1.p_over_q_ref ≈ b2.dp_over_q_ref rtol=1e-8 atol=1e-14*abs(b1.p_over_q_ref)
      # dp_over_q and dpc are related by the charge, always
      @test b2.dpc_ref ≈ b2.dp_over_q_ref * Z * Beamlines.C_LIGHT rtol=1e-8 atol=1e-14*abs(b1.pc_ref)
    end
  end
end

@testset "Reference params: |Z|>1, species changes, energies scaled to the larger mass" begin
  for (sp1, sp2) in (
      (Species("#4He+2"), Species("proton")),
      (Species("proton"), Species("#4He+2")),
      (Species("#12C+6"), Species("Li+3")),
      (Species("K-2"), Species("#4He+2")),
      (Species("#4He+2"), Species("K-2")),
      (Species("electron"), Species("#208Pb+82")),
      (Species("#208Pb+82"), Species("electron")),
      (Species("#208Pb+82"), Species("#12C+6")),
      (Species("helion"), Species("triton")),
  )
    M = max(Beamlines.massof(sp1), Beamlines.massof(sp2))
    inits1 = (
      (:E_ref, 10*M), (:pc_ref, 9*M), (:p_over_q_ref, Beamlines.pc_to_R(sp1, 8*M)),
      (:dE_ref, 9*M), (:dpc_ref, 8*M), (:dp_over_q_ref, Beamlines.pc_to_R(sp1, 7*M)),
    )
    inits2 = (
      (:E_ref, 7*M), (:pc_ref, 6*M), (:p_over_q_ref, Beamlines.pc_to_R(sp2, 6.5*M)),
      (:dE_ref, -3*M), (:dpc_ref, -2*M), (:dp_over_q_ref, Beamlines.pc_to_R(sp2, -2.5*M)),
    )
    for (k1, v1) in inits1, (k2, v2) in inits2
      bl1 = Beamline([Marker()]; Dict(k1 => v1, :species_ref => sp1)...)
      bl2 = Beamline([Marker()]; Dict(k2 => v2, :species_ref => sp2)...)
      b1, b2 = Branch([bl1, bl2]).beamlines

      @test getproperty(b1, k1) == v1
      @test getproperty(b2, k2) == v2
      @test b1.species_ref == sp1
      @test b2.species_ref == sp2
      for (b, sp) in ((b1, sp1), (b2, sp2))
        @test b.E_ref > Beamlines.massof(sp)
        @test abs(b.pc_ref) ≈ Beamlines.E_to_pc(sp, b.E_ref)
        @test b.E_ref ≈ Beamlines.pc_to_E(sp, b.pc_ref)
        @test b.E_ref ≈ Beamlines.R_to_E(sp, b.p_over_q_ref)
        @test b.pc_ref ≈ Beamlines.R_to_pc(sp, b.p_over_q_ref)
        @test b.p_over_q_ref ≈ b.pc_ref / Beamlines.C_LIGHT / Beamlines.chargeof(sp)
      end
      @test b1.dE_ref ≈ b1.E_ref - Beamlines.massof(sp1)
      @test b1.dpc_ref ≈ b1.pc_ref
      @test b1.dp_over_q_ref ≈ b1.p_over_q_ref
      @test b2.E_ref - b1.E_ref ≈ b2.dE_ref rtol=1e-8 atol=1e-14*abs(b1.E_ref)
      @test b2.pc_ref - b1.pc_ref ≈ b2.dpc_ref rtol=1e-8 atol=1e-14*abs(b1.pc_ref)
      @test b2.p_over_q_ref - b1.p_over_q_ref ≈ b2.dp_over_q_ref rtol=1e-8 atol=1e-14*abs(b1.p_over_q_ref)
    end
  end
end

@testset "Reference params: |Z|>1 explicit values" begin
  # Rigidity scales as 1/Z at fixed pc; pc scales as Z at fixed rigidity
  for (name, Z) in (("proton", 1), ("#4He+2", 2), ("Li+3", 3), ("#12C+6", 6), ("#208Pb+82", 82), ("K-2", -2))
    sp = Species(name)
    M = Beamlines.massof(sp)
    @test Beamlines.chargeof(sp) == Z

    bl = Beamline([Marker()]; pc_ref=9*M, species_ref=sp)
    b, = Branch([bl]).beamlines
    @test b.p_over_q_ref ≈ 9*M / Beamlines.C_LIGHT / Z
    @test b.dp_over_q_ref ≈ 9*M / Beamlines.C_LIGHT / Z
    @test b.E_ref ≈ sqrt(81*M^2 + M^2) # energy does not depend on the charge

    # p_over_q_ref must carry the sign of the charge (Beamline flips it otherwise, with an @info),
    # so that a forward-moving particle always has pc > 0
    R = 100.0 * sign(Z)
    bl = Beamline([Marker()]; p_over_q_ref=R, species_ref=sp)
    b, = Branch([bl]).beamlines
    @test b.p_over_q_ref == R
    @test b.pc_ref ≈ 100.0 * abs(Z) * Beamlines.C_LIGHT
    @test b.dpc_ref ≈ 100.0 * abs(Z) * Beamlines.C_LIGHT
    @test b.E_ref ≈ sqrt((100.0 * Z * Beamlines.C_LIGHT)^2 + M^2)
    @test b.dE_ref ≈ b.E_ref - M

    # Second Beamline stores a small dp_over_q: dpc = Z c dR exactly, dE = beta dpc to first order
    dR = 1e-9 * sign(Z) # increases |R| (and so pc) for either sign of the charge
    bl1 = Beamline([Marker()]; p_over_q_ref=R, species_ref=sp)
    bl2 = Beamline([Marker()]; dp_over_q_ref=dR)
    b1, b2 = Branch([bl1, bl2]).beamlines
    @test b2.dp_over_q_ref == dR
    @test b2.dpc_ref ≈ dR * Z * Beamlines.C_LIGHT rtol=1e-12
    @test b2.dpc_ref > 0
    @test b2.dE_ref ≈ b2.dpc_ref * b1.pc_ref / b1.E_ref rtol=1e-6
    @test b2.p_over_q_ref ≈ R + dR
    @test b2.pc_ref ≈ (100.0 + 1e-9) * abs(Z) * Beamlines.C_LIGHT

    # Stored dE: dp_over_q follows from the charge
    bl1 = Beamline([Marker()]; E_ref=10*M, species_ref=sp)
    bl2 = Beamline([Marker()]; dE_ref=-1e-3*M)
    b1, b2 = Branch([bl1, bl2]).beamlines
    @test b2.dp_over_q_ref ≈ b2.dpc_ref / Beamlines.C_LIGHT / Z rtol=1e-12
    @test b2.dpc_ref ≈ -1e-3*M * b1.E_ref / b1.pc_ref rtol=1e-3
  end

  # Same pc, same mass-per-charge differences: helion vs triton have equal charge but different mass
  he3 = Species("helion"); h3 = Species("triton")
  @test Beamlines.chargeof(he3) == 2
  @test Beamlines.chargeof(h3) == 1
  @test Beamlines.pc_to_R(he3, 9e9) ≈ Beamlines.pc_to_R(h3, 9e9) / 2
  @test Beamlines.pc_to_E(he3, 9e9) != Beamlines.pc_to_E(h3, 9e9)
end

@testset "Reference params: stripping and charge exchange (species loses or gains electrons)" begin
  # Realistic pairs: same nucleus, different charge state, so the masses differ only slightly
  for (sp1, sp2) in (
    (Species("#208Pb+54"), Species("#208Pb+82")),
    (Species("#12C+2"), Species("#12C+6")),
    (Species("#238U+28"), Species("#238U+92")),
    (Species("#4He+1"), Species("#4He+2")),
    (Species("#208Pb+82"), Species("#208Pb+54")), # capture
    (Species("#12C+6"), Species("#12C+5")),
  )
    m1 = Beamlines.massof(sp1)
    m2 = Beamlines.massof(sp2)
    q1 = Beamlines.chargeof(sp1)
    q2 = Beamlines.chargeof(sp2)

    # Same momentum before and after
    bl1 = Beamline([Marker()]; pc_ref=5*m1, species_ref=sp1)
    bl2 = Beamline([Marker()]; pc_ref=5*m1, species_ref=sp2)
    b1, b2 = Branch([bl1, bl2]).beamlines
    @test b2.pc_ref == b1.pc_ref
    @test b2.dpc_ref == 0
    @test b2.p_over_q_ref ≈ b1.p_over_q_ref * q1 / q2 rtol=1e-12 # rigidity changes with the charge
    @test b2.E_ref ≈ Beamlines.pc_to_E(sp2, 5*m1)
    @test b2.dE_ref ≈ Beamlines.pc_to_E(sp2, 5*m1) - Beamlines.pc_to_E(sp1, 5*m1) rtol=1e-8 atol=1e-14*abs(b1.E_ref)
    @test sign(b2.dE_ref) == sign(m2 - m1)
    @test b2.dp_over_q_ref ≈ b2.p_over_q_ref - b1.p_over_q_ref

    # Same total energy before and after
    bl1 = Beamline([Marker()]; E_ref=6*m1, species_ref=sp1)
    bl2 = Beamline([Marker()]; E_ref=6*m1, species_ref=sp2)
    b1, b2 = Branch([bl1, bl2]).beamlines
    @test b2.E_ref == b1.E_ref
    @test b2.dE_ref == 0
    @test sign(b2.dpc_ref) == sign(m1 - m2)
    @test b2.pc_ref ≈ Beamlines.E_to_pc(sp2, 6*m1)
    @test b2.p_over_q_ref ≈ Beamlines.E_to_R(sp2, 6*m1)

    # Same rigidity before and after
    R1 = Beamlines.pc_to_R(sp1, 4*m1)
    R2 = abs(R1) * sign(q2) # same |rigidity|, sign follows the new charge
    bl1 = Beamline([Marker()]; p_over_q_ref=R1, species_ref=sp1)
    bl2 = Beamline([Marker()]; p_over_q_ref=R2, species_ref=sp2)
    b1, b2 = Branch([bl1, bl2]).beamlines
    @test abs(b2.p_over_q_ref) == abs(b1.p_over_q_ref)
    @test b2.pc_ref ≈ b1.pc_ref * abs(q2) / abs(q1) rtol=1e-12
    @test b2.E_ref ≈ Beamlines.R_to_E(sp2, R2)
    @test b2.dpc_ref ≈ b2.pc_ref - b1.pc_ref rtol=1e-8 atol=1e-14*abs(b2.pc_ref)

    # A delta stored after stripping, relative to the stripped beam's own reference
    bl1 = Beamline([Marker()]; pc_ref=5*m1, species_ref=sp1)
    bl2 = Beamline([Marker()]; pc_ref=5*m1, species_ref=sp2)
    bl3 = Beamline([Marker()]; dpc_ref=-m1)
    b1, b2, b3 = Branch([bl1, bl2, bl3]).beamlines
    @test b3.species_ref == sp2
    @test b3.pc_ref ≈ 4*m1
    @test b3.E_ref ≈ Beamlines.pc_to_E(sp2, 4*m1) # converted with the stripped species
    @test b3.dE_ref ≈ Beamlines.dpc_to_dE(sp2, 5*m1, -m1) # delta uses the species of b2, not b1
    @test b3.dp_over_q_ref ≈ -m1 / Beamlines.C_LIGHT / q2

    # Species change with no reference set is an error (no variable is preserved by stripping)
    bl1 = Beamline([Marker()]; pc_ref=5*m1, species_ref=sp1)
    bl2 = Beamline([Marker()]; species_ref=sp2)
    b1, b2 = Branch([bl1, bl2]).beamlines
    for k in (:E_ref, :pc_ref, :p_over_q_ref, :dE_ref, :dpc_ref, :dp_over_q_ref)
      @test_throws ErrorException getproperty(b2, k)
    end
  end
end