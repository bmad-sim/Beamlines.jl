using Beamlines
using Beamlines: isactive
using Test

@testset "Beamlines.jl" begin
    L = 5.0f0
    ele = LineElement(kind="Test", name="Test123", L=L)

    @test getfield(ele, :pdict)[UniversalParams] === ele.UniversalParams

    up = ele.UniversalParams
    @test isactive(up)
    @test up.kind == "Test"
    @test up.name == "Test123"
    @test typeof(up.L) == typeof(L)
    @test up.L == L
    @test up.tracking_method == SciBmadStandard()
    @test ele.kind == up.kind
    @test ele.name == up.name
    @test ele.L == up.L
    @test ele.tracking_method == up.tracking_method

    ele2 = deepcopy(ele)
    @test !(ele2 === ele)
    @test ele2 ≈ ele 

    up_new = UniversalParams(SciBmadStandard(), 10.0, "NewTest", "NewTest123")
    ele.UniversalParams = up_new
    @test ele.UniversalParams === up_new
    @test ele.kind == up_new.kind
    @test ele.name == up_new.name
    @test ele.L == up_new.L
    @test ele.tracking_method == up_new.tracking_method

    g_ref = 0.1
    e1 = 0.123
    e2 = 0.456

    # Check if pdict remains valid:
    @test_throws ErrorException getfield(ele, :pdict)[BendParams] = up_new
    @test_throws ErrorException getfield(ele, :pdict)[1] = 10.0
    @test_throws ErrorException getfield(ele, :pdict)[1] = up_new
    @test_throws ErrorException getfield(ele, :pdict)[UniversalParams] = 10.0

    @test !isactive(ele.BendParams)
    ele.g_ref = g_ref
    @test isactive(ele.BendParams)
    @test ele.g_ref == g_ref
    @test ele.e1 == 0
    @test ele.e2 == 0

    ele.e1 = e1
    ele.e2 = e2
    @test ele.e1 == e1
    @test ele.e2 == e2

    bp = BendParams(1.0im, 2.0im, 3.0im, 4.0im, 5.0im, 6.0im)
    @test eltype(bp) == ComplexF64
    @test eltype(typeof(bp)) == ComplexF64
    @test bp ≈ BendParams(1.0im, 2.0im, 3.0im, 4.0im, 5.0im, 6.0im)
    ele.BendParams = bp
    @test ele.BendParams === bp
    @test ele.g_ref == 1.0im
    @test ele.tilt_ref == 2.0im
    @test ele.e1 == 3.0im
    @test ele.e2 == 4.0im
    @test ele.edge_int1 == 5.0im
    @test ele.edge_int2 == 6.0im

    ele.g_ref = 0.2
    @test ele.g_ref == 0.2
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

    b1 = SBend(L=1.0f0, g=0.2f0)
    @test b1.Kn0 == 0.2f0
    @test b1.g_ref == b1.Kn0
    @test b1.g == b1.Kn0

    b1.Kn0 = im
    @test eltype(b1.BMultipoleParams) == ComplexF32
    @test eltype(b1.BendParams) == Float32
    @test b1.g == 0.2f0
    @test b1.g_ref == 0.2f0

    b1.g_ref = 0.3
    @test eltype(b1.BendParams) == Float64
    @test eltype(b1.BMultipoleParams) == ComplexF32
    @test b1.g_ref ==  0.3
    @test b1.g == 0.3
    @test b1.Kn0 == 1.0f0*im

    # Test storing Kn0L internally before setting g
    b2 = SBend(L=3.0, Kn0L=2, g=0.5)
    @test eltype(b2.BMultipoleParams) == Float64
    @test eltype(b2.BendParams) == Float64
    @test b2.g == 0.5
    @test b2.Kn0L == 0.5*3.0 # note NOT 2! changed by g, order matters
    @test b2.Kn0 == 0.5
    @test b2.g_ref == b2.g

    b2.g = 0.5*im
    @test eltype(b2.BendParams) == ComplexF64
    @test eltype(b2.BMultipoleParams) == ComplexF64
    @test b2.g == 0.5*im
    @test b2.Kn0 == 0.5*im
    @test b2.g_ref == b2.g
    @test b2.Kn0L == 0.5*im*3.0

    b3 = SBend(L=2.0, g_ref=3.0, Kn0=3.0*im)
    @test b3.g_ref == 3.0
    @test b3.Kn0 == 3.0*im
    @test b3.Kn0L == 6.0*im
    @test eltype(b3.BendParams) == Float64
    @test eltype(b3.BMultipoleParams) == ComplexF64
    b4 = SBend(L=2.0, angle=pi/2)
    @test b4.g_ref == pi/2/b4.L
    @test b4.Kn0 == pi/2/b4.L

    # Basic beamline:
    a = LineElement(L=0.5f0, Bn1=2.0f0)
    ele.Bn2L = 1.2
    ele.Kn1 = 0.36
    ele.L = 2.0
    bl = Beamline([a,ele])
    @test bl.line[1] === a
    @test bl.line[2] === ele
    @test_throws ErrorException bl.R_ref
    @test_throws ErrorException a.R_ref

    @test a.beamline_index == 1
    @test a.beamline === bl

    @test ele.beamline_index == 2
    @test ele.beamline === bl

    bl.R_ref = 5.0
    @test a.Kn1 == 2.0f0/5.0
    @test a.Kn1L == 0.5f0*2.0f0/5.0
    @test a.R_ref == 5.0
    a.R_ref = 6.0
    @test a.R_ref == 6.0
    a.R_ref = 5.0
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
    a.x1_limit = 70; a.x2_limit = 71; a.y1_limit = 72; a.y2_limit = 73;
    ele.x1_limit = 74; ele.x2_limit = 75; ele.y1_limit = 76; ele.y2_limit = 77;
    ele.aperture_shape = ApertureShape.Rectangular
    ele.aperture_at = ApertureAt.BothEnds
    ele.aperture_shifts_with_body = false
    ele.aperture_active = false
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
                   deepcopy_no_beamline(ele)], R_ref=60.0)
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

    fodo = Beamline([qf, d, qd, d, qf, d, qd, d], R_ref=60)
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

      local R_ref = 60.
      local Kn1 = 0.36
      local L = 0.5
      qf = Quadrupole(Kn1=DefExpr(()->Kn1), L=DefExpr(()->L))
      d = Drift(L=1)
      qd = Quadrupole(Kn1=DefExpr(()->-qf.Kn1), L=DefExpr(()->L))

      fodo = Beamline([qf, d, qd, d], R_ref=DefExpr(()->R_ref))

      @test fodo.R_ref == R_ref
      @test qf.R_ref == R_ref

      R_ref = 40.
      @test fodo.R_ref == R_ref
      @test qf.R_ref == R_ref

      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*R_ref*L
      @test qd.Bn1L ≈ -Kn1*R_ref*L
      @test qf.Bn1 ≈ Kn1*R_ref
      @test qd.Bn1 ≈ -Kn1*R_ref
      @test qf.L ≈ L
      @test qd.L ≈ L
      @test fodo.line[end].s_downstream ≈ 3
      L = 1
      @test qf.L == 1
      @test qd.L == 1
      @test fodo.line[end].s_downstream ≈ 4
      
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*R_ref*L
      @test qd.Bn1L ≈ -Kn1*R_ref*L
      @test qf.Bn1 ≈ Kn1*R_ref
      @test qd.Bn1 ≈ -Kn1*R_ref
  
      Kn1 = 0.2
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*R_ref*L
      @test qd.Bn1L ≈ -Kn1*R_ref*L
      @test qf.Bn1 ≈ Kn1*R_ref
      @test qd.Bn1 ≈ -Kn1*R_ref

      R_ref = 3*im
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*R_ref*L
      @test qd.Bn1L ≈ -Kn1*R_ref*L
      @test qf.Bn1 ≈ Kn1*R_ref
      @test qd.Bn1 ≈ -Kn1*R_ref

      Kn1 = 4*im
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*R_ref*L
      @test qd.Bn1L ≈ -Kn1*R_ref*L
      @test qf.Bn1 ≈ Kn1*R_ref
      @test qd.Bn1 ≈ -Kn1*R_ref
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
      
      local R_ref::Float64 = 60.
      local Kn1::Float64 = 0.36
      local L::Float64 = 0.5
      qf = Quadrupole(Kn1=DefExpr(()->Kn1), L=DefExpr(()->L))
      d = Drift(L=1)
      qd = Quadrupole(Kn1=DefExpr(()->-qf.Kn1), L=DefExpr(()->L))

      fodo = Beamline([qf, d, qd, d], R_ref=DefExpr(()->R_ref))

      @test fodo.R_ref == R_ref
      @test qf.R_ref == R_ref

      R_ref = 40.
      @test fodo.R_ref == R_ref
      @test qf.R_ref == R_ref

      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*R_ref*L
      @test qd.Bn1L ≈ -Kn1*R_ref*L
      @test qf.Bn1 ≈ Kn1*R_ref
      @test qd.Bn1 ≈ -Kn1*R_ref
      @test qf.L ≈ L
      @test qd.L ≈ L
      @test fodo.line[end].s_downstream ≈ 3
      L = 1.
      @test qf.L == 1.
      @test qd.L == 1.
      @test fodo.line[end].s_downstream ≈ 4
      
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*R_ref*L
      @test qd.Bn1L ≈ -Kn1*R_ref*L
      @test qf.Bn1 ≈ Kn1*R_ref
      @test qd.Bn1 ≈ -Kn1*R_ref
  
      Kn1 = 0.2
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*R_ref*L
      @test qd.Bn1L ≈ -Kn1*R_ref*L
      @test qf.Bn1 ≈ Kn1*R_ref
      @test qd.Bn1 ≈ -Kn1*R_ref

      R_ref = 3.0
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*R_ref*L
      @test qd.Bn1L ≈ -Kn1*R_ref*L
      @test qf.Bn1 ≈ Kn1*R_ref
      @test qd.Bn1 ≈ -Kn1*R_ref

      Kn1 = 4.0
      @test qf.Kn1L ≈ Kn1*L
      @test qd.Kn1L ≈ -Kn1*L
      @test qf.Bn1L ≈ Kn1*R_ref*L
      @test qd.Bn1L ≈ -Kn1*R_ref*L
      @test qf.Bn1 ≈ Kn1*R_ref
      @test qd.Bn1 ≈ -Kn1*R_ref
    end
    ele = LineElement(x1_limit=123,
                      x2_limit=456,
                      y1_limit=789, 
                      y2_limit=012, 
                      aperture_shape=ApertureShape.Elliptical, 
                      aperture_at=ApertureAt.Exit, 
                      aperture_shifts_with_body=false,
                      aperture_active=true)
    @test isactive(ele.ApertureParams)
    @test ele.x1_limit == 123
    @test ele.x1_limit == 123
    @test ele.x2_limit == 456
    @test ele.y1_limit == 789 
    @test ele.y2_limit == 012 
    @test ele.aperture_shape == ApertureShape.Elliptical
    @test ele.aperture_at == ApertureAt.Exit 
    @test ele.aperture_shifts_with_body == false
    @test ele.aperture_active == true
    
    ele.x1_limit = 12*im
    @test eltype(ele.ApertureParams) == ComplexF32
    @test eltype(typeof(ele.ApertureParams)) == ComplexF32
    @test ele.ApertureParams ≈ ApertureParams(12*im, 456, 789, 012, ApertureShape.Elliptical, ApertureAt.Exit, false, true)
    @test ele.x1_limit == 12*im
    @test ele.x1_limit == ComplexF32(12*im)
    @test ele.x2_limit == ComplexF32(456)
    @test ele.y1_limit == ComplexF32(789 )
    @test ele.y2_limit == ComplexF32(012 )
    @test ele.aperture_shape == ApertureShape.Elliptical
    @test ele.aperture_at == ApertureAt.Exit 
    @test ele.aperture_shifts_with_body == false
    @test ele.aperture_active == true  

    # RFParams tests
    @test !isactive(qf.RFParams)

    # Basic RF frequency mode
    cav = RFCavity(rf_frequency=352e6, voltage=1e6)
    @test isactive(cav.RFParams)
    cav.voltage = 0
    @test !isactive(cav.RFParams)
    cav.voltage=1e6
    @test isactive(cav.RFParams)
    @test cav.harmon_master == false && cav.rf_frequency == 352e6
    @test_throws ErrorException cav.harmon
    cav.rf_frequency = 500e6 + 1e3im
    @test cav.traveling_wave == false
    @test eltype(cav.RFParams) == ComplexF64
    @test eltype(typeof(cav.RFParams)) == ComplexF64
    cav.RFParams.rf_frequency = 210.1e6
    @test_throws ErrorException cav.RFParams.dx_rot
    @test_throws ErrorException cav.RFParams.dx_rot = 1.0
    @test_throws ErrorException cav.RFParams.harmon = 120
    

    # Harmonic number mode and mode switching
    cav2 = RFCavity()
    cav2.harmon_master = false
    cav2.rf_frequency = 352e6
    cav2.voltage = 200e6
    @test cav2.RFParams.rf_frequency == 352e6 && cav2.harmon_master == false
    @test_throws ErrorException cav2.harmon
    cav2.harmon = 1159
    cav2.harmon = 1160
    @test cav2.harmon == 1160 && cav2.harmon_master == true
    cav2.harmon_master = false
    @test cav2.harmon_master == false
    @test_throws ErrorException cav2.harmon == 1160 
  
    # Direct property access and RFParams struct operations
    cp = RFParams(rate=352e6, harmon_master=false)
    @test hasproperty(cp, :rf_frequency) && !hasproperty(cp, :harmon)
    @test_throws ErrorException cp.harmon
    cav2.RFParams = cp
    @test cav2.RFParams === cp

    bo = 1.23
    dbo = DefExpr(()->bo)

    ele = LineElement(
      x_offset  = dbo,
      y_offset  = dbo + 1,
      z_offset  = dbo + 2,
      x_rot     = dbo + 3,
      y_rot     = dbo + 4,
      tilt      = dbo + 5,
      x1_limit  = dbo + 6,
      x2_limit  = dbo + 7,
      y1_limit  = dbo + 8,
      y2_limit  = dbo + 9,
      g_ref     = dbo + 13,
      tilt_ref  = dbo + 14,
      e1        = dbo + 15,
      e2        = dbo + 16,
      edge_int1 = dbo + 30,
      edge_int2 = dbo + 31,
      Kn1    = dbo + 17,
      Bn2L   = dbo + 18,
      tilt3  = dbo + 19,
      dt     = dbo + 20,
      dx     = dbo + 21,
      dy     = dbo + 22,
      dz     = dbo + 23,
      dx_rot = dbo + 24,
      dy_rot = dbo + 25,
      dz_rot = dbo + 26,
      rf_frequency = dbo + 27,
      voltage = dbo + 28,
      phi0 = dbo + 29,
    )

    bo = 2.34
    @test Beamlines.deval(ele.AlignmentParams) ≈ AlignmentParams(bo, bo + 1, bo + 2, bo + 3, bo + 4, bo + 5)
    @test Beamlines.deval(ele.ApertureParams ) ≈ ApertureParams(bo + 6, bo + 7, bo + 8, bo + 9, ApertureShape.Elliptical, ApertureAt.Entrance, true, true)
    @test Beamlines.deval(ele.BendParams) ≈ BendParams(bo + 13, bo + 14, bo + 15,bo + 16, b0+30, b0+31)
    n = Beamlines.SizedVector{3}([bo+17, bo+18, 0])
    s = zero(n)
    tilt = Beamlines.SizedVector{3}([0, 0, bo+19])
    order = Beamlines.SA[2, 3, 4]
    normalized = Beamlines.SA[true, false, true]
    integrated = Beamlines.SA[false, true, true]
    @test Beamlines.deval(ele.BMultipoleParams) ≈ BMultipoleParams(n, s, tilt, order, normalized, integrated)
    @test Beamlines.deval(ele.PatchParams) ≈ PatchParams(bo + 20, bo + 21, bo + 22, bo + 23, bo + 24, bo + 25, bo + 26)
    @test Beamlines.deval(ele.RFParams) ≈ RFParams(bo + 27, bo + 28, bo + 29, false, false)

    # Species addition
    bl = Beamline([LineElement(), LineElement()]; R_ref=-59.52872449027632, species_ref=Species("electron"))
    @test bl.species_ref == Species("electron")
    @test bl.R_ref == -59.52872449027632
    @test bl.pc_ref ≈ 1.7846262612447e10
    @test bl.E_ref ≈ 1.784626264386055e10
    @test sqrt(bl.E_ref^2-bl.pc_ref^2) ≈ Beamlines.massof(bl.species_ref)
    bl = Beamline([LineElement(), LineElement()]; pc_ref=1.7846262612447e10, species_ref=Species("electron"))
    @test bl.species_ref == Species("electron")
    @test bl.R_ref ≈ -59.52872449027632
    @test bl.pc_ref ≈ 1.7846262612447e10
    @test bl.E_ref ≈ 1.784626264386055e10
    @test sqrt(bl.E_ref^2-bl.pc_ref^2) ≈ Beamlines.massof(bl.species_ref)
    bl = Beamline([LineElement(), LineElement()]; E_ref=1.784626264386055e10, species_ref=Species("electron"))
    @test bl.species_ref == Species("electron")
    @test bl.R_ref ≈ -59.52872449027632
    @test bl.pc_ref ≈ 1.7846262612447e10
    @test bl.E_ref ≈ 1.784626264386055e10
    @test abs(bl.pc_ref*sinh(acosh(bl.E_ref/bl.pc_ref)) - Beamlines.massof(bl.species_ref)) < 0.41 # Round off error here

    @test_throws ErrorException bl.dR_ref
    @test_throws ErrorException bl.dE_ref
    @test_throws ErrorException bl.dpc_ref
    @test bl.line[1].E_ref == bl.E_ref
    @test bl.line[1].R_ref == bl.R_ref
    @test bl.line[1].pc_ref == bl.pc_ref
    @test bl.line[2].E_ref == bl.E_ref
    @test bl.line[2].R_ref == bl.R_ref
    @test bl.line[2].pc_ref == bl.pc_ref

    @test Beamline(LineElement[], species_ref=Species("electron"), R_ref = 10).R_ref == -10
    ele = LineElement()
    bl1 = Beamline([ele])
    @test_throws ErrorException Beamline([ele])
    bl = Beamline(LineElement[], species_ref=Species("electron"), R_ref = 10)
    @test bl.R_ref == -10
    @test (bl.pc_ref = 0; bl.R_ref) == 0
    @test (bl.E_ref = Beamlines.massof(Species("electron")); bl.R_ref) == 0
    bl.R_ref = 10
    @test bl.R_ref == -10

    @test_throws ErrorException Beamline(LineElement[]).species_ref

    # Get unset property
    @test isnothing(LineElement().x1_limit)
    # Get write-only property
    @test_throws ErrorException LineElement(angle=1.0).angle

    # Test dR etc
    bl = Beamline(LineElement[]; dR_ref=-59.52872449027632, species_ref=Species("electron"))
    @test bl.species_ref == Species("electron")
    @test bl.dR_ref == -59.52872449027632
    @test_throws ErrorException bl.dpc_ref
    @test_throws ErrorException bl.dE_ref
    @test_throws ErrorException bl.R_ref
    @test_throws ErrorException bl.E_ref
    @test_throws ErrorException bl.pc_ref
    bl = Beamline(LineElement[]; dpc_ref=1.7846262612447e10, species_ref=Species("electron"))
    @test bl.species_ref == Species("electron")
    @test bl.dpc_ref == 1.7846262612447e10
    @test_throws ErrorException bl.dR_ref
    @test_throws ErrorException bl.dE_ref
    @test_throws ErrorException bl.R_ref
    @test_throws ErrorException bl.E_ref
    @test_throws ErrorException bl.pc_ref
    bl = Beamline(LineElement[]; dE_ref=1.784626264386055e10, species_ref=Species("electron"))
    @test bl.species_ref == Species("electron")
    @test bl.dE_ref == 1.784626264386055e10
    @test_throws ErrorException bl.dpc_ref
    @test_throws ErrorException bl.dR_ref
    @test_throws ErrorException bl.E_ref 
    @test_throws ErrorException bl.R_ref
    @test_throws ErrorException bl.pc_ref

    # InitialBeamlineParams
    ele = LineElement(species_ref=Species("electron"))
    @test_throws ErrorException ele.InitialBeamlineParams
    @test_throws ErrorException ele.InitialBeamlineParams = Beamlines.InitialBeamlineParams()
    @test Beamline([ele]).species_ref == Species("electron")
    ele = LineElement(species_ref=Species("electron"), dR_ref=-59.52872449027632)
    @test ele.dR_ref == -59.52872449027632
    @test_throws ErrorException ele.dpc_ref
    @test_throws ErrorException ele.dE_ref 
    ele.dpc_ref = 1.7846262612447e10
    @test ele.dpc_ref == 1.7846262612447e10
    @test_throws ErrorException ele.dR_ref
    @test_throws ErrorException ele.dE_ref
    ele.dE_ref = 1.784626264386055e10
    @test ele.dE_ref == 1.784626264386055e10
    @test_throws ErrorException ele.dR_ref 
    @test_throws ErrorException ele.dpc_ref
    ele.species_ref = Species("proton")
    @test ele.species_ref == Species("proton")
    @test ele.dE_ref == 1.784626264386055e10
    @test_throws ErrorException ele.dR_ref 
    @test_throws ErrorException ele.dpc_ref
    ele.E_ref = ele.dE_ref
    ele.species_ref = Species("electron")
    @test ele.species_ref == Species("electron")
    @test ele.R_ref ≈ -59.52872449027632
    @test ele.pc_ref ≈ 1.7846262612447e10
    @test ele.E_ref ≈ 1.784626264386055e10
    ele.pc_ref = 1.7846262612447e10
    @test ele.R_ref ≈ -59.52872449027632
    @test ele.pc_ref ≈ 1.7846262612447e10
    @test ele.E_ref ≈ 1.784626264386055e10
    ele.R_ref = -59.52872449027632
    @test ele.R_ref ≈ -59.52872449027632
    @test ele.pc_ref ≈ 1.7846262612447e10
    @test ele.E_ref ≈ 1.784626264386055e10

    # Get before setting anything
    @test_throws ErrorException LineElement().E_ref
    @test_throws ErrorException LineElement().species_ref
    @test_throws ErrorException LineElement(E_ref=18e9).species_ref
    @test_throws ErrorException LineElement(species_ref=Species("electron")).R_ref

     # Only valid at first element
    bl = Beamline([LineElement(), LineElement()], E_ref=10e9, species_ref=Species("electron"))
    @test_throws ErrorException bl.line[2].E_ref = 2e9
    bl.line[1].E_ref = 2e9
    @test bl.line[1].E_ref == 2e9
    @test bl.line[2].E_ref == 2e9
    @test bl.line[2].dR_ref == 0
    @test bl.line[2].dE_ref == 0
    @test bl.line[2].dpc_ref == 0
    @test_throws ErrorException bl.line[1].dR_ref
    @test_throws ErrorException bl.line[1].dE_ref
    @test_throws ErrorException bl.line[1].dpc_ref
    @test_throws ErrorException Beamline([LineElement(), LineElement(species_ref=Species("electron"))])
    @test_throws ErrorException Beamline([LineElement(), LineElement(R_ref=-39.)])
    @test_throws ErrorException Beamline([LineElement(), LineElement(E_ref=10e9, species_ref=Species("electron"))])

    # Overriding InitialBeamlineParams at Beamline level
    ele = LineElement(species_ref=Species("electron"), pc_ref=1.0)
    bl = Beamline([ele]; species_ref=Species("proton"), pc_ref=2.0)
    @test ele.species_ref == Species("proton")
    @test ele.pc_ref == 2.0
    # set thru first element
    ele.pc_ref = 3.0
    @test ele.pc_ref == 3.0
    # last cov
    bl.ref = 4.0
    @test bl.ref == 4.0

    # Lattices now
    bl1 = Beamline(LineElement[]; E_ref=10e9, species_ref=Species("electron"))
    bl2 = Beamline(LineElement[]; dE_ref=-3e9, species_ref=Species("proton"))
    @test_throws ErrorException bl1.dE_ref
    @test_throws ErrorException bl2.dpc_ref
    @test_throws ErrorException bl2.dR_ref
    @test bl2.dE_ref == -3e9
    lat = Lattice([bl1, bl2])
    @test bl2.E_ref == 7e9
    @test bl2.species_ref == Species("proton")
    @test bl2.dE_ref == -3e9
    @test bl1.dE_ref == 10e9
    @test bl2.R_ref - bl1.R_ref ≈ bl2.dR_ref
    @test bl2.E_ref - bl1.E_ref ≈ bl2.dE_ref
    @test bl2.pc_ref - bl1.pc_ref ≈ bl2.dpc_ref
    @test bl2.R_ref ≈ Beamlines.E_to_R(bl2.species_ref, bl2.E_ref)
    @test bl2.pc_ref ≈ Beamlines.E_to_pc(bl2.species_ref, bl2.E_ref)

    bl2.dpc_ref = -2e9
    bl1.R_ref = -40
    @test bl2.dpc_ref == -2e9
    @test bl1.R_ref == -40
    @test bl2.pc_ref - bl1.pc_ref ≈ bl2.dpc_ref
    @test bl2.E_ref - bl1.E_ref ≈ bl2.dE_ref
    @test bl2.R_ref - bl1.R_ref ≈ bl2.dR_ref

    bl2.dR_ref = -5
    bl1.pc_ref = 9e9
    @test bl2.pc_ref - bl1.pc_ref ≈ bl2.dpc_ref
    @test bl2.E_ref - bl1.E_ref ≈ bl2.dE_ref
    @test bl2.R_ref - bl1.R_ref ≈ bl2.dR_ref

    bl2.E_ref = 10e9
    @test bl2.E_ref == 10e9
    @test bl2.pc_ref - bl1.pc_ref ≈ bl2.dpc_ref
    @test bl2.E_ref - bl1.E_ref ≈ bl2.dE_ref
    @test bl2.R_ref - bl1.R_ref ≈ bl2.dR_ref

    @test_throws ErrorException Beamline(LineElement[]; pc_ref=1, dR_ref=2)
    @test_throws ErrorException Beamline(LineElement[]).lattice
    @test (bl = Beamline(LineElement[]; E_ref=10); lat = Lattice([bl]); bl.dE_ref) == 10
    @test_throws ErrorException Beamline(LineElement[]).lattice_index = 1
    @test_throws ErrorException Beamline(LineElement[]).lattice = Beamlines.NULL_LATTICE
    @test_throws ErrorException Beamline(LineElement[]).ref_meaning = Beamlines.RefMeaning.R_ref
    
    bl = Beamline(LineElement[])
    lat = Lattice([bl])
    @test_throws ErrorException Lattice([bl])

    @test Lattice([Beamline(LineElement[]; dR_ref=10.)]).beamlines[1].R_ref == 10.

    # Lattice LineElement ctor:
    ele1 = LineElement(E_ref=10e9, species_ref=Species("electron"))
    ele1a = LineElement()
    ele2 = LineElement(dE_ref=-3e9, species_ref=Species("proton"))
    ele2a = LineElement()
    ele2b = LineElement()
    lat = Lattice([ele1, ele1a, ele2, ele2a, ele2b])
    @test all(lat.beamlines[1].line .=== [ele1, ele1a])
    @test all(lat.beamlines[2].line .=== [ele2, ele2a, ele2b])
    bl1 = ele1.beamline
    bl2 = ele2.beamline
    @test bl2.E_ref == 7e9
    @test bl2.species_ref == Species("proton")
    @test bl2.dE_ref == -3e9
    @test bl1.dE_ref == 10e9
    @test bl2.R_ref - bl1.R_ref ≈ bl2.dR_ref
    @test bl2.E_ref - bl1.E_ref ≈ bl2.dE_ref
    @test bl2.pc_ref - bl1.pc_ref ≈ bl2.dpc_ref
    @test bl2.R_ref ≈ Beamlines.E_to_R(bl2.species_ref, bl2.E_ref)
    @test bl2.pc_ref ≈ Beamlines.E_to_pc(bl2.species_ref, bl2.E_ref)
    bl2.dpc_ref = -2e9
    bl1.R_ref = -40
    @test bl2.dpc_ref == -2e9
    @test bl1.R_ref == -40
    @test bl2.pc_ref - bl1.pc_ref ≈ bl2.dpc_ref
    @test bl2.E_ref - bl1.E_ref ≈ bl2.dE_ref
    @test bl2.R_ref - bl1.R_ref ≈ bl2.dR_ref
    bl2.dR_ref = -5
    bl1.pc_ref = 9e9
    @test bl2.pc_ref - bl1.pc_ref ≈ bl2.dpc_ref
    @test bl2.E_ref - bl1.E_ref ≈ bl2.dE_ref
    @test bl2.R_ref - bl1.R_ref ≈ bl2.dR_ref
    bl2.E_ref = 10e9
    @test bl2.E_ref == 10e9
    @test bl2.pc_ref - bl1.pc_ref ≈ bl2.dpc_ref
    @test bl2.E_ref - bl1.E_ref ≈ bl2.dE_ref
    @test bl2.R_ref - bl1.R_ref ≈ bl2.dR_ref


    # Check that InitialBeamlineParams is overridden:
    ele1 = LineElement(E_ref=10e9, species_ref=Species("electron"))
    ele1a = LineElement()
    lat = Lattice([ele1, ele1a]; species_ref0=Species("proton"), E_ref0=20e9)
    @test all(lat.beamlines[1].line .=== [ele1, ele1a])
    bl1 = ele1.beamline
    @test bl1.E_ref == 20e9
    @test bl1.species_ref == Species("proton")

    ele1 = LineElement(E_ref=10e9, species_ref=Species("electron"))
    ele1a = LineElement()
    ele2 = LineElement(dE_ref=-3e9, species_ref=Species("proton"))
    ele2a = LineElement()
    ele2b = LineElement()
    lat = Lattice([ele1, ele1a, ele2, ele2a, ele2b]; species_ref0=Species("proton"), E_ref0=20e9)
    @test all(lat.beamlines[1].line .=== [ele1, ele1a])
    @test all(lat.beamlines[2].line .=== [ele2, ele2a, ele2b])
    bl1 = ele1.beamline
    bl2 = ele2.beamline
    @test bl1.E_ref == 20e9
    @test bl1.species_ref == Species("proton")


    lat = Lattice([LineElement(), LineElement()]; species_ref0=Species("proton"), E_ref0=10e9)
    @test lat.beamlines[1].E_ref == 10e9
    @test lat.beamlines[1].species_ref == Species("proton")

    ele1 = LineElement()
    bl1 = Beamline([ele1])
    @test_throws ErrorException Lattice([ele1])
    @test_throws ErrorException Lattice(LineElement[]; E_ref0=10e9, pc_ref0=3e9)

    # MapParams
    f = (x,px,y,py,z,pz,q0,q1,q2,q3)->(1,2,3,4,5,6,7,8,9,10)
    g = (x,px,y,py,z,pz,q0,q1,q2,q3)->(11,12,13,14,15,16,17,18,19,20)
    ele1 = LineElement(transport_map=f)
    ele2 = LineElement(transport_map=f)
    @test !isnothing(ele1.MapParams)
    @test ele1.MapParams isa MapParams{typeof(f)}
    @test ele1.transport_map == f
    @test ele2.transport_map == f
    @test ele1 ≈ ele2
    ele1.transport_map = g
    ele2.transport_map = g
    @test ele1.MapParams isa MapParams{typeof(g)}
    @test ele1.transport_map == g
    @test ele2.transport_map == g
    @test ele1 ≈ ele2

    # FourPotentialParams
    f = (x,y,s,t)->(1,2,3,4)
    g = (x,y,s,t)->(5,6,7,8)
    ele1 = LineElement(four_potential=f)
    ele2 = LineElement(four_potential=f)
    @test !isnothing(ele1.FourPotentialParams)
    @test ele1.FourPotentialParams isa FourPotentialParams{typeof(f)}
    @test ele1.four_potential == f
    @test ele2.four_potential == f
    @test ele1 ≈ ele2
    ele1.four_potential = g
    ele2.four_potential = g
    @test ele1.FourPotentialParams isa FourPotentialParams{typeof(g)}
    @test ele1.four_potential == g
    @test ele2.four_potential == g
    @test ele1 ≈ ele2

    # MetaParams
    alias = "matt"
    label = "the matt"
    description = "this is a matt"
    ele = LineElement(alias=alias, label=label, description=description)
    @test ele.alias == alias
    @test ele.label == label
    @test ele.description == description

    alias = "david"
    label = "the david"
    description = "this is a david"
    ele.alias = alias
    ele.label = label
    ele.description = description
    @test ele.alias == alias
    @test ele.label == label
    @test ele.description == description
    @test ele ≈ LineElement()

    @test ele.MetaParams ≈ MetaParams()
end
