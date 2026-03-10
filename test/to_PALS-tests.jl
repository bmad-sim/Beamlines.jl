using Revise # Figure out how to automatically load this
using Beamlines
using YAML
using Test

struct CustomTrackingMethod 
    param1::String
    param2::Int
end

@testset "to_PALS.jl" begin
    #= ------------------------------------ =#
    # Test a basic FODO cell

    @elements drift1 = Drift( L = 0.25 )
    @elements quad1 = Quadrupole( L = 1.0, Bn1 = 1.0)
    @elements drift2 = Drift( L = 0.5)
    @elements quad2 = Quadrupole( L = 1.0, Bn1 = -1.0)
    @elements fodo_cell = Beamline( [drift1, quad1, drift2, quad2, drift1])
    @elements fodo_lattice = Lattice( [fodo_cell] )

    # Create the test file
    Beamlines.scibmad_to_pals(fodo_lattice, "test_fodo_cell")
    
    # Load the test file and the master test file into strings
    expected_file = YAML.load_file("test_fodo_cell_expected.pals.yaml")
    test_file = YAML.load_file("test_fodo_cell.pals.yaml")
    
    # Check if the created file exists
    @test isfile("test_fodo_cell.pals.yaml")
    # Check if the created file matches the expected
    @test test_file == expected_file
    

    #= ------------------------------------ =#
    # Test a FODO cell without names
    
    drift1 = Drift( L = 0.25 )
    quad1 = Quadrupole( L = 1.0, Bn1 = 1.0)
    drift2 = Drift( L = 0.5)
    quad2 = Quadrupole( L = 1.0, Bn1 = -1.0)
    fodo_cell = Beamline( [drift1, quad1, drift2, quad2, drift1])
    fodo_lattice = Lattice( [fodo_cell] )

    # Create the test file
    Beamlines.scibmad_to_pals(fodo_lattice, "test_unnamed_fodo_cell")
    
    # Load the test file and the master test file into strings
    expected_file = YAML.load_file("test_unnamed_fodo_cell_expected.pals.yaml")
    test_file = YAML.load_file("test_unnamed_fodo_cell.pals.yaml")
    
    # Check if the created file exists
    @test isfile("test_unnamed_fodo_cell.pals.yaml")
    # Check if the created file matches the expected
    @test test_file == expected_file


    #= ------------------------------------ =#
    # Test every type of element
    
    @elements solenoid = Solenoid(L = 1.0, Ksol = 0.142634259959)
    @elements sbend = SBend(L = 2.0, g = 4.1897690181481E-3, e1 = 6.295379021E-3, e2 = 6.295379021E-3)
    @elements quadrupole = Quadrupole(L = 3.0, Kn1 = 0.1776428377)
    @elements sextupole = Sextupole( L = 4.0, Kn2 = 2.465563152)
    @elements drift = Drift( L = 5.0)
    @elements octupole = Octupole( L = 6.0, Kn3 = 0.567856444535)
    @elements multipole = Multipole( L = 7.0, Bn1L = 4.31233, Kn4 = 4.4353)
    @elements marker = Marker()
    @elements kicker = HKicker( L = 8.0 )
    @elements rfcavity = RFCavity( L = 9.0 )
    @elements crabcavity = CrabCavity( L = 10.0, is_crabcavity=true)
    @elements patch = Patch( L = 11.0, dt = 1.0, dx_rot = .0988312)
    @elements beamline = Beamline( [solenoid, sbend, quadrupole, sextupole, drift, octupole, multipole, marker, kicker, rfcavity, crabcavity, patch])
    @elements lattice = Lattice( [beamline] )

    # Create the test file
    Beamlines.scibmad_to_pals(lattice, "test_every_element")
    
    # Load the test file and the master test file into strings
    expected_file = YAML.load_file("test_every_element_expected.pals.yaml")
    test_file = YAML.load_file("test_every_element.pals.yaml")
    
    # Check if the created file exists
    @test isfile("test_every_element.pals.yaml")
    # Check if the created file matches the expected
    @test test_file == expected_file


    #= ------------------------------------ =#
    # Test multiple beamlines
    
    @elements drift_1 = Drift( L = 0.25 )
    @elements quad_1 = Quadrupole( L = 1.0, Bn1 = 1.0)
    @elements drift_2 = Drift( L = 0.5)
    @elements quad_2 = Quadrupole( L = 1.0, Bn1 = -1.0)
    @elements fodo_cell_1 = Beamline( [drift_1, quad_1, drift_2, quad_2, drift_1])

    @elements drift_3 = Drift( L = 0.25 )
    @elements quad_3 = Quadrupole( L = 1.0, Bn1 = 1.0)
    @elements drift_4 = Drift( L = 0.5)
    @elements quad_4 = Quadrupole( L = 1.0, Bn1 = -1.0)
    @elements fodo_cell_2 = Beamline( [drift_3, quad_3, drift_4, quad_4, drift_3])

    @elements fodo_lattice = Lattice( [fodo_cell_1, fodo_cell_2] )

    # Create the test file
    Beamlines.scibmad_to_pals(fodo_lattice, "test_two_beamlines")
    
    # Load the test file and the master test file into strings
    expected_file = YAML.load_file("test_two_beamlines_expected.pals.yaml")
    test_file = YAML.load_file("test_two_beamlines.pals.yaml")
    
    # Check if the created file exists
    @test isfile("test_two_beamlines.pals.yaml")
    # Check if the created file matches the expected
    @test test_file == expected_file

    #= ------------------------------------ =#
    # Test non-standard tracking method
    
    @elements drift_one = Drift( L = 0.25, tracking_method = CustomTrackingMethod("ABC", 123) )
    @elements quad_one = Quadrupole( L = 1.0, Bn1 = 1.0, tracking_method = CustomTrackingMethod("ABC", 123) )
    @elements drift_two = Drift( L = 0.5, tracking_method = CustomTrackingMethod("ABC", 123) )
    @elements quad_two = Quadrupole( L = 1.0, Bn1 = -1.0, tracking_method = CustomTrackingMethod("ABC", 123) )
    @elements fodo_cell = Beamline( [drift_one, quad_one, drift_two, quad_two, drift_one] )
    @elements fodo_lattice = Lattice( [fodo_cell] )

    # Create the test file
    Beamlines.scibmad_to_pals(fodo_lattice, "test_custom_tracking")
    
    # Load the test file and the master test file into strings
    expected_file = YAML.load_file("test_custom_tracking_expected.pals.yaml")
    test_file = YAML.load_file("test_custom_tracking.pals.yaml")
    
    # Check if the created file exists
    @test isfile("test_custom_tracking.pals.yaml")
    # Check if the created file matches the expected
    @test test_file == expected_file
    
    return nothing
end