"""
`writebl` is internal, still being developed, and may change at any time. 
General users should NOT use it yet.

    writebl(fname_or_io, bl::Beamline)
    writebl(fname_or_io, lat::Lattice)

Writes Julia code that reconstructs `bl` or `lat`. For a `Beamline`, the `fork_orientation` 
and `fork_propagate_reference` of any `ForkParams` are written but `fork_connect_element` is 
not. For a `Lattice`, each `Branch` is written as a variable `b<i>`, followed by the fork 
connections (e.g. `b1[2].fork_connect_element = b2[1]`), followed by the `Lattice` 
constructor, so the forks are reconstructed.
"""
function writebl(fname::AbstractString, x::Union{Beamline,Lattice})
  open(fname, "w") do io
    writebl(io, x)
  end
end

const WRITEBL_PARAMS = [:UniversalParams, :InitialBeamlineParams, :AlignmentParams, :BendParams, 
                        :BMultipoleParams, :PatchParams, :ApertureParams, :MapParams, :RFParams, 
                        :FourPotentialParams, :EMultipoleParams, :ForkParams]

writebl(io::IO, bl::Beamline) = _writebl(io, bl, "", ele -> true)

# `write_fork(ele)` says whether the ForkParams of `ele` (if any) is written.
function _writebl(io::IO, bl::Beamline, indent::String, write_fork)
  c = bl.context
  println(io, indent, "Beamline([")
  for ele in bl.line
    print(io, indent, " LineElement(")
    for pgsym in WRITEBL_PARAMS
      pg = deval(getproperty(ele, pgsym), c)
      if isnothing(pg) || (pg isa ForkParams && !write_fork(ele))
        continue
      end
      writeparam(io, pg)
    end
    println(io, ")")
  end
  print(io, indent, "])")
  return
end

function writebl(io::IO, lat::Lattice)
  # Fork connections to write, as (element, connected element). Each element of a Lattice 
  # with a fork_connect_element is in a connected pair. If the two elements point at each 
  # other with the same fork_orientation and fork_propagate_reference, only one connection 
  # is written (from the Fork element if only one is a Fork): when the Lattice is 
  # reconstructed, the other element is pointed back by the Lattice constructor.
  connections = Tuple{LineElement,LineElement}[]
  for br in lat.branches, bl in br.beamlines, ele in bl.line
    fp = ele.ForkParams
    (isnothing(fp) || isnothing(fp.fork_connect_element)) && continue
    target = fp.fork_connect_element
    tfp = target.ForkParams
    if !isnothing(tfp) && tfp.fork_connect_element === ele && 
          tfp.fork_orientation == fp.fork_orientation && 
          tfp.fork_propagate_reference == fp.fork_propagate_reference
      ele_is_fork = ele.kind == "Fork"
      target_is_fork = target.kind == "Fork"
      if ele_is_fork != target_is_fork
        ele_is_fork || continue
      else  # Write from the element that comes first in the Lattice
        bi, ii = _branch_and_index(ele)
        bt, it = _branch_and_index(target)
        (bi.lattice_index, ii) <= (bt.lattice_index, it) || continue
      end
    end
    push!(connections, (ele, target))
  end
  written = Base.IdSet{LineElement}(first.(connections))

  for (i, br) in enumerate(lat.branches)
    println(io, "b$i = Branch(Beamline[")
    for bl in br.beamlines
      _writebl(io, bl, " ", ele -> ele in written)
      println(io, ",")
    end
    println(io, "]; name=", repr(br.name), ")")
  end

  isempty(connections) || println(io)
  for (ele, target) in connections
    be, ie = _branch_and_index(ele)
    bt, it = _branch_and_index(target)
    println(io, "b$(be.lattice_index)[$ie].fork_connect_element = b$(bt.lattice_index)[$it]")
  end

  println(io)
  print(io, "lat = Lattice([", join(("b$i" for i in eachindex(lat.branches)), ", "), "]; name=", repr(lat.name), ")")
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
    print(io, String(ref_meaning), "=", param_repr(ref), ",")
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
# fork_connect_element is a reference to another element, so it is written separately by
# `writebl(::IO, ::Lattice)`.
function writeparam(io::IO, a::ForkParams)
  print(io, "fork_orientation=", param_repr(a.fork_orientation), ",")
  print(io, "fork_propagate_reference=", param_repr(a.fork_propagate_reference), ",")
  return
end
