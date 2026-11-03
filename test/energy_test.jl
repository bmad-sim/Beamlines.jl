# Tests for particle energy conversions =====================================================
#
# SETUP: adjust the two lines below to match your package.
#   - load whatever module exports Species, massof, chargeof, C_LIGHT and the conversions
#   - check the Species(...) constructor strings in `SPECIES` (see the "species" section)

using Test
using Beamlines
using Beamlines.AtomicAndPhysicalConstants
using Beamlines: E_to_R, E_to_v, R_to_E, R_to_gamma, R_to_pc, R_to_beta_gamma, R_to_v, 
        pc_to_R, dR_to_dpc, dpc_to_dR, dE_to_dpc, dpc_to_dE, dE_to_dR, dR_to_dE, pc_to_E, 
        E_to_pc
# include("energy_conversions.jl")       # <-- or include the file directly

# ---------------------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------------------
setprecision(BigFloat, 256)

# High-precision reference implementations (BigFloat, same constants as the package)
function ref(sp)
  m = big(massof(sp)); q = big(chargeof(sp)); c = big(C_LIGHT)
  (; m, q, c,
     pc_of_R = R  -> R*q*c,
     R_of_pc = pc -> pc/c/q,
     E_of_pc = pc -> sqrt(pc^2 + m^2),
     pc_of_E = E  -> sqrt((E - m)*(E + m)),   # positive branch
  )
end

# Species used throughout. Constructor strings may need editing for your package.
const SPECIES = Dict(
  "proton"      => Species("proton"),
  "electron"    => Species("electron"),
  "positron"    => Species("positron"),
  "anti-proton" => Species("anti-proton"),
  "deuteron"    => Species("deuteron"),
  "#4He+2"      => Species("#4He+2"),    
  "#12C+6"      => Species("#12C+6"),    
  "#208Pb+82"   => Species("#208Pb+82"), 
)

# pc values (eV) spanning nonrelativistic to ultra-relativistic for any species above
const PCS = [1e3, 1e6, 1e8, 1e9, 1e10, 1e12, 1e15]

# E values are generated per species as a multiple of the mass (gamma values)
const GAMMAS = [1.0000001, 1.001, 1.1, 2.0, 10.0, 1e3, 1e6]

# ---------------------------------------------------------------------------------------
@testset "Energy conversions" begin

# =======================================================================================
@testset "Species sanity (conventions the conversions rely on)" begin
  @test chargeof(SPECIES["proton"])     ==  1
  @test chargeof(SPECIES["electron"])   == -1
  @test chargeof(SPECIES["positron"])   ==  1
  @test chargeof(SPECIES["anti-proton"]) == -1
  @test chargeof(SPECIES["deuteron"])   ==  1
  @test chargeof(SPECIES["#4He+2"])      ==  2
  @test chargeof(SPECIES["#12C+6"])      ==  6
  @test chargeof(SPECIES["#208Pb+82"])   ==  82

  # Total ion mass, not per-nucleon: He4 nucleus ~ 3.727 GeV, C12 ~ 11.18 GeV
  @test isapprox(massof(SPECIES["#4He+2"]), 3.7274e9;  rtol = 1e-3)
  @test isapprox(massof(SPECIES["#12C+6"]), 1.1175e10; rtol = 1e-3)
  @test isapprox(massof(SPECIES["proton"]), 938.272e6; rtol = 1e-5)
  @test isapprox(massof(SPECIES["electron"]), 0.51099895e6; rtol = 1e-6)
  @test massof(SPECIES["proton"]) == massof(SPECIES["anti-proton"])
  @test massof(SPECIES["electron"]) == massof(SPECIES["positron"])
  @test all(massof(sp) > 0 for sp in values(SPECIES))
end

# =======================================================================================
@testset "Known values" begin
  p = SPECIES["proton"]; m = massof(p)

  # Rest: pc = 0 -> E = m, v = 0
  @test pc_to_E(p, 0.0) == m
  @test R_to_E(p, 0.0)  == m
  @test R_to_v(p, 0.0)  == 0.0
  @test R_to_gamma(p, 0.0) == 1.0
  @test R_to_beta_gamma(p, 0.0) == 0.0
  @test E_to_pc(p, m) == 0.0
  @test E_to_R(p, m)  == 0.0
  @test E_to_v(p, m)  == 0.0

  # pc = m  ->  E = sqrt(2) m, beta*gamma = 1, gamma = sqrt(2), beta = 1/sqrt(2)
  @test pc_to_E(p, m) ≈ sqrt(2)*m rtol = 1e-14
  R_m = pc_to_R(p, m)
  @test R_to_beta_gamma(p, R_m) ≈ 1.0 rtol = 1e-14
  @test R_to_gamma(p, R_m) ≈ sqrt(2) rtol = 1e-14
  @test R_to_v(p, R_m) ≈ C_LIGHT/sqrt(2) rtol = 1e-14

  # E = 2m -> pc = sqrt(3) m, gamma = 2, beta = sqrt(3)/2
  @test E_to_pc(p, 2m) ≈ sqrt(3)*m rtol = 1e-14
  @test E_to_v(p, 2m)  ≈ C_LIGHT*sqrt(3)/2 rtol = 1e-14

  # 3-4-5 style triangle: E^2 = pc^2 + m^2 with pc = 3 units, m = 4 units -> E = 5 units
  # (use a species mass as the unit)
  @test pc_to_E(p, 0.75m) ≈ 1.25m rtol = 1e-14       # (0.75, 1, 1.25)
  @test E_to_pc(p, 1.25m) ≈ 0.75m rtol = 1e-14

  # Proton at pc = 1 GeV (well-known): E = sqrt(1e18 + m^2)
  @test pc_to_E(p, 1e9) ≈ sqrt(1e18 + m^2) rtol = 1e-15
  # Bp = pc/(q c): 1 GeV proton -> ~3.3356 T m
  @test pc_to_R(p, 1e9) ≈ 1e9/C_LIGHT rtol = 1e-15
  @test isapprox(pc_to_R(p, 1e9), 3.33564, rtol = 1e-5)
end

# =======================================================================================
@testset "Linear conversions, all species" begin
  for (name, sp) in SPECIES
    @testset "$name" begin
      q = chargeof(sp)
      for pc in PCS
        R = pc_to_R(sp, pc)
        @test R ≈ pc/C_LIGHT/q rtol = 1e-15
        @test R_to_pc(sp, R) ≈ pc rtol = 1e-14
        @test pc_to_R(sp, R_to_pc(sp, R)) ≈ R rtol = 1e-14
        @test sign(R) == sign(q)               # forward-moving particle: sign(R) = sign(q)
        # negative pc flips everything
        @test pc_to_R(sp, -pc) ≈ -R rtol = 1e-15
        @test R_to_pc(sp, -R)  ≈ -pc rtol = 1e-14
      end
      # exact linearity / zero
      @test R_to_pc(sp, 0.0) == 0.0
      @test pc_to_R(sp, 0.0) == 0.0
      @test R_to_pc(sp, 2.5) ≈ 2.5*R_to_pc(sp, 1.0) rtol = 1e-15
      @test R_to_pc(sp, 1.0 + 2.0) ≈ R_to_pc(sp, 1.0) + R_to_pc(sp, 2.0) rtol = 1e-15
    end
  end
end

# =======================================================================================
@testset "Absolute conversions vs BigFloat reference, all species" begin
  for (name, sp) in SPECIES
    @testset "$name" begin
      r = ref(sp)

      # pc -> E, R -> E
      for pc in PCS
        Eref = r.E_of_pc(big(pc))
        @test pc_to_E(sp, pc) ≈ Float64(Eref) rtol = 1e-14
        R = pc_to_R(sp, pc)
        @test R_to_E(sp, R) ≈ Float64(r.E_of_pc(r.pc_of_R(big(R)))) rtol = 1e-14
        # negative R, pc give the same (positive) E
        @test pc_to_E(sp, -pc) == pc_to_E(sp, pc)
        @test R_to_E(sp, -R)   == R_to_E(sp, R)
      end

      # E -> pc, R, v, over a gamma sweep
      for g in GAMMAS
        E = g*massof(sp)
        pcref = r.pc_of_E(big(E))
        @test E_to_pc(sp, E) ≈ Float64(pcref) rtol = 1e-13
        @test E_to_R(sp, E)  ≈ Float64(r.R_of_pc(pcref)) rtol = 1e-13
        vref = pcref*r.c/big(E)
        @test E_to_v(sp, E) ≈ Float64(vref) rtol = 1e-13
      end

      # R -> v, gamma, beta*gamma
      for pc in PCS
        R = pc_to_R(sp, pc)
        pcb = r.pc_of_R(big(R))
        Eb  = r.E_of_pc(pcb)
        @test R_to_v(sp, R)          ≈ Float64(pcb*r.c/Eb) rtol = 1e-14
        @test R_to_gamma(sp, R)      ≈ Float64(Eb/r.m)     rtol = 1e-14
        @test R_to_beta_gamma(sp, R) ≈ Float64(pcb/r.m)    rtol = 1e-14
      end
    end
  end
end

# =======================================================================================
@testset "Round trips, all species" begin
  for (name, sp) in SPECIES
    @testset "$name" begin
      for pc in PCS
        # pc -> E -> pc.  Loses accuracy at very low KE (E ~ m) so use rtol by regime.
        E = pc_to_E(sp, pc)
        if pc > 0.1*massof(sp)
          @test E_to_pc(sp, E) ≈ pc rtol = 1e-12
        end
        # R -> pc -> R
        R = pc_to_R(sp, pc)
        @test pc_to_R(sp, R_to_pc(sp, R)) ≈ R rtol = 1e-14
        # R -> E -> R (E_to_R returns the positive-pc branch: sign(q)*|R|)
        if pc > 0.1*massof(sp)
          @test E_to_R(sp, R_to_E(sp, R)) ≈ R rtol = 1e-12
        end
      end
      for g in GAMMAS
        E = g*massof(sp)
        @test pc_to_E(sp, E_to_pc(sp, E)) ≈ E rtol = 1e-13
        @test R_to_E(sp, E_to_R(sp, E))   ≈ E rtol = 1e-13
      end
    end
  end
end

# =======================================================================================
@testset "Relativistic identities" begin
  for (name, sp) in SPECIES
    @testset "$name" begin
      m = massof(sp)
      for pc in PCS
        R = pc_to_R(sp, pc)
        g  = R_to_gamma(sp, R)
        bg = R_to_beta_gamma(sp, R)
        v  = R_to_v(sp, R)
        beta = v/C_LIGHT
        E  = R_to_E(sp, R)

        @test g^2 ≈ 1 + bg^2 rtol = 1e-12
        @test g ≈ E/m rtol = 1e-14
        @test bg ≈ pc/m rtol = 1e-14
        @test beta ≈ pc/E rtol = 1e-14
        @test beta ≈ bg/g rtol = 1e-14
        @test abs(v) < C_LIGHT*(1 + 4eps())
        if g < 100   # 1/sqrt(1-beta^2) loses digits as beta -> 1
          @test 1/sqrt((1 - beta)*(1 + beta)) ≈ g rtol = 1e-10
        end
        # E_to_v only sees the rounded E, so the tolerance comes from error propagation
        @test E_to_v(sp, E) ≈ abs(v) rtol = 1e-13 + 4*eps()*(E/pc)^2
      end
    end
  end

  # Limits (proton)
  p = SPECIES["proton"]; m = massof(p)
  @test pc_to_E(p, 1e15) ≈ 1e15 rtol = 1e-6            # ultra-relativistic: E -> pc
  @test R_to_v(p, pc_to_R(p, 1e15)) ≈ C_LIGHT rtol = 1e-6
  @test R_to_v(p, pc_to_R(p, 1e3)) ≈ 1e3/m*C_LIGHT rtol = 1e-10  # non-relativistic: v = pc c / m
  @test R_to_gamma(p, pc_to_R(p, 1e3)) ≈ 1.0 rtol = 1e-10
  KE_nr = pc_to_E(p, 1e5) - m                          # non-relativistic KE = pc^2/2m
  @test KE_nr ≈ (1e5)^2/(2m) rtol = 1e-3
end

# =======================================================================================
@testset "Charge dependence (|Z| > 1)" begin
  p  = SPECIES["proton"]
  he = SPECIES["#4He+2"]
  c6 = SPECIES["#12C+6"]
  pb = SPECIES["#208Pb+82"]

  # Same pc: rigidity scales as 1/|q|
  pc = 1e10
  @test pc_to_R(he, pc) ≈ pc_to_R(p, pc)/2  rtol = 1e-15
  @test pc_to_R(c6, pc) ≈ pc_to_R(p, pc)/6  rtol = 1e-15
  @test pc_to_R(pb, pc) ≈ pc_to_R(p, pc)/82 rtol = 1e-15

  # Same R: pc scales as |q|
  R = 5.0
  @test R_to_pc(he, R) ≈ 2*R_to_pc(p, R)  rtol = 1e-15
  @test R_to_pc(c6, R) ≈ 6*R_to_pc(p, R)  rtol = 1e-15
  @test R_to_pc(pb, R) ≈ 82*R_to_pc(p, R) rtol = 1e-15

  # Energy depends on mass, NOT on charge, at fixed pc
  # (build a fake comparison: He pc -> E must equal sqrt(pc^2 + m_He^2))
  @test pc_to_E(he, pc) ≈ sqrt(pc^2 + massof(he)^2) rtol = 1e-15
  @test pc_to_E(pb, pc) ≈ sqrt(pc^2 + massof(pb)^2) rtol = 1e-15

  # R_to_E should include the charge: pc = R q c
  @test R_to_E(he, R) ≈ sqrt((R*2*C_LIGHT)^2 + massof(he)^2) rtol = 1e-15
  @test R_to_E(pb, R) ≈ sqrt((R*82*C_LIGHT)^2 + massof(pb)^2) rtol = 1e-15

  # E_to_R at fixed E scales as 1/|q| for equal masses (compare same-mass species)
  e_, pos = SPECIES["electron"], SPECIES["positron"]
  E = 10.0*massof(e_)
  @test E_to_R(pos, E) ≈ -E_to_R(e_, E) rtol = 1e-15   # opposite charge -> opposite sign R

  # Velocity at fixed R: heavier-per-charge ions are slower
  @test R_to_v(pb, 10.0) < R_to_v(p, 10.0)
  # Velocity depends only on pc/m, so same pc/m -> same v regardless of charge
  pc_he = 2*massof(he)           # pc/m = 2
  pc_pb = 2*massof(pb)
  @test R_to_v(he, pc_to_R(he, pc_he)) ≈ R_to_v(pb, pc_to_R(pb, pc_pb)) rtol = 1e-14

  # beta*gamma at fixed R scales with q/m
  @test R_to_beta_gamma(pb, R) / R_to_beta_gamma(p, R) ≈
        (82/massof(pb)) / (1/massof(p)) rtol = 1e-14
end

# =======================================================================================
@testset "Sign conventions (negative charges and negative pc)" begin
  for (name, sp) in SPECIES
    @testset "$name" begin
      q = chargeof(sp)
      pc = 1e10

      # forward pc>0 -> R has sign of q
      @test sign(pc_to_R(sp, pc)) == sign(q)
      @test sign(E_to_R(sp, 2*massof(sp))) == sign(q)

      # E, gamma, |v| always positive/magnitude; v is signed by pc
      R_fwd = pc_to_R(sp, pc)
      R_bwd = pc_to_R(sp, -pc)
      @test R_to_E(sp, R_fwd) == R_to_E(sp, R_bwd)
      @test R_to_gamma(sp, R_fwd) == R_to_gamma(sp, R_bwd)
      @test R_to_v(sp, R_fwd) > 0
      @test R_to_v(sp, R_bwd) < 0
      @test R_to_v(sp, R_fwd) ≈ -R_to_v(sp, R_bwd) rtol = 1e-15
      @test R_to_beta_gamma(sp, R_fwd) > 0
      @test R_to_beta_gamma(sp, R_bwd) < 0
      @test R_to_beta_gamma(sp, R_bwd) ≈ -R_to_beta_gamma(sp, R_fwd) rtol = 1e-15

      # E_to_v is a magnitude
      @test E_to_v(sp, 3*massof(sp)) > 0
      @test E_to_pc(sp, 3*massof(sp)) > 0
    end
  end

  # particle / antiparticle pairs: equal and opposite R, identical E, v, gamma
  for (a, b) in (("proton", "anti-proton"), ("electron", "positron"))
    sa, sb = SPECIES[a], SPECIES[b]
    pc = 3e9
    @test pc_to_R(sa, pc) ≈ -pc_to_R(sb, pc) rtol = 1e-15
    @test pc_to_E(sa, pc) == pc_to_E(sb, pc)
    Ra, Rb = pc_to_R(sa, pc), pc_to_R(sb, pc)
    @test R_to_E(sa, Ra) == R_to_E(sb, Rb)
    @test R_to_v(sa, Ra) == R_to_v(sb, Rb)
    @test R_to_gamma(sa, Ra) == R_to_gamma(sb, Rb)
    @test R_to_beta_gamma(sa, Ra) == R_to_beta_gamma(sb, Rb)
  end
end

# =======================================================================================
@testset "Domain and edge cases" begin
  for (name, sp) in SPECIES
    m = massof(sp)
    # E < m is unphysical
    @test_throws DomainError E_to_pc(sp, 0.5*m)
    @test_throws DomainError E_to_R(sp, 0.5*m)
    @test_throws DomainError E_to_pc(sp, 0.0)
    @test_throws DomainError E_to_pc(sp, -2*m)           # no silent sign trick
    @test_throws DomainError E_to_R(sp, -2*m)
    # E == m is exactly at rest
    @test E_to_pc(sp, m) == 0.0
    @test abs(E_to_R(sp, m)) == 0.0
    # zero
    @test R_to_E(sp, 0.0) == m
    @test pc_to_E(sp, 0.0) == m
    @test R_to_v(sp, 0.0) == 0.0
    @test !isnan(R_to_v(sp, 0.0))
    @test R_to_v(sp, -0.0) == 0.0
    # NaN / Inf propagate rather than crash silently into finite garbage
    @test isnan(pc_to_E(sp, NaN))
    @test isnan(R_to_E(sp, NaN))
    @test isnan(R_to_v(sp, NaN))
    @test isinf(pc_to_E(sp, Inf))
    @test isinf(R_to_E(sp, Inf))
  end

  # Very large and very small values
  p = SPECIES["proton"]
  @test isfinite(pc_to_E(p, 1e20))
  @test isfinite(R_to_gamma(p, pc_to_R(p, 1e20)))
  @test R_to_v(p, pc_to_R(p, 1e20)) ≤ C_LIGHT
  @test pc_to_E(p, 1e-30) == massof(p)                   # underflow-safe: E = m
  # Float32 inputs should not error
  @test isfinite(pc_to_E(p, 1f9))
  @test isfinite(R_to_v(p, 1f0))
  # Integer inputs should not error
  @test isfinite(pc_to_E(p, 1_000_000_000))
  @test isfinite(R_to_E(p, 3))
end

# =======================================================================================
@testset "Low-energy precision (cancellation)" begin
  # E_to_pc / E_to_v should be accurate when E is barely above m.
  for (name, sp) in SPECIES
    r = ref(sp)
    m = massof(sp)
    for eps_rel in (1e-4, 1e-6, 1e-8, 1e-10)
      E = m*(1 + eps_rel)
      Eb = big(E)                          # exact binary value of the Float64 E
      pcb = r.pc_of_E(Eb)
      @test E_to_pc(sp, E) ≈ Float64(pcb) rtol = 1e-12
      @test E_to_v(sp, E)  ≈ Float64(pcb*r.c/Eb) rtol = 1e-12
      @test E_to_R(sp, E)  ≈ Float64(r.R_of_pc(pcb)) rtol = 1e-12
    end
  end
end

# =======================================================================================
@testset "Delta conversions: linear (dR <-> dpc)" begin
  for (name, sp) in SPECIES
    @testset "$name" begin
      q = chargeof(sp)
      for d in (1e-9, 1e-3, 1.0, 1e3, -1e-3, -1.0)
        @test dR_to_dpc(sp, d) ≈ d*q*C_LIGHT rtol = 1e-15
        @test dpc_to_dR(sp, dR_to_dpc(sp, d)) ≈ d rtol = 1e-14
        @test dR_to_dpc(sp, dpc_to_dR(sp, d)) ≈ d rtol = 1e-14
      end
      @test dR_to_dpc(sp, 0.0) == 0.0
      @test dpc_to_dR(sp, 0.0) == 0.0

      # Linear deltas must equal differences of absolutes
      R0, dR = 7.0, 1e-3
      @test dR_to_dpc(sp, dR) ≈ R_to_pc(sp, R0 + dR) - R_to_pc(sp, R0) rtol = 1e-8
      pc0, dpc = 3e9, 1e5
      @test dpc_to_dR(sp, dpc) ≈ pc_to_R(sp, pc0 + dpc) - pc_to_R(sp, pc0) rtol = 1e-8

      # Independent of reference: additivity
      @test dR_to_dpc(sp, 1.0 + 2.0) ≈ dR_to_dpc(sp, 1.0) + dR_to_dpc(sp, 2.0) rtol = 1e-15
    end
  end
end

# =======================================================================================
@testset "Delta conversions: nonlinear vs BigFloat reference" begin
  for (name, sp) in SPECIES
    @testset "$name" begin
      r = ref(sp)
      m = massof(sp)

      # dpc -> dE
      for pc0 in PCS, rel in (1e-12, 1e-9, 1e-6, 1e-3, 0.1)
        dpc = rel*pc0
        exact = r.E_of_pc(big(pc0) + big(dpc)) - r.E_of_pc(big(pc0))
        @test dpc_to_dE(sp, pc0, dpc) ≈ Float64(exact) rtol = 1e-12
        # negative delta
        exactn = r.E_of_pc(big(pc0) - big(dpc)) - r.E_of_pc(big(pc0))
        @test dpc_to_dE(sp, pc0, -dpc) ≈ Float64(exactn) rtol = 1e-12
      end

      # dE -> dpc
      for g in (1.001, 1.1, 2.0, 10.0, 1e3, 1e6), rel in (1e-12, 1e-9, 1e-6, 1e-3, 0.1)
        E0 = g*m
        dE = rel*(E0 - m)                      # fraction of the kinetic energy
        dE == 0 && continue
        exact = r.pc_of_E(big(E0) + big(dE)) - r.pc_of_E(big(E0))
        @test dE_to_dpc(sp, E0, dE) ≈ Float64(exact) rtol = 1e-11
        exactn = r.pc_of_E(big(E0) - big(dE)) - r.pc_of_E(big(E0))
        @test dE_to_dpc(sp, E0, -dE) ≈ Float64(exactn) rtol = 1e-11
      end

      # dR -> dE and dE -> dR (positive-R branch for dE->dR when q > 0)
      for pc0 in PCS, rel in (1e-9, 1e-3, 0.1)
        R0 = pc_to_R(sp, pc0)
        dR = rel*R0
        exact = r.E_of_pc(r.pc_of_R(big(R0) + big(dR))) - r.E_of_pc(r.pc_of_R(big(R0)))
        @test dR_to_dE(sp, R0, dR) ≈ Float64(exact) rtol = 1e-11
      end
    end
  end
end

# =======================================================================================
@testset "Delta conversions: why they exist (naive subtraction fails, ours does not)" begin
  p = SPECIES["proton"]
  r = ref(p)
  pc0, dpc = 1e9, 1e-3                              # tiny delta, relative 1e-12
  naive = pc_to_E(p, pc0 + dpc) - pc_to_E(p, pc0)   # catastrophic cancellation
  exact = Float64(r.E_of_pc(big(pc0) + big(dpc)) - r.E_of_pc(big(pc0)))
  good  = dpc_to_dE(p, pc0, dpc)
  @test abs(good - exact)/abs(exact) < 1e-12
  @test abs(good - exact) <= abs(naive - exact)     # never worse than the naive result
end

# =======================================================================================
@testset "Delta conversions: consistency properties" begin
  for (name, sp) in SPECIES
    @testset "$name" begin
      m = massof(sp)
      pc0 = 5*m                                     # moderately relativistic
      E0  = pc_to_E(sp, pc0)
      R0  = pc_to_R(sp, pc0)

      # zero delta -> zero delta
      @test dpc_to_dE(sp, pc0, 0.0) == 0.0
      @test dE_to_dpc(sp, E0, 0.0)  == 0.0
      @test dR_to_dE(sp, R0, 0.0)   == 0.0
      @test dE_to_dR(sp, E0, 0.0)   == 0.0

      # delta result equals difference of absolutes (moderate delta, no cancellation issue)
      dpc = 0.05*pc0
      @test dpc_to_dE(sp, pc0, dpc) ≈ pc_to_E(sp, pc0 + dpc) - pc_to_E(sp, pc0) rtol = 1e-10
      dE = 0.05*E0
      @test dE_to_dpc(sp, E0, dE) ≈ E_to_pc(sp, E0 + dE) - E_to_pc(sp, E0) rtol = 1e-10
      dR = 0.05*R0
      @test dR_to_dE(sp, R0, dR) ≈ R_to_E(sp, R0 + dR) - R_to_E(sp, R0) rtol = 1e-10
      @test dE_to_dR(sp, E0, dE) ≈ E_to_R(sp, E0 + dE) - E_to_R(sp, E0) rtol = 1e-10

      # round trips
      for rel in (1e-3, 1e-2, 0.1, -1e-3, -1e-2, -0.1)
        dpc = rel*pc0
        @test dE_to_dpc(sp, E0, dpc_to_dE(sp, pc0, dpc)) ≈ dpc rtol = 1e-8
        dE = rel*(E0 - m)
        @test dpc_to_dE(sp, pc0, dE_to_dpc(sp, E0, dE)) ≈ dE rtol = 1e-8
        dR = rel*R0
        @test dE_to_dR(sp, E0, dR_to_dE(sp, R0, dR)) ≈ dR rtol = 1e-8
      end

      # additivity along a path: delta(a+b) = delta(a) + delta(from pc0+a, b)
      a, b = 0.01*pc0, 0.02*pc0
      @test dpc_to_dE(sp, pc0, a + b) ≈
            dpc_to_dE(sp, pc0, a) + dpc_to_dE(sp, pc0 + a, b) rtol = 1e-12

      # small-delta limit: dE ≈ (dE/dpc) dpc = (pc/E) dpc = beta dpc
      tiny = 1e-8*pc0
      beta = pc0/E0
      @test dpc_to_dE(sp, pc0, tiny) ≈ beta*tiny rtol = 1e-6
      # and dpc ≈ (E/pc) dE
      tinyE = 1e-8*(E0 - m)
      @test dE_to_dpc(sp, E0, tinyE) ≈ (E0/pc0)*tinyE rtol = 1e-6

      # Ultra-relativistic: dE ≈ dpc
      pcU = 1e6*m
      @test dpc_to_dE(sp, pcU, 1e-3*pcU) ≈ 1e-3*pcU rtol = 1e-6
    end
  end

  # Opposite-charge partners: dE is identical, dR flips sign
  e_, pos = SPECIES["electron"], SPECIES["positron"]
  pc0 = 1e8
  R_e, R_p = pc_to_R(e_, pc0), pc_to_R(pos, pc0)
  dpc = 1e3
  @test dpc_to_dE(e_, pc0, dpc) == dpc_to_dE(pos, pc0, dpc)
  @test dR_to_dE(e_, R_e, dpc_to_dR(e_, dpc)) ≈ dR_to_dE(pos, R_p, dpc_to_dR(pos, dpc)) rtol = 1e-14
  @test dpc_to_dR(e_, dpc) ≈ -dpc_to_dR(pos, dpc) rtol = 1e-15
end

# =======================================================================================
@testset "Delta conversions: negative pc0 (backward-moving)" begin
  # dpc_to_dE takes a signed pc0, so moving along the negative branch works.
  p = SPECIES["proton"]; r = ref(p)
  pc0 = -2e9
  for dpc in (1e3, -1e3, 1e6, -1e6)
    exact = r.E_of_pc(big(pc0) + big(dpc)) - r.E_of_pc(big(pc0))
    @test dpc_to_dE(p, pc0, dpc) ≈ Float64(exact) rtol = 1e-12
  end
  # Making |pc| larger raises E regardless of direction
  @test dpc_to_dE(p, -2e9, -1e6) > 0
  @test dpc_to_dE(p,  2e9,  1e6) > 0
  @test dpc_to_dE(p, -2e9,  1e6) < 0

  # dE_to_dpc is positive-branch only (documented): result has the sign of dE
  E0 = pc_to_E(p, 2e9)
  @test dE_to_dpc(p, E0,  1e6) > 0
  @test dE_to_dpc(p, E0, -1e6) < 0
end

# =======================================================================================
@testset "Delta conversions: edge cases" begin
  p = SPECIES["proton"]; m = massof(p)
  # Reference at rest: dE_to_dpc(E0 = m, dE > 0) is finite and positive
  @test isfinite(dE_to_dpc(p, m, 1e3))
  @test dE_to_dpc(p, m, 1e3) > 0
  @test dE_to_dpc(p, m, 1e3) ≈ sqrt(2*m*1e3 + 1e6) rtol = 1e-12   # pc(m+dE) = sqrt(dE(2m+dE))
  # Known degenerate case (documented): 0/0 when E0 == m and dE == 0
  @test isnan(dE_to_dpc(p, m, 0.0))
  # Going below the rest energy is unphysical
  @test_throws DomainError dE_to_dpc(p, 1.5*m, -1.0*m)
  # dpc_to_dE from rest
  @test dpc_to_dE(p, 0.0, 1e6) ≈ sqrt(1e12 + m^2) - m rtol = 1e-10
  @test dpc_to_dE(p, 0.0, 1e3) ≈ (1e3)^2/(2m) rtol = 1e-6          # non-relativistic KE
  @test dpc_to_dE(p, 0.0, 0.0) == 0.0
  # NaN propagation
  @test isnan(dpc_to_dE(p, 1e9, NaN))
  @test isnan(dE_to_dpc(p, 2m, NaN))
end

# =======================================================================================
#=
@testset "Automatic differentiation (ForwardDiff)" begin
  for (name, sp) in SPECIES
    @testset "$name" begin
      q = chargeof(sp); m = massof(sp)
      for pc in (1e6, 1e9, 1e12)
        R = pc_to_R(sp, pc)
        E = pc_to_E(sp, pc)
        beta = pc/E

        # d/dpc E = beta
        @test ForwardDiff.derivative(x -> pc_to_E(sp, x), pc) ≈ beta rtol = 1e-12
        # d/dR E = (q c)^2 R / E = q c beta
        @test ForwardDiff.derivative(x -> R_to_E(sp, x), R) ≈ q*C_LIGHT*beta rtol = 1e-12
        # d/dE pc = E/pc = 1/beta
        @test ForwardDiff.derivative(x -> E_to_pc(sp, x), E) ≈ 1/beta rtol = 1e-10
        # d/dR pc = q c  (linear, constant)
        @test ForwardDiff.derivative(x -> R_to_pc(sp, x), R) ≈ q*C_LIGHT rtol = 1e-14
        @test ForwardDiff.derivative(x -> pc_to_R(sp, x), pc) ≈ 1/(q*C_LIGHT) rtol = 1e-14
        # d/dR beta*gamma = q c / m (constant)
        @test ForwardDiff.derivative(x -> R_to_beta_gamma(sp, x), R) ≈ q*C_LIGHT/m rtol = 1e-14
        # d/dpc v = c m^2 / E^3
        @test ForwardDiff.derivative(x -> R_to_v(sp, pc_to_R(sp, x)), pc) ≈
              C_LIGHT*m^2/E^3 rtol = 1e-10
        # d/dpc gamma = beta/m
        @test ForwardDiff.derivative(x -> R_to_gamma(sp, pc_to_R(sp, x)), pc) ≈ beta/m rtol = 1e-10
      end

      # Derivatives well-defined at rest (this is where the old R_to_v gave NaN)
      @test ForwardDiff.derivative(x -> R_to_E(sp, x), 0.0) == 0.0
      @test ForwardDiff.derivative(x -> pc_to_E(sp, x), 0.0) == 0.0
      dv0 = ForwardDiff.derivative(x -> R_to_v(sp, x), 0.0)
      @test isfinite(dv0)
      @test dv0 ≈ q*C_LIGHT*C_LIGHT/m rtol = 1e-12            # dv/dR at R=0 = q c^2 / m
      @test isfinite(ForwardDiff.derivative(x -> R_to_gamma(sp, x), 0.0))

      # Delta functions differentiate cleanly
      pc0 = 5*m; E0 = pc_to_E(sp, pc0); R0 = pc_to_R(sp, pc0)
      # d(dE)/d(dpc) at dpc = 0 is beta
      @test ForwardDiff.derivative(x -> dpc_to_dE(sp, pc0, x), 0.0) ≈ pc0/E0 rtol = 1e-10
      # d(dpc)/d(dE) at dE = 0 is 1/beta
      @test ForwardDiff.derivative(x -> dE_to_dpc(sp, E0, x), 0.0) ≈ E0/pc0 rtol = 1e-10
      # d(dE)/d(dR) at dR = 0 is q c beta
      @test ForwardDiff.derivative(x -> dR_to_dE(sp, R0, x), 0.0) ≈
            chargeof(sp)*C_LIGHT*pc0/E0 rtol = 1e-10
      # Linear deltas have constant derivative
      @test ForwardDiff.derivative(x -> dR_to_dpc(sp, x), 123.0) ≈ q*C_LIGHT rtol = 1e-14
    end
  end

  # Gradient consistency: finite differences agree with AD (proton)
  p = SPECIES["proton"]
  f(x) = R_to_E(p, x)
  R0 = 4.0; h = 1e-5
  fd = (f(R0 + h) - f(R0 - h))/(2h)
  @test ForwardDiff.derivative(f, R0) ≈ fd rtol = 1e-6

  # Second derivative: d²E/dpc² = m²/E³
  m = massof(p); pc = 3e9; E = pc_to_E(p, pc)
  d2 = ForwardDiff.derivative(y -> ForwardDiff.derivative(x -> pc_to_E(p, x), y), pc)
  @test d2 ≈ m^2/E^3 rtol = 1e-10
end
=#

# =======================================================================================
@testset "Type stability and numeric types" begin
  p = SPECIES["proton"]
  @test pc_to_E(p, 1e9)  isa Float64
  @test R_to_pc(p, 1.0)  isa Float64
  @test dpc_to_dE(p, 1e9, 1e3) isa Float64
  @test dE_to_dpc(p, 2e9, 1e3) isa Float64
  @test (@inferred pc_to_E(p, 1e9)) isa Float64
  @test (@inferred R_to_E(p, 1.0)) isa Float64
  @test (@inferred E_to_pc(p, 2e9)) isa Float64
  @test (@inferred R_to_v(p, 1.0)) isa Float64
  @test (@inferred dpc_to_dE(p, 1e9, 1e3)) isa Float64
  @test (@inferred dE_to_dpc(p, 2e9, 1e3)) isa Float64
  @test (@inferred dR_to_dE(p, 1.0, 1e-3)) isa Float64
  @test (@inferred dE_to_dR(p, 2e9, 1e3)) isa Float64

  # BigFloat input stays BigFloat and agrees with Float64 to Float64 precision
  @test pc_to_E(p, big(1e9)) isa BigFloat
  @test Float64(pc_to_E(p, big(1e9))) ≈ pc_to_E(p, 1e9) rtol = 1e-15
  @test dpc_to_dE(p, big(1e9), big(1e3)) isa BigFloat

  # Broadcasting over arrays
  pcs = [1e6, 1e9, 1e12]
  @test pc_to_E.(Ref(p), pcs) ≈ [pc_to_E(p, x) for x in pcs]
  @test dpc_to_dE.(Ref(p), pcs, 1e-3 .* pcs) ≈ [dpc_to_dE(p, x, 1e-3*x) for x in pcs]
end

# =======================================================================================
@testset "Monotonicity and ordering" begin
  for (name, sp) in SPECIES
    pcs = sort(PCS)
    Es  = pc_to_E.(Ref(sp), pcs)
    vs  = R_to_v.(Ref(sp), pc_to_R.(Ref(sp), pcs))
    gs  = R_to_gamma.(Ref(sp), pc_to_R.(Ref(sp), pcs))
    @test issorted(Es)
    @test issorted(vs)
    @test issorted(gs)
    @test all(Es .≥ massof(sp))
    @test all(gs .≥ 1)
    @test all(0 .≤ vs .≤ C_LIGHT)
  end

  # Heavier species at same pc has lower velocity and higher E
  p, he = SPECIES["proton"], SPECIES["#4He+2"]
  pc = 1e10
  @test R_to_v(he, pc_to_R(he, pc)) < R_to_v(p, pc_to_R(p, pc))
  @test pc_to_E(he, pc) > pc_to_E(p, pc)
end

end # top-level testset