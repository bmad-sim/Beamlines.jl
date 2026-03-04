using Revise
using Beamlines

function test()
    @elements drift1 = Drift( L = 0.25)
    @elements quad1 = Quadrupole( L = 1.0, Bn1 = 1.0)
    @elements drift2 = Drift( L = 0.5)
    @elements quad2 = Quadrupole( L = 1.0, Bn1 = -1.0)
    @elements fodo_cell = Beamline( [drift1, quad1, drift2, quad2, drift1])
    @elements fodo_lattice = Lattice([fodo_cell])

    Beamlines.scibmad_to_pals(fodo_lattice, "test")
    return nothing
end

test()