module BeamlinesPythonCallExt
using PythonCall
using Beamlines: LineElement, Beamline
import Beamlines: defconvert, Lattice

# Python objects are always converted to numbers
defconvert(::Type{T}, f::Py) where {T} = pyconvert(Number, f)
function Lattice(lbl::PyList)
  lbl = collect(vec(lbl))
  if all(t->t isa LineElement, lbl)
    return Lattice(convert(Vector{LineElement}, lbl))
  elseif all(t->t isa Beamline, lbl)
    return Lattice(convert(Vector{Beamline}, lbl))
  else
    error("Lattice array must only contain ONE of Either LineElement or Beamline types")
  end
end

end