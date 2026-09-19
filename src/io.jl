"""
`writebl` is internal, still being developed, and may change at any time. 
General users should NOT use it yet.
"""
function writebl(fname::AbstractString, bl::Beamline)
  open(fname, "w") do io
    writebl(io, bl)
  end
end

function writebl(io::IO, bl::Beamline)
  c = bl.context
  pgs = [ :UniversalParams, :InitialBeamlineParams, :AlignmentParams, :BendParams, :BMultipoleParams, 
          :PatchParams, :ApertureParams, :MapParams, :RFParams, :FourPotentialParams, :EMultipoleParams]
  println(io, "Beamline([")
  for ele in bl.line
    print(io, " LineElement(")
    for pg in map(x->deval(getproperty(ele, x), c), pgs)
      if isnothing(pg)
        continue
      end
      writeparam(io, pg)
    end
    if !isempty(ele.do_not_use)
      print(io, "do_not_use=", ele.do_not_use, ",")
    end
    println(io, ")")
  end
  print(io, "])")
  return
end

function writeparam(io::IO, a::AbstractParams)
  fields = fieldnames(typeof(a))
  for field in fields
    print(io, String(field), "=", param_repr(getproperty(a, field)), ",")
  end
  return
end

# For UniversalParams, print each tracking_method field:
function writeparam(io::IO, a::UniversalParams)
  fields = fieldnames(typeof(a))
  for field in fields
    if field == :tracking_method
      tm = getproperty(a, field)
      print(io, String(field), "=", typeof(tm), "(")
      subfields = fieldnames(typeof(tm))
      for subfield in subfields
        print(io, String(subfield), "=", param_repr(getproperty(tm, subfield)), ",")
      end
      print(io, "),")
    else
      print(io, String(field), "=", param_repr(getproperty(a, field)), ",")
    end
  end
  return
end

function writeparam(io::IO, a::InitialBeamlineParams)
  try 
    species_ref = a.species_ref
    name = nameof(species_ref)
    print(io, "species_ref=Species(\"", name, "\"),")
  catch
  end
  try
    ref = a.ref
    ref_meaning = refmeaning_to_sym(a.ref_meaning)
    println(io, String(ref_meaning), "=", param_repr(ref), ",")
  catch
  end
  return
end

function writeparam(io::IO, b::BMultipoleParams)
  for bm in b
    n = bm.n
    s = bm.s
    tilt = bm.tilt
    if n != 0
      sym = BMULTIPOLE_STRENGTH_INVERSE_MAP[(true, bm.order, bm.normalized, bm.integrated)]
      print(io, String(sym), "=", param_repr(n), ",")
    end
    if s != 0
      sym = BMULTIPOLE_STRENGTH_INVERSE_MAP[(false, bm.order, bm.normalized, bm.integrated)]
      print(io, String(sym), "=", param_repr(s), ",")
    end
    if tilt != 0
      sym = BMULTIPOLE_TILT_INVERSE_MAP[bm.order]
      print(io, String(sym), "=", param_repr(tilt), ",")
    end
  end
  return
end

function writeparam(io::IO, e::EMultipoleParams)
  for em in e
    n = em.n
    s = em.s
    tilt = em.tilt
    if n != 0
      sym = EMULTIPOLE_STRENGTH_INVERSE_MAP[(true, em.order, em.integrated)]
      print(io, String(sym), "=", param_repr(n), ",")
    end
    if s != 0
      sym = EMULTIPOLE_STRENGTH_INVERSE_MAP[(false, em.order, em.integrated)]
      print(io, String(sym), "=", param_repr(s), ",")
    end
    if tilt != 0
      sym = EMULTIPOLE_TILT_INVERSE_MAP[em.order]
      print(io, String(sym), "=", param_repr(tilt), ",")
    end
  end
  return
end

function writeparam(io::IO, a::RFParams)
  fields = fieldnames(RFParams)
  if a.rate_meaning == RateMeaning.RFFrequency
    print(io, "rf_frequency=", param_repr(a.rate), ",")
  elseif a.rate_meaning == RateMeaning.Harmon
    print(io, "harmon=", param_repr(a.rate), ",")
  end
  for field in fields
    if field == :rate || field == :rate_meaning
      continue
    end
    print(io, String(field), "=", param_repr(getproperty(a, field)), ",")
  end
  return
end