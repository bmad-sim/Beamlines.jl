module BeamlinesPythonCallExt
using PythonCall
import Beamlines: defconvert

# Python objects are always converted to numbers
defconvert(::Type{T}, f::Py) where {T} = pyconvert(Number, f)

end