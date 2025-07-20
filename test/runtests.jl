using Beamlines
using Beamlines: isactive
using Test

@testset "Beamlines.jl" begin
    L = 5.0f0
    ele = LineElement(class="Test", name="Test123", L=L)

    @test getfield(ele, :pdict)[UniversalParams] === ele.UniversalParams

    up = ele.UniversalParams
    @test isactive(up)
    @test up.class == "Test"
    @test up.name == "Test123"
    @test typeof(up.L) == typeof(L)
    @test up.L == L
    @test up.tracking_method == SciBmadStandard()
    @test ele.class == up.class
    @test ele.name == up.name
    @test ele.L == up.L
    @test ele.tracking_method == up.tracking_method

    ele2 = deepcopy(ele)
    @test !(ele2 === ele)
    @test ele2 ≈ ele 

    up_new = UniversalParams(SciBmadStandard(), 10.0, "NewTest", "NewTest123")
    ele.UniversalParams = up_new
    @test ele.UniversalParams === up_new
    @test ele.class == up_new.class
    @test ele.name == up_new.name
    @test ele.L == up_new.L
    @test ele.tracking_method == up_new.tracking_method

    g = 0.1
    e1 = 0.123
    e2 = 0.456

    # Check if pdict remains valid:
    @test_throws ErrorException getfield(ele, :pdict)[BendParams] = up_new
    @test_throws ErrorException getfield(ele, :pdict)[1] = 10.0
    @test_throws ErrorException getfield(ele, :pdict)[1] = up_new
    @test_throws ErrorException getfield(ele, :pdict)[UniversalParams] = 10.0

    @test !isactive(ele.BendParams)
    ele.g = g
    @test isactive(ele.BendParams)
    @test ele.g == g
    @test ele.e1 == 0
    @test ele.e2 == 0

    ele.e1 = e1
    ele.e2 = e2
    @test ele.e1 == e1
    @test ele.e2 == e2

    bp = BendParams(1.0im, 2.0im, 3.0im)
    @test eltype(bp) == ComplexF64
    @test eltype(typeof(bp)) == ComplexF64
    @test bp ≈ BendParams(1.0im, 2.0im, 3.0im)
    ele.BendParams = bp
    @test ele.BendParams === bp
    @test ele.g == 1.0im
    @test ele.e1 == 2.0im
    @test ele.e2 == 3.0im

    ele.g = 0.2
    @test ele.g == 0.2
    @test ele.BendParams === bp # do not change parameter group if promotion is ok

    @test !isactive(ele.AlignmentParams)
    ap = AlignmentParams(1, 2, 3, 4, 5, 6)
    @test eltype(ap) == Int
    @test eltype(typeof(ap)) == Int
    @test ap ≈ AlignmentParams(1, 2, 3, 4, 5, 6)
    ele.AlignmentParams = ap
    @test isactive(ele.AlignmentParams)
    @test ele.AlignmentParams === ap
    @test ele.x_offset == 1
    @test ele.y_offset == 2
    @test ele.z_offset == 3
    @test ele.x_rot == 4
    @test ele.y_rot == 5
    @test ele.tilt == 6

    ele.x_offset = 7
    @test ele.x_offset == 7
    @test ap.x_offset == 7
    @test ele.AlignmentParams === ap

    @test typeof(ele.x_offset) == Int
    ele.x_offset = 10.0
    @test ele.x_offset == 10.0
    @test !(ele.AlignmentParams === ap)
    @test typeof(ele.x_offset) == Float64

    @test !isactive(ele.BMultipoleParams)
    ele.Kn1 = 0.36
    @test isactive(ele.BMultipoleParams)
    @test ele.Kn1 == 0.36
    @test ele.Kn1L == 0.36*ele.L
    @test ele.BMultipoleParams.n[1] == 0.36
    @test !ele.BMultipoleParams.integrated[1]
    @test ele.BMultipoleParams.normalized[1]
    @test ele.BMultipoleParams.order[1] == 2
    @test ele.BMultipoleParams[2] == BMultipole(0.36,0.,0.,2,true,false)
    @test_throws ErrorException ele.BMultipoleParams[3]
    
    ele.L = 2.0
    @test ele.Kn1 == 0.36
    @test ele.Kn1L == 2.0*0.36

    ele.L = 2.0*im
    @test ele.Kn1 == 0.36
    @test ele.Kn1L == 2.0*im*0.36

    ele.Bn2L = 0.50
    @test ele.Bn2L == 0.50
    @test ele.Bn2 == 0.50/ele.L
    @test ele.BMultipoleParams.n[2] == 0.50
    @test ele.BMultipoleParams.integrated[2]
    @test !ele.BMultipoleParams.normalized[2]
    @test ele.BMultipoleParams[3] == BMultipole(0.50,0.,0.,3,false,true)
    
    # Test iteration over BMultipoles
    i = 1
    for bm in ele.BMultipoleParams
      if i == 1
        @test bm == BMultipole(0.36,0.,0.,2,true,false)
      else
        @test bm == BMultipole(0.50,0.,0.,3,false,true)
      end
       i += 1
    end
    @test i == 3

    @test eltype(ele.BMultipoleParams) == Float64
    ele.Bn2 = 1.2
    @test eltype(ele.BMultipoleParams) == ComplexF64 # promotion because length is complex
    @test ele.Bn2 == 1.2
    @test ele.Bn2L == 1.2*ele.L
    @test ele.Kn1 == 0.36
    @test ele.Kn1L == 2.0*im*0.36

    BM_indep = ele.BM_independent
    @test (; order=3, normalized=false, integrated=true) in BM_indep
    @test (; order=2, normalized=true, integrated=false) in BM_indep

    ele.BM_independent = [(; order=3, normalized=false, integrated=false),
                          (; order=2, normalized=true, integrated=true)]
    BM_indep2 = ele.BM_independent
    @test (; order=3, normalized=false, integrated=false) in BM_indep2
    @test (; order=2, normalized=true, integrated=true) in BM_indep2
    @test ele.Bn2 == 1.2
    @test ele.Kn1 == 0.36

    ele.BMultipoleParams = nothing
    ele.L = 5.0f0
    @test !isactive(ele.BMultipoleParams)
    ele.tilt0 = 1.0f0
    @test ele.BMultipoleParams.integrated[1]
    @test ele.BMultipoleParams.normalized[1]

    b1 = SBend(L=1.0f0, Kn0=0.2f0)
    @test b1.Kn0 == 0.2f0
    @test b1.g == b1.Kn0
    b2 = SBend(L=1.0, g=5.0)
    @test b2.Kn0 == 5.0
    @test b2.g == 5.0
    b3 = SBend(L=2.0, g=3.0, Kn0=3.0*im)
    @test b3.g == 3.0
    @test b3.Kn0 == 3.0*im
    @test b3.Kn0L == 6.0*im
    @test eltype(b3.BendParams) == Float64
    @test eltype(b3.BMultipoleParams) == ComplexF64
    b4 = SBend(L=2.0, angle=pi/2)
    @test b4.g == pi/2/b4.L
    @test b4.Kn0 == pi/2/b4.L

    # Basic beamline:
    a = LineElement(L=0.5f0, Bn1=2.0f0)
    ele.Bn2L = 1.2
    ele.Kn1 = 0.36
    ele.L = 2.0
    bl = Beamline([a,ele])
    @test bl.line[1] === a
    @test bl.line[2] === ele
    @test_throws ErrorException bl.Brho_ref
    @test_throws ErrorException a.Brho_ref

    @test a.beamline_index == 1
    @test a.beamline === bl

    @test ele.beamline_index == 2
    @test ele.beamline === bl

    bl.Brho_ref = 5.0
    @test a.Kn1 == 2.0f0/5.0
    @test a.Kn1L == 0.5f0*2.0f0/5.0
    @test a.Brho_ref == 5.0
    a.Brho_ref = 6.0
    @test a.Brho_ref == 6.0
    a.Brho_ref = 5.0
    @test eltype(a.BMultipoleParams) == Float32
    a.Kn1 = 123 # should cause promotion
    @test eltype(a.BMultipoleParams) == Float64
    @test a.Kn1 == 123
    @test a.Bn1 == 123*5.0
    @test a.Bn1L == 0.5*123*5.0
    @test !a.BMultipoleParams.integrated[1]
    @test !a.BMultipoleParams.normalized[1]
    # Sets:
    a.Kn1 = 0.5
    @test a.Kn1 ≈ 0.5
    a.Kn1L = 0.5
    @test a.Kn1L ≈ 0.5
    a.Bn1L = 0.5
    @test a.Bn1L ≈ 0.5

    a.Kn2 = 1.2
    @test a.Kn2 ≈ 1.2
    a.Kn2L = 1.2
    @test a.Kn2L ≈ 1.2
    a.Bn2L = 1.2
    @test a.Bn2L ≈ 1.2
    a.Bn2 = 1.2
    @test a.Bn2 ≈ 1.2

    a.Bn3L = 5.6
    @test a.Bn3L ≈ 5.6
    a.Bn3 = 5.6
    @test a.Bn3 ≈ 5.6
    a.Kn3L = 5.6
    @test a.Kn3L ≈ 5.6
    a.Kn3 = 5.6
    @test a.Kn3 ≈ 5.6

    a.Kn4L = 7.8
    @test a.Kn4L ≈ 7.8
    a.Kn4 = 7.8
    @test a.Kn4 ≈ 7.8
    a.Bs4L = 7.8
    @test a.Bs4L ≈ 7.8
    a.Bs4 = 7.8
    @test a.Bs4 ≈ 7.8

    ele.BMultipoleParams = nothing
    ele.Bsol = 1.0
    ele.Bn1L = 2.0
    ele.Kn2 = 3.0
    ele.Kn3L = 4.0

    BM_indep = ele.BM_independent
    @test length(BM_indep) == 4
    @test (; order=0, normalized=false, integrated=false) in BM_indep
    @test (; order=2, normalized=false, integrated=true) in BM_indep
    @test (; order=3, normalized=true, integrated=false) in BM_indep
    @test (; order=4, normalized=true, integrated=true) in BM_indep
    @test ele.Bsol == 1.0
    @test ele.Bn1L == 2.0
    @test ele.Kn2 == 3.0
    @test ele.Kn3L == 4.0

    ele.BM_independent = [(; order=0, normalized=true, integrated=true),
                          (; order=2, normalized=true, integrated=false),
                          (; order=3, normalized=false, integrated=true),
                          (; order=4, normalized=false, integrated=false),
                          (; order=5, normalized=true, integrated=false)]
    BM_indep2 = ele.BM_independent
    @test length(BM_indep2) == 5
    @test (; order=0, normalized=true, integrated=true) in BM_indep2
    @test (; order=2, normalized=true, integrated=false) in BM_indep2
    @test (; order=3, normalized=false, integrated=true) in BM_indep2
    @test (; order=4, normalized=false, integrated=false) in BM_indep2
    @test (; order=5, normalized=true, integrated=false) in BM_indep2

    @test ele.Bsol == 1.0
    @test ele.Bn1L == 2.0
    @test ele.Kn2 == 3.0
    @test ele.Kn3L == 4.0
    @test ele.Kn4 == 0.0

    ele.Kn4 = 5.0
    ele.field_master = true
    @test ele.field_master == true
    BM_indep3 = ele.BM_independent
    @test length(BM_indep3) == 5
    @test (; order=0, normalized=false, integrated=true) in BM_indep3
    @test (; order=2, normalized=false, integrated=false) in BM_indep3
    @test (; order=3, normalized=false, integrated=true) in BM_indep3
    @test (; order=4, normalized=false, integrated=false) in BM_indep3
    @test (; order=5, normalized=false, integrated=false) in BM_indep3

    @test ele.Bsol == 1.0
    @test ele.Bn1L == 2.0
    @test ele.Kn2 == 3.0
    @test ele.Kn3L == 4.0
    @test ele.Kn4 == 5.0

    ele.field_master = false   
    @test ele.field_master == false
    BM_indep4 = ele.BM_independent
    @test length(BM_indep4) == 5
    @test (; order=0, normalized=true, integrated=true) in BM_indep4
    @test (; order=2, normalized=true, integrated=false) in BM_indep4
    @test (; order=3, normalized=true, integrated=true) in BM_indep4
    @test (; order=4, normalized=true, integrated=false) in BM_indep4
    @test (; order=5, normalized=true, integrated=false) in BM_indep4

    @test ele.Bsol == 1.0
    @test ele.Bn1L == 2.0
    @test ele.Kn2 == 3.0
    @test ele.Kn3L == 4.0
    @test ele.Kn4 == 5.0

    ele.BM_independent = [(; order=0, normalized=true, integrated=true),
                          (; order=2, normalized=true, integrated=false),
                          (; order=3, normalized=false, integrated=true),
                          (; order=4, normalized=false, integrated=false),
                          (; order=5, normalized=true, integrated=false)]
    @test length(ele.BM_independent) == 5
    @test ele.Bsol == 1.0
    @test ele.Bn1L == 2.0
    @test ele.Kn2 == 3.0
    @test ele.Kn3L == 4.0
    @test ele.Kn4 == 5.0

    ele.integrated_master = true
    @test ele.integrated_master == true
    BM_indep5 = ele.BM_independent
    @test length(BM_indep5) == 5
    @test (; order=0, normalized=true, integrated=true) in BM_indep5
    @test (; order=2, normalized=true, integrated=true) in BM_indep5
    @test (; order=3, normalized=false, integrated=true) in BM_indep5
    @test (; order=4, normalized=false, integrated=true) in BM_indep5
    @test (; order=5, normalized=true, integrated=true) in BM_indep5
    @test ele.Bsol == 1.0
    @test ele.Bn1L == 2.0
    @test ele.Kn2 == 3.0
    @test ele.Kn3L == 4.0
    @test ele.Kn4 == 5.0

    ele.integrated_master = false
    @test ele.integrated_master == false
    BM_indep6 = ele.BM_independent
    @test length(BM_indep6) == 5
    @test (; order=0, normalized=true, integrated=false) in BM_indep6
    @test (; order=2, normalized=true, integrated=false) in BM_indep6
    @test (; order=3, normalized=false, integrated=false) in BM_indep6
    @test (; order=4, normalized=false, integrated=false) in BM_indep6
    @test (; order=5, normalized=true, integrated=false) in BM_indep6
    @test ele.Bsol == 1.0
    @test ele.Bn1L == 2.0
    @test ele.Kn2 == 3.0
    @test ele.Kn3L == 4.0
    @test ele.Kn4 == 5.0


    # BitsBeamline
    foreach(t->t.integrated_master=true, bl.line)
    foreach(t->t.field_master=true, bl.line)
    a.dt = 69.; a.dx = 68.; a.dy = 67.; a.dz = 66.; a.dx_rot = 65.; a.dy_rot = 64.; a.dz_rot =63.
    bbl = BitsBeamline(bl)
    bl2 = Beamline(bbl)
    @test all(bl.line .≈ bl2.line)

    foreach(t->t.field_master=false, bl.line)
    bbl = BitsBeamline(bl, store_normalized=true)
    bl2 = Beamline(bbl)
    @test all(bl.line .≈ bl2.line)

    
    # BitsBeamline with MultipleTrackingMethods
    struct MyTrackingMethod
      a::Float64
    end
    Beamlines.TRACKING_METHOD_MAP[MyTrackingMethod] = 0x1
    function Beamlines.get_tracking_method_extras(mt::MyTrackingMethod)
      return Beamlines.SA[mt.a]
    end

    bl.line[2].tracking_method = MyTrackingMethod(123.4)

    foreach(t->t.field_master=true, bl.line)
    bbl = BitsBeamline(bl)
    bl2 = Beamline(bbl)
    @test all(bl.line .≈ bl2.line)

    foreach(t->t.field_master=false, bl.line)
    bbl = BitsBeamline(bl, store_normalized=true)
    bl2 = Beamline(bbl)
    @test all(bl.line .≈ bl2.line)

    # BitsBeamline with repeat:
    bl = Beamline([deepcopy_no_beamline(a), 
                   deepcopy_no_beamline(ele), 
                   deepcopy_no_beamline(a), 
                   deepcopy_no_beamline(ele)], Brho_ref=60.0)
    foreach(t->t.field_master=true, bl.line)
    bbl = BitsBeamline(bl)
    bl2 = Beamline(bbl)
    @test all(bl.line .≈ bl2.line)

    foreach(t->t.field_master=false, bl.line)
    bbl = BitsBeamline(bl, store_normalized=true)
    bl2 = Beamline(bbl)
    @test all(bl.line .≈ bl2.line)
    

    # Controllers
    c = Controller(
      (a,   :Kn1) => (t; Kn1, L) -> Kn1,
      (ele, :L)  => (t; Kn1, L) -> L;
      vars = (; Kn1 = 0.0, L = 0.0,)
    )
    
    Kn1 = a.Kn1
    L = ele.L
    set!(c)
    @test a.Kn1 == 0.0
    @test ele.L == 0.0

    c.Kn1 = 123.4
    @test a.Kn1 == 123.4
    @test ele.L == 0.0

    c.L = 0.75
    @test a.Kn1 == 123.4
    @test ele.L == 0.75
    
    a.Kn1 = 0
    ele.L = 0

    set!(c)
    @test a.Kn1 == 123.4
    @test ele.L == 0.75

    c2 = Controller(
      (c, :Kn1) => (t; x) -> 2*x,
      (c, :L)  => (t; x) -> 3*x;
      vars = (; x = 1.0)
    )

    set!(c2)
    @test a.Kn1 == 2
    @test ele.L == 3

    c2.x = 2
    @test a.Kn1 == 4
    @test ele.L == 6

    a.Kn1 = 0
    ele.L = 0
    set!(c2)
    @test a.Kn1 == 4
    @test ele.L == 6

    @test c.vars == (; Kn1 = 4, L = 6)

    # check s computation
    @test a.s == 0
    @test a.s_downstream == a.L
    @test ele.s == a.L
    @test ele.s_downstream == a.L + ele.L

    @test !isactive(ele.PatchParams)
    pp = PatchParams(-1.2e-12, 1.23e-4, 0, -2, 0.0012, 5, 6)
    @test eltype(pp) == Float64
    @test eltype(typeof(pp)) == Float64
    @test pp ≈ PatchParams(-1.2e-12, 1.23e-4, 0, -2, 0.0012, 5, 6)
    ele.PatchParams = pp
    @test isactive(ele.PatchParams)
    @test ele.PatchParams === pp
    @test ele.dt == -1.2e-12 
    @test ele.dx == 1.23e-4
    @test ele.dy == 0 
    @test ele.dz == -2
    @test ele.dx_rot == 0.0012 
    @test ele.dy_rot == 5
    @test ele.dz_rot == 6

    ele.dt = 1.0
    @test ele.dt == 1.0
    @test typeof(ele.dt) == Float64
    @test ele.PatchParams === pp

    ele.dx = 1.0im
    ele.dy = 1
    ele.dz = 1
    ele.dx_rot = 1
    ele.dy_rot = 1
    ele.dz_rot = 1
    @test ele.dx == 1.0im
    @test ele.dy == 1
    @test ele.dz == 1
    @test ele.dx_rot == 1
    @test ele.dy_rot == 1
    @test ele.dz_rot == 1
    @test typeof(ele.dt) == ComplexF64
    @test typeof(ele.dx) == ComplexF64
    @test typeof(ele.dy) == ComplexF64
    @test typeof(ele.dz) == ComplexF64
    @test typeof(ele.dx_rot) == ComplexF64
    @test typeof(ele.dy_rot) == ComplexF64
    @test typeof(ele.dz_rot) == ComplexF64
    @test !(ele.PatchParams === pp)

    # @eles
    @eles qf = Quadrupole(Kn1=0.36)
    @test qf.name == "qf"
    @eles d = Drift()
    @test d.name == "d"
    
    @eles begin
      qf = Quadrupole(Kn1=0.36)
    end
    @test qf.name == "qf"

    @eles begin
      d = Drift()
    end
    @test d.name == "d"

    @eles begin
      qf = Quadrupole(Kn1=0.36)
      d = Drift()
    end
    @test qf.name == "qf"
    @test d.name == "d"

    @eles begin
      qf = Quadrupole(Kn1=0.36)
      a = 1+qf.Kn1
      d = Drift(L=a)
    end
    @test qf.name == "qf"
    @test d.name == "d"
    @test d.L == 1+0.36
    @test a == 1+0.36

    # Duplicate elements
    qf = Quadrupole(Kn1=0.36, L=0.5)
    d = Drift(L=1)
    qd = Quadrupole(Kn1=-0.36, L=0.5)

    fodo = Beamline([qf, d, qd, d, qf, d, qd, d], Brho_ref=60)
    @test qf === fodo.line[1]
    @test d === fodo.line[2]
    @test qd === fodo.line[3]
    @test !(d === fodo.line[4] )
    @test !(qf === fodo.line[5])
    @test !(qd === fodo.line[7])

    @test qf ≈ fodo.line[5]
    @test d ≈ fodo.line[4]
    @test qd ≈ fodo.line[7]

    qf2 = fodo.line[5]
    qf2.L = 2
    @test qf.L == 2
    @test qf2.L == 2
    @test qf2 ≈ qf
    qf.L = 0.5
    @test qf.L == 0.5
    @test qf2.L == 0.5
    @test qf2 ≈ qf
    qf.Kn1 = 0.1
    @test qf.Kn1 == 0.1
    @test qf2.Kn1 == 0.1
    
    qf2.Kn2 = 1.23
    @test qf.Kn2 == 1.23
    @test qf2.Kn2 == 1.23
    
    # Promote through child
    qf2.Kn2L = 1.23*im

    @test typeof(qf.Kn2L) == ComplexF64
    @test qf.Kn2L == 1.23*im
    @test typeof(qf2.Kn2L) == ComplexF64
    @test qf2.Kn2L == 1.23*im
    @test qf ≈ qf2 

    @test qf2.BMultipoleParams === qf.BMultipoleParams

    # Add new group through child
    qf2.x_rot = 0f0
    @test qf.AlignmentParams === qf2.AlignmentParams
    @test qf ≈ qf2

    qf2.AlignmentParams = AlignmentParams(1,2,3,4,5,6)
    @test qf.AlignmentParams === qf2.AlignmentParams
    @test qf ≈ qf2

    # s-position
    @test qf.s == 0
    @test qf.s_downstream == 0.5
    @test qf2.s == 3
    @test qf2.s_downstream == 3.5
    @test fodo.line[end].s_downstream == 6

    # Manual override 
    getfield(qf2, :pdict)[UniversalParams] = UniversalParams(L=1)
    @test qf2.BMultipoleParams === qf.BMultipoleParams
    @test !(qf.UniversalParams === qf2.UniversalParams)
    @test qf.L == 0.5
    @test qf2.L == 1
    @test qf.s == 0
    @test qf.s_downstream == 0.5
    @test qf2.s == 3
    @test qf2.s_downstream == 4
    @test fodo.line[end].s_downstream == 6.5
    @test qf2.Kn2L == qf2.Kn2*qf2.L
    @test qf2.Kn2 == qf.Kn2
    
    qf.Kn3L = 1
    @test qf2.Kn3L == 1
    @test qf2.Kn3L == qf2.Kn3*qf2.L
    @test qf2.Kn3*qf2.L == qf.Kn3*qf.L

    # ProtectParams
    getfield(qf2, :pdict)[Beamlines.ProtectParams] = Beamlines.ProtectParams([:L, :UniversalParams])
    @test qf2.L == 1 # get property (allowed)
    @test_throws ErrorException qf2.L = 2 # reset property (not allowed)
    @test_throws ErrorException qf2.UniversalParams # get parameter group (not allowed)
    @test_throws ErrorException qf2.UniversalParams = UniversalParams() # reset parameter group (not allowed)

    # Deferred Expressions
    # Function
    let 
      local a = 0.36
      da = DefExpr(()->a)
      @test da() == a
      a = 0.1
      @test da() == a
      local b = 0.2
      db = DefExpr(()->b)
      dc = da+db
      @test dc() ≈ 0.3
      dd = DefExpr{ComplexF64}(dc)
      @test dd() ≈ 0.3 && typeof(dd()) == ComplexF64

      a = 0.2
      @test dc() ≈ 0.4
      @test dd() ≈ 0.4 && typeof(dd()) == ComplexF64
      b = 0.3
      @test dc() ≈ 0.5
      @test dd() ≈ 0.5 && typeof(dd()) == ComplexF64

      local Brho_ref = 60.
      local Kn1 = 0.36
      local L = 0.5
      qf = Quadrupole(Kn1=DefExpr(()->Kn1), L=DefExpr(()->L))
      d = Drift(L=1)
      qd = Quadrupole(Kn1=DefExpr(()->-qf.Kn1), L=DefExpr(()->L))

      fodo = Beamline([qf, d, qd, d], Brho_ref=DefExpr(()->Brho_ref))

      @test fodo.Brho_ref == Brho_ref
      @test qf.Brho_ref == Brho_ref

      Brho_ref = 40.
      @test fodo.Brho_ref == Brho_ref
      @test qf.Brho_ref == Brho_ref

      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*Brho_ref*L
      @test qd.Bn1L ≈ -Kn1*Brho_ref*L
      @test qf.Bn1 ≈ Kn1*Brho_ref
      @test qd.Bn1 ≈ -Kn1*Brho_ref
      @test qf.L ≈ L
      @test qd.L ≈ L
      @test fodo.line[end].s_downstream ≈ 3
      L = 1
      @test qf.L == 1
      @test qd.L == 1
      @test fodo.line[end].s_downstream ≈ 4
      
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*Brho_ref*L
      @test qd.Bn1L ≈ -Kn1*Brho_ref*L
      @test qf.Bn1 ≈ Kn1*Brho_ref
      @test qd.Bn1 ≈ -Kn1*Brho_ref
  
      Kn1 = 0.2
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*Brho_ref*L
      @test qd.Bn1L ≈ -Kn1*Brho_ref*L
      @test qf.Bn1 ≈ Kn1*Brho_ref
      @test qd.Bn1 ≈ -Kn1*Brho_ref

      Brho_ref = 3*im
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*Brho_ref*L
      @test qd.Bn1L ≈ -Kn1*Brho_ref*L
      @test qf.Bn1 ≈ Kn1*Brho_ref
      @test qd.Bn1 ≈ -Kn1*Brho_ref

      Kn1 = 4*im
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*Brho_ref*L
      @test qd.Bn1L ≈ -Kn1*Brho_ref*L
      @test qf.Bn1 ≈ Kn1*Brho_ref
      @test qd.Bn1 ≈ -Kn1*Brho_ref
    end

    # CFunction
    let 
      local a::Float64 = 0.36
      da = DefExpr(()->a)
      @test da() == a
      a = 0.1
      @test da() == a
      local b::Float64 = 0.2
      db = DefExpr(()->b)
      dc = da+db
      @test dc() ≈ 0.3
      dd = DefExpr{ComplexF64}(dc)
      @test dd() ≈ 0.3 && typeof(dd()) == ComplexF64

      a = 0.2
      @test dc() ≈ 0.4
      @test dd() ≈ 0.4 && typeof(dd()) == ComplexF64
      b = 0.3
      @test dc() ≈ 0.5
      @test dd() ≈ 0.5 && typeof(dd()) == ComplexF64
      
      local Brho_ref::Float64 = 60.
      local Kn1::Float64 = 0.36
      local L::Float64 = 0.5
      qf = Quadrupole(Kn1=DefExpr(()->Kn1), L=DefExpr(()->L))
      d = Drift(L=1)
      qd = Quadrupole(Kn1=DefExpr(()->-qf.Kn1), L=DefExpr(()->L))

      fodo = Beamline([qf, d, qd, d], Brho_ref=DefExpr(()->Brho_ref))

      @test fodo.Brho_ref == Brho_ref
      @test qf.Brho_ref == Brho_ref

      Brho_ref = 40.
      @test fodo.Brho_ref == Brho_ref
      @test qf.Brho_ref == Brho_ref

      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*Brho_ref*L
      @test qd.Bn1L ≈ -Kn1*Brho_ref*L
      @test qf.Bn1 ≈ Kn1*Brho_ref
      @test qd.Bn1 ≈ -Kn1*Brho_ref
      @test qf.L ≈ L
      @test qd.L ≈ L
      @test fodo.line[end].s_downstream ≈ 3
      L = 1.
      @test qf.L == 1.
      @test qd.L == 1.
      @test fodo.line[end].s_downstream ≈ 4
      
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*Brho_ref*L
      @test qd.Bn1L ≈ -Kn1*Brho_ref*L
      @test qf.Bn1 ≈ Kn1*Brho_ref
      @test qd.Bn1 ≈ -Kn1*Brho_ref
  
      Kn1 = 0.2
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*Brho_ref*L
      @test qd.Bn1L ≈ -Kn1*Brho_ref*L
      @test qf.Bn1 ≈ Kn1*Brho_ref
      @test qd.Bn1 ≈ -Kn1*Brho_ref

      Brho_ref = 3.0
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*Brho_ref*L
      @test qd.Bn1L ≈ -Kn1*Brho_ref*L
      @test qf.Bn1 ≈ Kn1*Brho_ref
      @test qd.Bn1 ≈ -Kn1*Brho_ref

      Kn1 = 4.0
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*Brho_ref*L
      @test qd.Bn1L ≈ -Kn1*Brho_ref*L
      @test qf.Bn1 ≈ Kn1*Brho_ref
      @test qd.Bn1 ≈ -Kn1*Brho_ref
    end
    ele = LineElement(x1_limit=123,
                      x2_limit=456,
                      y1_limit=789, 
                      y2_limit=012, 
                      aperture_shape=ApertureShape.Elliptical, 
                      aperture_at=ApertureAt.Exit, 
                      aperture_shifts_with_body=false)
    @test isactive(ele.ApertureParams)
    @test ele.x1_limit == 123
    @test ele.x1_limit == 123
    @test ele.x2_limit == 456
    @test ele.y1_limit == 789 
    @test ele.y2_limit == 012 
    @test ele.aperture_shape == ApertureShape.Elliptical
    @test ele.aperture_at == ApertureAt.Exit 
    @test ele.aperture_shifts_with_body == false
    
    ele.x1_limit = 12*im
    @test eltype(ele.ApertureParams) == ComplexF32
    @test eltype(typeof(ele.ApertureParams)) == ComplexF32
    @test ele.ApertureParams ≈ ApertureParams(12*im, 456, 789, 012, ApertureShape.Elliptical, ApertureAt.Exit, false)
    @test ele.x1_limit == 12*im
    @test ele.x1_limit == ComplexF32(12*im)
    @test ele.x2_limit == ComplexF32(456)
    @test ele.y1_limit == ComplexF32(789 )
    @test ele.y2_limit == ComplexF32(012 )
    @test ele.aperture_shape == ApertureShape.Elliptical
    @test ele.aperture_at == ApertureAt.Exit 
    @test ele.aperture_shifts_with_body == false    

    # RFParams tests
    @test isnothing(qf.rf_frequency)

    # Basic RF frequency mode
    cav = RFCavity(rf_frequency=352e6, voltage=1e6)
    @test cav.harmon_master == false && cav.rf_frequency == 352e6
    @test_throws ErrorException cav.harmon
    cav.rf_frequency = 500e6 + 1e3im
    @test eltype(cav.RFParams) == ComplexF64
    @test eltype(typeof(cav.RFParams)) == ComplexF64
    cav.RFParams.rf_frequency = 210.1e6
    @test_throws ErrorException cav.RFParams.dx_rot
    @test_throws ErrorException cav.RFParams.dx_rot = 1.0

    # Harmonic number mode and mode switching
    cav2 = RFCavity(rf_frequency=352e6)
    cav2.voltage = 200e6
    @test cav2.RFParams.rf_frequency == 352e6 && cav2.harmon_master == false
    @test_throws ErrorException cav2.harmon
    cav2.harmon = 1159
    cav2.harmon = 1160
    @test cav2.harmon == 1160 && cav2.harmon_master == true
  
    # Direct property access and RFParams struct operations
    cp = RFParams(rate=352e6, harmon_master=false)
    @test hasproperty(cp, :rf_frequency) && !hasproperty(cp, :harmon)
    @test_throws ErrorException cp.harmon
    cav2.RFParams = cp
    @test cav2.RFParams === cp
end
