using Revise
using Beamlines
using tests

@testset "to_PALS.jl" begin
    # Create a basic FODO cell
    @elements drift1 = Drift( L = 0.25)
    @elements quad1 = Quadrupole( L = 1.0, Bn1 = 1.0)
    @elements drift2 = Drift( L = 0.5)
    @elements quad2 = Quadrupole( L = 1.0, Bn1 = -1.0)
    @elements fodo_cell = Beamline( [drift1, quad1, drift2, quad2, drift1])
    @elements fodo_lattice = Lattice([fodo_cell])

    Beamlines.scibmad_to_pals(fodo_lattice, "test")

    # Test every element
    @elements solenoid = Solenoid( L = 1.0, Ksol = 0.2345334)
    @elements sbend = SBend( L = 3.8000605852935, g = 5.1475963740429E-3, e1 = 9.780589045E-3, e2 = 9.780589045E-3)
    @elements quad1 = Quadrupole( L = 1.0, Bn1 = 1.0)
    @elements sextupole = Sextupole( L = 0.24, Kn2 = 2.465563152)
    @elements drift =  Drift( L = 5.3)
    @elements octupole = Octupole( L = 0.77, Kn7 = 5.6765, Bn2 = 9.4546)
    @elements quad1 = Multipole( L = 1.0, Bn1 = 1.0, Kn3 = 5.6)
    @elements marker = Marker()
    @elements kicker =  VKicker( L = 0.2)
    @elements rfcavity =  RFCavity( L = 4.01667)
    @elements crab_cavity = CrabCavity( L = 4.01667, is_crabcavity = true)
    @elements patch = Patch( L = 0.44 )

    @elements beamline = Beamline( [solenoid, sbend, quad1, sextupole, drift, octupole, quad1, marker, kicker,
    rfcavity, crab_cavity, patch])
    @elements fodo_lattice = Lattice([beamline])

    Beamlines.scibmad_to_pals(fodo_lattice, "test2")

    # Test multiple lines
    @elements drift1a = Drift( L = 0.25)
    @elements quad1a = Quadrupole( L = 1.0, Bn1 = 1.0)
    @elements drift2a = Drift( L = 0.5)
    @elements quad2a = Quadrupole( L = 1.0, Bn1 = -1.0)

    @elements drift1b = Drift( L = 0.25)
    @elements quad1b = Quadrupole( L = 1.0, Bn1 = 1.0)
    @elements drift2b = Drift( L = 0.5)
    @elements quad2b = Quadrupole( L = 1.0, Bn1 = -1.0)

    @elements beamline1 = Beamline( [drift1a, quad1a, drift2a, quad2a, drift1a] )
    @elements beamline2 = Beamline( [drift1b, quad1b, drift2b, quad2b, drift1b] )
    @elements fodo_lattice = Lattice([beamline1, beamline2])

    Beamlines.scibmad_to_pals(fodo_lattice, "test3")
end