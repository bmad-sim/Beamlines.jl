struct DefExpr <: Number
  f::Function
end
(d::DefExpr)() = d.f()

DefExpr(a::Number) = DefExpr(()->a)

Base.:+(da::DefExpr, b::Number)   = DefExpr(()-> da() + b   )
Base.:+(a::Number,   db::DefExpr) = DefExpr(()-> a    + db())
Base.:+(da::DefExpr, db::DefExpr) = DefExpr(()-> da() + db())

Base.:-(da::DefExpr, b::Number)   = DefExpr(()-> da() - b   )
Base.:-(a::Number,   db::DefExpr) = DefExpr(()-> a    - db())
Base.:-(da::DefExpr, db::DefExpr) = DefExpr(()-> da() - db())

Base.:*(da::DefExpr, b::Number)   = DefExpr(()-> da() * b   )
Base.:*(a::Number,   db::DefExpr) = DefExpr(()-> a    * db())
Base.:*(da::DefExpr, db::DefExpr) = DefExpr(()-> da() * db())

Base.:/(da::DefExpr, b::Number)   = DefExpr(()-> da() / b   )
Base.:/(a::Number,   db::DefExpr) = DefExpr(()-> a    / db())
Base.:/(da::DefExpr, db::DefExpr) = DefExpr(()-> da() / db())

Base.:^(da::DefExpr, b::Number)   = DefExpr(()-> da() ^ b   )
Base.:^(a::Number,   db::DefExpr) = DefExpr(()-> a    ^ db())
Base.:^(da::DefExpr, db::DefExpr) = DefExpr(()-> da() ^ db())

for t = (:sqrt, :exp, :log, :sin, :cos, :tan, :cot, :sinh, :cosh, :tanh, :inv,
  :coth, :asin, :acos, :atan, :acot, :asinh, :acosh, :atanh, :acoth, :sinc, :csc, 
  :csch, :acsc, :acsch, :sec, :sech, :asec, :asech, :conj, :log10)
@eval begin
Base.$t(d::DefExpr) = DefExpr(()-> ($t)(d()))
end
end

for t = (:unit, :sincu, :sinhc, :sinhcu, :asinc, :asincu, :asinhc, :asinhcu, :erf, 
         :erfc, :erfcx, :erfi, :wf, :rect)
@eval begin
GTPSA.$t(d::DefExpr) = DefExpr(()-> ($t)(d()))
end
end

Base.promote_rule(::Type{DefExpr}, ::Type{T}) where {T<:Real} = DefExpr
Base.promote_rule(::Type{DefExpr}, ::Type{T}) where {T<:Number} = DefExpr
Base.promote_rule(::Type{T}, ::Type{DefExpr}) where {T<:AbstractIrrational} = DefExpr
Base.promote_rule(::Type{T}, ::Type{DefExpr}) where {T<:Rational} = DefExpr

Base.broadcastable(o::DefExpr) = Ref(o)