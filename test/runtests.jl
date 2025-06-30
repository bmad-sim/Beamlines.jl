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
    ele.K1 = 0.36
    @test isactive(ele.BMultipoleParams)
    @test ele.K1 == 0.36
    @test ele.K1L == 0.36*ele.L
    @test ele.BMultipoleParams.K1 == 0.36
    @test_throws ErrorException ele.BMultipoleParams.K1L
    @test !ele.BMultipoleParams.bdict[2].integrated
    @test ele.BMultipoleParams.bdict[2].normalized
    
    ele.L = 2.0
    @test ele.K1 == 0.36
    @test ele.K1L == 2.0*0.36

    ele.L = 2.0*im
    @test ele.K1 == 0.36
    @test ele.K1L == 2.0*im*0.36

    ele.B2L = 0.50
    @test ele.B2L == 0.50
    @test ele.B2 == 0.50/ele.L
    @test ele.BMultipoleParams.B2L == 0.50
    @test_throws ErrorException ele.BMultipoleParams.B2

    @test ele.BMultipoleParams.bdict[3].integrated
    @test !ele.BMultipoleParams.bdict[3].normalized

    @test eltype(ele.BMultipoleParams) == Float64
    ele.B2 = 1.2
    @test eltype(ele.BMultipoleParams) == ComplexF64 # promotion because length is complex
    @test ele.B2 == 1.2
    @test ele.B2L == 1.2*ele.L
    @test ele.K1 == 0.36
    @test ele.K1L == 2.0*im*0.36

    BM_indep = ele.BM_independent
    @test :B2L in BM_indep
    @test :K1 in BM_indep

    ele.BM_independent = [:B2, :K1L]
    BM_indep2 = ele.BM_independent
    @test :B2 in BM_indep2
    @test :K1L in BM_indep2
    @test ele.B2 == 1.2
    @test ele.K1 == 0.36

    ele.BMultipoleParams = nothing
    ele.L = 5.0f0
    @test !isactive(ele.BMultipoleParams)
    ele.tilt0 = 1.0f0
    @test ele.BMultipoleParams.bdict[1].integrated
    @test !ele.BMultipoleParams.bdict[1].normalized
    @test_throws ErrorException ele.K0
    @test_throws ErrorException ele.K0L

    b1 = SBend(L=1.0f0, K0=0.2f0)
    @test b1.K0 == 0.2f0
    @test b1.g == b1.K0
    b2 = SBend(L=1.0, g=5.0)
    @test b2.K0 == 5.0
    @test b2.g == 5.0
    b3 = SBend(L=2.0, g=3.0, K0=3.0*im)
    @test b3.g == 3.0
    @test b3.K0 == 3.0*im
    @test b3.K0L == 6.0*im
    @test eltype(b3.BendParams) == Float64
    @test eltype(b3.BMultipoleParams) == ComplexF64
    b4 = SBend(L=2.0, angle=pi/2)
    @test b4.g == pi/2/b4.L
    @test b4.K0 == pi/2/b4.L

    # Basic beamline:
    a = LineElement(L=0.5f0, B1=2.0f0)
    ele.B2L = 1.2
    ele.K1 = 0.36
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
    @test a.K1 == 2.0f0/5.0
    @test a.K1L == 0.5f0*2.0f0/5.0
    @test a.Brho_ref == 5.0
    a.Brho_ref = 6.0
    @test a.Brho_ref == 6.0
    a.Brho_ref = 5.0
    @test eltype(a.BMultipoleParams) == Float32
    a.K1 = 123 # should cause promotion
    @test eltype(a.BMultipoleParams) == Float64
    @test a.K1 == 123
    @test a.B1 == 123*5.0
    @test a.B1L == 0.5*123*5.0
    @test !a.BMultipoleParams.bdict[2].integrated
    @test !a.BMultipoleParams.bdict[2].normalized
    # Sets:
    a.K1 = 0.5
    @test a.K1 ≈ 0.5
    a.K1L = 0.5
    @test a.K1L ≈ 0.5
    a.B1L = 0.5
    @test a.B1L ≈ 0.5

    a.K2 = 1.2
    @test a.K2 ≈ 1.2
    a.K2L = 1.2
    @test a.K2L ≈ 1.2
    a.B2L = 1.2
    @test a.B2L ≈ 1.2
    a.B2 = 1.2
    @test a.B2 ≈ 1.2

    a.B3L = 5.6
    @test a.B3L ≈ 5.6
    a.B3 = 5.6
    @test a.B3 ≈ 5.6
    a.K3L = 5.6
    @test a.K3L ≈ 5.6
    a.K3 = 5.6
    @test a.K3 ≈ 5.6

    a.K4L = 7.8
    @test a.K4L ≈ 7.8
    a.K4 = 7.8
    @test a.K4 ≈ 7.8
    a.B4L = 7.8
    @test a.B4L ≈ 7.8
    a.B4 = 7.8
    @test a.B4 ≈ 7.8

    ele.BMultipoleParams = nothing
    ele.Bs = 1.0
    ele.B1L = 2.0
    ele.K2 = 3.0
    ele.K3L = 4.0

    BM_indep = ele.BM_independent
    @test length(BM_indep) == 4
    @test :Bs in BM_indep
    @test :B1L in BM_indep
    @test :K2 in BM_indep
    @test :K3L in BM_indep
    @test ele.Bs == 1.0
    @test ele.B1L == 2.0
    @test ele.K2 == 3.0
    @test ele.K3L == 4.0

    ele.BM_independent = [:KsL, :K1, :B2L, :B3, :K4]
    BM_indep2 = ele.BM_independent
    @test length(BM_indep2) == 5
    @test :KsL in BM_indep2
    @test :K1 in BM_indep2
    @test :B2L in BM_indep2
    @test :B3 in BM_indep2
    @test :K4 in BM_indep2

    @test ele.Bs == 1.0
    @test ele.B1L == 2.0
    @test ele.K2 == 3.0
    @test ele.K3L == 4.0
    @test ele.K4 == 0.0

    ele.K4 = 5.0
    ele.field_master = true
    @test ele.field_master == true
    BM_indep3 = ele.BM_independent
    @test length(BM_indep3) == 5
    @test :BsL in BM_indep3
    @test :B1 in BM_indep3
    @test :B2L in BM_indep3
    @test :B3 in BM_indep3
    @test :B4 in BM_indep3

    @test ele.Bs == 1.0
    @test ele.B1L == 2.0
    @test ele.K2 == 3.0
    @test ele.K3L == 4.0
    @test ele.K4 == 5.0

    ele.field_master = false   
    @test ele.field_master == false
    BM_indep4 = ele.BM_independent
    @test length(BM_indep4) == 5
    @test :KsL in BM_indep4
    @test :K1 in BM_indep4
    @test :K2L in BM_indep4
    @test :K3 in BM_indep4
    @test :K4 in BM_indep4

    @test ele.Bs == 1.0
    @test ele.B1L == 2.0
    @test ele.K2 == 3.0
    @test ele.K3L == 4.0
    @test ele.K4 == 5.0

    ele.BM_independent = [:KsL, :K1, :B2L, :B3, :K4]
    @test length(ele.BM_independent) == 5
    @test ele.Bs == 1.0
    @test ele.B1L == 2.0
    @test ele.K2 == 3.0
    @test ele.K3L == 4.0
    @test ele.K4 == 5.0

    ele.integrated_master = true
    @test ele.integrated_master == true
    BM_indep5 = ele.BM_independent
    @test length(BM_indep5) == 5
    @test :KsL in BM_indep5
    @test :K1L in BM_indep5
    @test :B2L in BM_indep5
    @test :B3L in BM_indep5
    @test :K4L in BM_indep5
    @test ele.Bs == 1.0
    @test ele.B1L == 2.0
    @test ele.K2 == 3.0
    @test ele.K3L == 4.0
    @test ele.K4 == 5.0

    ele.integrated_master = false
    @test ele.integrated_master == false
    BM_indep6 = ele.BM_independent
    @test length(BM_indep6) == 5
    @test :Ks in BM_indep6
    @test :K1 in BM_indep6
    @test :B2 in BM_indep6
    @test :B3 in BM_indep6
    @test :K4 in BM_indep6
    @test ele.Bs == 1.0
    @test ele.B1L == 2.0
    @test ele.K2 == 3.0
    @test ele.K3L == 4.0
    @test ele.K4 == 5.0


    # BitsBeamline
    foreach(t->t.integrated_master=true, bl.line)
    foreach(t->t.field_master=true, bl.line)
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
      (a,   :K1) => (t; K1, L) -> K1,
      (ele, :L)  => (t; K1, L) -> L;
      vars = (; K1 = 0.0, L = 0.0,)
    )
    
    K1 = a.K1
    L = ele.L
    set!(c)
    @test a.K1 == 0.0
    @test ele.L == 0.0

    c.K1 = 123.4
    @test a.K1 == 123.4
    @test ele.L == 0.0

    c.L = 0.75
    @test a.K1 == 123.4
    @test ele.L == 0.75
    
    a.K1 = 0
    ele.L = 0

    set!(c)
    @test a.K1 == 123.4
    @test ele.L == 0.75

    c2 = Controller(
      (c, :K1) => (t; x) -> 2*x,
      (c, :L)  => (t; x) -> 3*x;
      vars = (; x = 1.0)
    )

    set!(c2)
    @test a.K1 == 2
    @test ele.L == 3

    c2.x = 2
    @test a.K1 == 4
    @test ele.L == 6

    a.K1 = 0
    ele.L = 0
    set!(c2)
    @test a.K1 == 4
    @test ele.L == 6

    @test c.vars == (; K1 = 4, L = 6)

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
    @eles qf = Quadrupole(K1=0.36)
    @test qf.name == "qf"
    @eles d = Drift()
    @test d.name == "d"
    
    @eles begin
      qf = Quadrupole(K1=0.36)
    end
    @test qf.name == "qf"

    @eles begin
      d = Drift()
    end
    @test d.name == "d"

    @eles begin
      qf = Quadrupole(K1=0.36)
      d = Drift()
    end
    @test qf.name == "qf"
    @test d.name == "d"

    @eles begin
      qf = Quadrupole(K1=0.36)
      a = 1+qf.K1
      d = Drift(L=a)
    end
    @test qf.name == "qf"
    @test d.name == "d"
    @test d.L == 1+0.36
    @test a == 1+0.36

    # Duplicate elements
    qf = Quadrupole(K1=0.36, L=0.5)
    d = Drift(L=1)
    qd = Quadrupole(K1=-0.36, L=0.5)

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
    qf.K1 = 0.1
    @test qf.K1 == 0.1
    @test qf2.K1 == 0.1
    
    qf2.K2 = 1.23
    @test qf.K2 == 1.23
    @test qf2.K2 == 1.23
    
    # Promote through child
    qf2.K2L = 1.23*im

    @test typeof(qf.K2L) == ComplexF64
    @test qf.K2L == 1.23*im
    @test typeof(qf2.K2L) == ComplexF64
    @test qf2.K2L == 1.23*im
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
    @test qf2.K2L == qf2.K2*qf2.L
    @test qf2.K2 == qf.K2
    
    qf.K3L = 1
    @test qf2.K3L == 1
    @test qf2.K3L == qf2.K3*qf2.L
    @test qf2.K3*qf2.L == qf.K3*qf.L

    # Deferred Expressions
    a = 0.36
    da = DefExpr(()->a)
    @test da() == a
    a = 0.1
    @test da() == a
    b = 0.2
    db = DefExpr(()->b)
    dc = da+db
    @test dc() ≈ 0.3

    a = 0.2
    @test dc() ≈ 0.4
    b = 0.3
    @test dc() ≈ 0.5

    Brho_ref = 60.
    K1 = 0.36
    L = 0.5
    qf = Quadrupole(K1=DefExpr(()->K1), L=DefExpr(()->L))
    d = Drift(L=1)
    qd = Quadrupole(K1=DefExpr(()->-qf.K1), L=DefExpr(()->L))

    fodo = Beamline([qf, d, qd, d], Brho_ref=DefExpr(()->Brho_ref))

    @test fodo.Brho_ref == Brho_ref
    @test qf.Brho_ref == Brho_ref

    Brho_ref = 40.
    @test fodo.Brho_ref == Brho_ref
    @test qf.Brho_ref == Brho_ref

    @test qf.K1L ≈ K1*L
    @test qd.K1L ≈ -K1*L
    @test qf.B1L ≈ K1*Brho_ref*L
    @test qd.B1L ≈ -K1*Brho_ref*L
    @test qf.B1 ≈ K1*Brho_ref
    @test qd.B1 ≈ -K1*Brho_ref
    @test qf.L ≈ L
    @test qd.L ≈ L
    @test fodo.line[end].s_downstream ≈ 3
    L = 1
    @test qf.L == 1
    @test qd.L == 1
    @test fodo.line[end].s_downstream ≈ 4
    
    @test qf.K1L ≈ K1*L
    @test qd.K1L ≈ -K1*L
    @test qf.B1L ≈ K1*Brho_ref*L
    @test qd.B1L ≈ -K1*Brho_ref*L
    @test qf.B1 ≈ K1*Brho_ref
    @test qd.B1 ≈ -K1*Brho_ref
 
    K1 = 0.2
    @test qf.K1L ≈ K1*L
    @test qd.K1L ≈ -K1*L
    @test qf.B1L ≈ K1*Brho_ref*L
    @test qd.B1L ≈ -K1*Brho_ref*L
    @test qf.B1 ≈ K1*Brho_ref
    @test qd.B1 ≈ -K1*Brho_ref

    Brho_ref = 3*im
    @test qf.K1L ≈ K1*L
    @test qd.K1L ≈ -K1*L
    @test qf.B1L ≈ K1*Brho_ref*L
    @test qd.B1L ≈ -K1*Brho_ref*L
    @test qf.B1 ≈ K1*Brho_ref
    @test qd.B1 ≈ -K1*Brho_ref

    K1 = 4*im
    @test qf.K1L ≈ K1*L
    @test qd.K1L ≈ -K1*L
    @test qf.B1L ≈ K1*Brho_ref*L
    @test qd.B1L ≈ -K1*Brho_ref*L
    @test qf.B1 ≈ K1*Brho_ref
    @test qd.B1 ≈ -K1*Brho_ref
end
