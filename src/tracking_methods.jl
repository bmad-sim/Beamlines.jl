
# ========== Symplectic ===========================
abstract type AbstractSymplectic end

# order and opt_scheme are also type parameters, and getproperty returns those, so that they
# are known to the compiler in tracking (e.g. the integrator chosen by order is type stable)
for name in (:DriftKick, :MatrixKick, :BendKick, :SolenoidKick)
@eval begin
  struct $name{O,S} <: AbstractSymplectic
    order::Int
    opt_scheme::Bool
    function $name(order, opt_scheme) 
      if !(order in (2, 4, 6, 8, 10))
        error("$($name) only supports orders 2, 4, 6, 8, and 10")
      end
      return new{Int(order),Bool(opt_scheme)}(order, opt_scheme)
    end
  end
  $name(; order=4, opt_scheme=true) = $name(order, opt_scheme)
  Base.getproperty(tm::$name{O,S}, key::Symbol) where {O,S} = key === :order ? O : key === :opt_scheme ? S : getfield(tm, key)
  Base.show(io::IO, tm::$name) = print(io, $(string(name)), "(order=", tm.order, ", opt_scheme=", tm.opt_scheme, ")")
end
end

PROPS(::Type{<:AbstractSymplectic}) = OrderedDict{String,String}(
  "order" => "Order of the integrator, supported are orders 2, 4, 6, 8, and 10. Default is 4",
  "opt_scheme" => "If `true`, uses an optimized integration scheme, else uses the standard Yoshida scheme. Default is `true`",
)


"""
    DriftKick(; order=4, opt_scheme=true)

Symplectic integrator using a drift-kick Hamiltonian split.

## Properties
$(PROPSDOC(DriftKick))
"""
DriftKick

"""
    MatrixKick(; order=4, opt_scheme=true)

Symplectic integrator using a matrix-kick Hamiltonian split.

## Properties
$(PROPSDOC(MatrixKick))
"""
MatrixKick

"""
    BendKick(; order=4, opt_scheme=true)

Symplectic integrator using a bend-kick Hamiltonian split.

## Properties
$(PROPSDOC(BendKick))
"""
BendKick

"""
    SolenoidKick(; order=4, opt_scheme=true)

Symplectic integrator using a solenoid-kick Hamiltonian split.

## Properties
$(PROPSDOC(SolenoidKick))
"""
SolenoidKick


"""
    Implicit(; order=4, opt_scheme=true, use_newton=false)

Implicit symplectic integrator for arbitrary electromagnetic potentials.

## Properties
$(PROPSDOC(Implicit))
- `use_newton`: If `true`, Newton's method is used to solve the implicit step, else fixed point iteration is used. Default is `false`
"""
struct Implicit{O,S,N} <: AbstractSymplectic
  order::Int
  opt_scheme::Bool
  use_newton::Bool
  function Implicit(order, opt_scheme, use_newton) 
    if !(order in (2, 4, 6, 8, 10))
      error("Implicit only supports orders 2, 4, 6, 8, and 10")
    end
    return new{Int(order),Bool(opt_scheme),Bool(use_newton)}(order, opt_scheme, use_newton)
  end
end
Implicit(; order=4, opt_scheme=true, use_newton=false) = Implicit(order, opt_scheme, use_newton)
Base.getproperty(tm::Implicit{O,S,N}, key::Symbol) where {O,S,N} = key === :order ? O : key === :opt_scheme ? S : key === :use_newton ? N : getfield(tm, key)
Base.show(io::IO, tm::Implicit) = print(io, "Implicit(order=", tm.order, ", opt_scheme=", tm.opt_scheme, ", use_newton=", tm.use_newton, ")")


# ========== Exact ===========================
# For patches, maps, markers, thin elements


"""
    Exact()

Tracking method specifying "exact" transformations, e.g. patches, custom maps, 
thin multipoles, etc.
"""
struct Exact end

# ========== SaganCavity =====================

"""
    SaganCavity(; n_cells = -1, L_active = -1.0)

Integrator for RF cavities using the Sagan Cavity model.

## Properties
- `n_cells`: Number cells in the cavity. If negative, then the approximate half wavelength between cells is used, and if zero then a single kick is applied. Default is `-1`
- `L_active`: Active length of the cavity. If negative, then the element length is used. Default is `-1`
"""
Base.@kwdef struct SaganCavity
  n_cells::Int      = -1    # Negative => Use approx half wavelength between cells, Zero => single kick.
  L_active::Float64 = -1.0  # Negative => Use L as the active length.
end
Base.show(io::IO, tm::SaganCavity) = print(io, "SaganCavity(n_cells=", tm.n_cells, ", L_active=", tm.L_active, ")")

# ========== Explicit RK4 Tracking ==========
"""
    RK4()

Fourth order Runge Kutta integrator, not symplectic.
"""
struct RK4 end