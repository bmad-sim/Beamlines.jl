module BeamlinesPythonCallExt
using PythonCall
using Beamlines: LineElement, Beamline, Context
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
# A `DefExpr` wraps a lambda that is either 0-argument or accepts a `Context`.
# The generic `DefExpr(f)` constructor decides between these by inspecting
# `applicable(f)`, which cannot distinguish them for a `Py`: juliacall makes
# every `Py` callable with any number of arguments, so `applicable(f)` is always
# true and the 0-argument branch is always taken. Here we inspect the Python
# signature instead, so both
#
#     DefExpr(lambda: a)        # 0-argument
#     DefExpr(lambda c: c.k1)   # Context-accepting
#
# build the correct expression, closing over the real `Context` at evaluation
# time. A plain Python value (e.g. `DefExpr(0.36)`) is also accepted.

_pycallable(f::Py) = pytruth(pybuiltins.callable(f))

# Number of required positional parameters of a Python callable (0 or >=1).
function _py_positional_arity(f::Py)
  inspect = pyimport("inspect")
  local sig
  try
    sig = inspect.signature(f)
  catch
    return 1  # cannot introspect (e.g. some builtins); assume it takes a Context
  end
  Parameter = inspect.Parameter
  n = 0
  for p in sig.parameters.values()
    kind = p.kind
    if pyeq(Bool, kind, Parameter.VAR_POSITIONAL)
      return 1  # *args can absorb the Context
    end
    is_positional = pyeq(Bool, kind, Parameter.POSITIONAL_ONLY) ||
                    pyeq(Bool, kind, Parameter.POSITIONAL_OR_KEYWORD)
    has_default = !pyeq(Bool, p.default, Parameter.empty)
    if is_positional && !has_default
      n += 1
    end
  end
  return n
end

function DefExpr{T}(f::Py) where {T}
  if _pycallable(f)
    if _py_positional_arity(f) == 0
      return DefExpr{T}(() -> pyconvert(T, f()))
    else
      return DefExpr{T}((c::Context) -> pyconvert(T, f(c)))
    end
  else
    return DefExpr{T}(pyconvert(T, f))  # a plain Python value
  end
end

# Untyped convenience: Python numeric parameters are Float64 by default.
DefExpr(f::Py) = DefExpr{Float64}(f)

end
