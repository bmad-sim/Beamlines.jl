function create_element(kind, tm, L, kwargs)
  if L != 0
    return LatElement(; L=L, kind=kind, tracking_method=tm, kwargs...)
  else
    return LatElement(; kind=kind, tracking_method=Exact(), kwargs...)
  end
end

Solenoid(; L=0f0, kwargs...) = create_element("Solenoid", SolenoidKick(), L, kwargs)
SBend(; L=0f0, kwargs...) = create_element("SBend", BendKick(), L, kwargs)
Quadrupole(; L=0f0, kwargs...) = create_element("Quadrupole", MatrixKick(), L, kwargs)

for kind in (:Sextupole, :Octupole, :Multipole, :Drift, :VKicker, :HKicker, :Kicker)
  @eval begin
    $kind(; L=0f0, kwargs...) = create_element("$($kind)", DriftKick(), L, kwargs)
  end
end

for kind in (:Marker, :BPM, :Patch, :Map)
  @eval begin
    $kind(; L=0f0, kwargs...) = create_element("$($kind)", Exact(), L, kwargs)
  end
end

RFCavity(; L=0f0, kwargs...) = create_element("RFCavity", SolenoidKick(), L, kwargs)

CrabCavity(; L=0f0, kwargs...) = create_element("CrabCavity", SolenoidKick(), L, (; is_crabcavity=true, kwargs...))

BeamBeam(; L=0f0, kwargs...) = LatElement(; L=L, kind="BeamBeam", tracking_method=Implicit(), kwargs...) #create_element("BeamBeam", Implicit(), L, kwargs)
