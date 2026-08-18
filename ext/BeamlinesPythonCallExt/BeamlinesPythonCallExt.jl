module BeamlinesPythonCallExt
using PythonCall
using Beamlines: LineElement, Beamline, Context, NULL_CONTEXT
import Beamlines: defconvert, Branch, DefExpr

# Python objects are always converted to numbers
defconvert(::Type{T}, f::Py) where {T} = pyconvert(Number, f)
function Branch(lbl::PyList)
  lbl = collect(vec(lbl))
  if all(t->t isa LineElement, lbl)
    return Branch(convert(Vector{LineElement}, lbl))
  elseif all(t->t isa Beamline, lbl)
    return Branch(convert(Vector{Beamline}, lbl))
  else
    error("Branch array must only contain ONE of Either LineElement or Beamline types")
  end
end

# --- DefExpr construction from Python callables ------------------------------
#
# `DefExpr(f)` picks the 0-argument vs `Context`-accepting form using
# `applicable`, which cannot decide for a `Py`: juliacall makes every `Py`
# applicable at every arity, so whichever branch is tested first always wins and
# the other form fails at evaluation time. Dispatch on the Python signature
# instead, so all of
#
#     DefExpr(lambda: a)        # 0-argument
#     DefExpr(lambda c: c.k1)   # Context-accepting
#     DefExpr(0.36)             # plain value
#
# build the right expression, closing over the real `Context` at evaluation
# time. No value type is assumed: the result is a `DefExpr{Py}` whose Python
# return value is unwrapped by the `defconvert` method above when the expression
# is evaluated, so a callable returning e.g. a TPS stays a TPS. Use
# `DefExpr{T}(::Py)` to convert to a specific `T` instead.

_pyarity0(f::Py) = pylen(pyimport("inspect").signature(f).parameters) == 0

function DefExpr{T}(f::Py) where {T}
  pytruth(pybuiltins.callable(f)) || return DefExpr{T}((c=NULL_CONTEXT)->pyconvert(T, f))
  return _pyarity0(f) ? DefExpr{T}(()->pyconvert(T, f())) :
                        DefExpr{T}((c::Context)->pyconvert(T, f(c)))
end

function DefExpr(f::Py)
  pytruth(pybuiltins.callable(f)) || return DefExpr{Py}((c=NULL_CONTEXT)->f)
  return _pyarity0(f) ? DefExpr{Py}(()->f()) : DefExpr{Py}((c::Context)->f(c))
end

end
