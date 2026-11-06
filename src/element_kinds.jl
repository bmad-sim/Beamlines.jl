function create_element(kind, tm, L, kwargs)
  if L != 0
    return LatElement(; L=L, kind=kind, tracking_method=tm, kwargs...)
  else
    return LatElement(; L=L, kind=kind, tracking_method=Exact(), kwargs...)
  end
end

for (kind, tm) in ((:Solenoid, :SolenoidKick), (:SBend, :BendKick), (:Quadrupole, :MatrixKick),
                   (:Sextupole, :DriftKick), (:Octupole, :DriftKick), (:Multipole, :DriftKick),
                   (:Drift, :DriftKick), (:VKicker, :DriftKick), (:HKicker, :DriftKick),
                   (:Kicker, :DriftKick), (:RFCavity, :SolenoidKick))
  @eval begin
    """
        $($kind)(; L=0f0, kwargs...)

    Constructs a `LatElement` with `kind = "$($kind)"`. If `L != 0`, the default `tracking_method`
    is `$($tm)()`, else `Exact()`. Any `tracking_method` in `kwargs` overrides the default.

    See the documentation for `LatElement`.
    """
    $kind(; L=0f0, kwargs...) = create_element("$($kind)", $tm(), L, kwargs)
  end
end

for kind in (:Marker, :BPM, :Patch, :Map)
  @eval begin
    """
        $($kind)(; L=0f0, kwargs...)

    Constructs a `LatElement` with `kind = "$($kind)"`. The default `tracking_method` is `Exact()`
    for any `L`. Any `tracking_method` in `kwargs` overrides the default.

    See the documentation for `LatElement`.
    """
    $kind(; L=0f0, kwargs...) = create_element("$($kind)", Exact(), L, kwargs)
  end
end

"""
    CrabCavity(; L=0f0, kwargs...)

Constructs a `LatElement` with `kind = "CrabCavity"` and `is_crabcavity = true`. If `L != 0`, the
default `tracking_method` is `SolenoidKick()`, else `Exact()`. Any `tracking_method` in `kwargs`
overrides the default.

See the documentation for `LatElement`.
"""
CrabCavity(; L=0f0, kwargs...) = create_element("CrabCavity", SolenoidKick(), L, (; is_crabcavity=true, kwargs...))

"""
    BeamBeam(; L=0f0, kwargs...)

Constructs a `LatElement` with `kind = "BeamBeam"`. The default `tracking_method` is `Implicit()`
for any `L`. Any `tracking_method` in `kwargs` overrides the default.

See the documentation for `LatElement`.
"""
BeamBeam(; L=0f0, kwargs...) = LatElement(; L=L, kind="BeamBeam", tracking_method=Implicit(), kwargs...) #create_element("BeamBeam", Implicit(), L, kwargs)
