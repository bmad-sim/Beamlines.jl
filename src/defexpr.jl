struct DefExpr{T}
  f::FunctionWrapper{T,Tuple{}}
  DefExpr{T}(f::FunctionWrapper{T,Tuple{}}) where {T} = new{T}(f)
end

# In Julia we don't need to do any conversion, just static asserts
defconvert(::Type{T}, f) where {T} = f::T

# Calling DefExpr
(d::DefExpr{T})() where {T} = defconvert(T, d.f())

# Construct for Function -> DefExpr{FunctionWrapper}
function DefExpr{T}(f) where {T}
  return DefExpr{T}(FunctionWrapper{T,Tuple{}}(f))
end

# Conversion of types to DefExpr
DefExpr{T}(a::Number) where {T} = DefExpr{T}(()->convert(T,a))
DefExpr{T}(a::DefExpr) where {T} = DefExpr{T}(()->convert(T,a()))

# Make these apply via convert
Base.convert(::Type{D}, a) where {D<:DefExpr} = D(a)

# Now simple constructor for convenience
function DefExpr(f)
  T = Base.promote_op(f)
  return DefExpr{T}(f)
end

deval(d::DefExpr) = d()
deval(d) = d

Base.:+(da::DefExpr, b)   = DefExpr(()-> da() + b   )
Base.:+(a,   db::DefExpr) = DefExpr(()-> a    + db())
Base.:+(da::DefExpr, db::DefExpr) = DefExpr(()-> da() + db())

Base.:-(da::DefExpr, b)   = DefExpr(()-> da() - b   )
Base.:-(a,   db::DefExpr) = DefExpr(()-> a    - db())
Base.:-(da::DefExpr, db::DefExpr) = DefExpr(()-> da() - db())

Base.:*(da::DefExpr, b)   = DefExpr(()-> da() * b   )
Base.:*(a,   db::DefExpr) = DefExpr(()-> a    * db())
Base.:*(da::DefExpr, db::DefExpr) = DefExpr(()-> da() * db())

Base.:/(da::DefExpr, b)   = DefExpr(()-> da() / b   )
Base.:/(a,   db::DefExpr) = DefExpr(()-> a    / db())
Base.:/(da::DefExpr, db::DefExpr) = DefExpr(()-> da() / db())

Base.:^(da::DefExpr, b)   = DefExpr(()-> da() ^ b   )
Base.:^(a,   db::DefExpr) = DefExpr(()-> a    ^ db())
Base.:^(da::DefExpr, db::DefExpr) = DefExpr(()-> da() ^ db())

for t = (:sqrt, :exp, :log, :sin, :cos, :tan, :cot, :sinh, :cosh, :tanh, :inv,
  :coth, :asin, :acos, :atan, :acot, :asinh, :acosh, :atanh, :acoth, :sinc, :csc, 
  :csch, :acsc, :acsch, :sec, :sech, :asec, :asech, :conj, :log10, :isnan)
@eval begin
Base.$t(d::DefExpr) = DefExpr(()-> ($t)(d()))
end
end

Base.promote_rule(::Type{DefExpr{T}}, ::Type{U}) where {T,U<:Number} = DefExpr{promote_type(T,U)}
Base.promote_rule(::Type{DefExpr{T}}, ::Type{DefExpr{U}}) where {T,U<:Number} = DefExpr{promote_type(T,U)}

Base.broadcastable(o::DefExpr) = Ref(o)






# ======== SHOW DefExpr
#=
# This below was written by Claude (AI) and is experimental
using InteractiveUtils

#=
Version-agnostic closure expansion for Julia IR.
Uses semantic pattern matching instead of assuming specific IR structures.
=#

# ============================================================================
# Main Entry Point
# ============================================================================

function expand_closure(f)
    ci = @code_lowered f()
    ssa_map = build_ssa_map(ci)
    return_val = find_return_value(ci)
    expr = reconstruct_expr(return_val, ssa_map, f)
    return simplify_expr(expr)  # Final cleanup pass
end

# ============================================================================
# IR Analysis Helpers
# ============================================================================

function build_ssa_map(ci::Core.CodeInfo)
    ssa_map = Dict{Any, Any}()
    for (i, stmt) in enumerate(ci.code)
        if !(stmt isa Core.ReturnNode)
            ssa_map[Core.SSAValue(i)] = stmt
        end
    end
    return ssa_map
end

function find_return_value(ci::Core.CodeInfo)
    for stmt in ci.code
        if stmt isa Core.ReturnNode && isdefined(stmt, :val)
            return stmt.val
        end
    end
    return ci.code[end]
end

# ============================================================================
# Expression Reconstruction
# ============================================================================

function reconstruct_expr(val, ssa_map, parent_func)
    # Resolve SSA values first
    val = resolve_ssa(val, ssa_map, parent_func)
    
    # Dispatch based on value type
    if val isa GlobalRef
        return handle_globalref(val)
    elseif val isa Expr
        return handle_expr(val, ssa_map, parent_func)
    elseif val isa QuoteNode
        return val.value
    elseif is_slot(val)
        return handle_slot(val, parent_func)
    else
        # Numbers, symbols, and other literals pass through
        return val
    end
end

function resolve_ssa(val, ssa_map, parent_func)
    # Recursively resolve SSA values
    while val isa Core.SSAValue
        val = get(ssa_map, val, val)
        if val isa Core.SSAValue
            break  # Prevent infinite loops
        end
    end
    
    # After resolving, might need to reconstruct if it's an expression
    if val isa Expr || val isa GlobalRef
        return val
    elseif val isa Core.SSAValue
        return val  # Couldn't resolve further
    else
        return val
    end
end

function is_slot(val)
    return val isa Core.SlotNumber || val isa Core.Argument
end

function handle_slot(val, parent_func)
    # Slots typically refer to function arguments or local variables
    # In our case, they usually mean #self# (the closure object)
    return :_self_
end

# ============================================================================
# GlobalRef Handling
# ============================================================================

function handle_globalref(gref::GlobalRef)
    # Main module - always show bare symbol
    if gref.mod === Main
        return gref.name
    end
    
    # Standard library functions - show without module prefix
    if is_stdlib_symbol(gref.name)
        return gref.name
    end
    
    # User-defined symbols from other modules - show with prefix
    mod_name = nameof(gref.mod)
    return Expr(:., mod_name, QuoteNode(gref.name))
end

function is_stdlib_symbol(sym::Symbol)
    # Common operators and functions that don't need module prefix
    stdlib_symbols = Set([
        # Arithmetic
        :+, :-, :*, :/, :^, ://, :÷, :%, :\,
        # Comparison
        :<, :>, :<=, :>=, :(==), :≠, :!=, :(===), :(!==),
        # Logical
        :!, :&, :|, :⊻, :&&, :||,
        # Math functions
        :sin, :cos, :tan, :asin, :acos, :atan, :atan2,
        :sinh, :cosh, :tanh, :asinh, :acosh, :atanh,
        :sqrt, :cbrt, :exp, :exp2, :exp10, :expm1,
        :log, :log2, :log10, :log1p,
        :abs, :abs2, :sign, :signbit,
        :ceil, :floor, :round, :trunc,
        :min, :max, :clamp,
        :inv, :conj, :real, :imag, :angle,
        # Special functions
        :sinc, :cosc,
        :sec, :csc, :cot, :asec, :acsc, :acot,
        :sech, :csch, :coth, :asech, :acsch, :acoth,
        # Indexing/property access
        :getindex, :setindex!, :getproperty, :setproperty!,
        :getfield, :setfield!,
        # Array construction
        :vect, :hcat, :vcat, :hvcat,
        # Type operations
        :convert, :promote, :eltype, :typeof,
        # Internal operations
        :literal_pow, :apply_type,
        # Utility
        :isnan, :isinf, :isfinite, :iszero, :isone
    ])
    
    return sym in stdlib_symbols
end

# ============================================================================
# Expression Handling
# ============================================================================

function handle_expr(expr::Expr, ssa_map, parent_func)
    if expr.head == :call
        return handle_call(expr, ssa_map, parent_func)
    elseif expr.head == :static_parameter
        # Type parameters - use placeholder
        return :_T_
    elseif expr.head == :new
        # Constructor calls
        return handle_new(expr, ssa_map, parent_func)
    else
        # Generic expression - reconstruct all arguments
        return Expr(expr.head, [reconstruct_expr(arg, ssa_map, parent_func) for arg in expr.args]...)
    end
end

function handle_new(expr::Expr, ssa_map, parent_func)
    # :new expressions are constructor calls
    # Reconstruct all arguments
    return Expr(expr.head, [reconstruct_expr(arg, ssa_map, parent_func) for arg in expr.args]...)
end

# ============================================================================
# Call Expression Handling
# ============================================================================

function handle_call(expr::Expr, ssa_map, parent_func)
    @assert expr.head == :call
    
    func_ref = expr.args[1]
    
    # Special case: zero-argument call
    if length(expr.args) == 1
        result = handle_zero_arg_call(func_ref, ssa_map, parent_func)
        if !isnothing(result)
            return result
        end
    end
    
    # Try function-specific handlers
    if func_ref isa GlobalRef
        result = try_special_handler(func_ref.name, expr, ssa_map, parent_func)
        if !isnothing(result)
            return result
        end
        
        # Try to expand nested closures
        result = try_expand_nested_closure(func_ref, expr)
        if !isnothing(result)
            return result
        end
    end
    
    # Default: reconstruct all arguments
    reconstructed_args = [reconstruct_expr(arg, ssa_map, parent_func) for arg in expr.args]
    return Expr(:call, reconstructed_args...)
end

function handle_zero_arg_call(func_ref, ssa_map, parent_func)
    # Reconstruct what we're calling
    func_obj = reconstruct_expr(func_ref, ssa_map, parent_func)
    
    # If it's a DefExpr, expand it recursively
    if isdefined(Main, :DefExpr) && func_obj isa Main.DefExpr
        return expand_closure(func_obj.f.obj[])
    end
    
    # If it's already a value (not a callable reference), return it
    if !(func_obj isa GlobalRef) && !(func_obj isa Symbol) && !(func_obj isa Expr)
        return func_obj
    end
    
    return nothing
end

function try_expand_nested_closure(func_ref::GlobalRef, expr)
    try
        actual_func = getfield(func_ref.mod, func_ref.name)
        if applicable(actual_func) && length(expr.args) == 1
            return expand_closure(actual_func)
        end
    catch
    end
    return nothing
end

# ============================================================================
# Special Function Handlers
# ============================================================================

function try_special_handler(name::Symbol, expr::Expr, ssa_map, parent_func)
    # Dispatch to specialized handlers for known patterns
    if name == :literal_pow
        return handle_literal_pow(expr, ssa_map, parent_func)
    elseif name == :getindex
        return handle_getindex(expr, ssa_map, parent_func)
    elseif name == :getproperty
        return handle_getproperty(expr, ssa_map, parent_func)
    elseif name == :getfield
        return handle_getfield(expr, ssa_map, parent_func)
    elseif name == :convert
        return handle_convert(expr, ssa_map, parent_func)
    elseif name == :vect
        return handle_vect(expr, ssa_map, parent_func)
    elseif name == :apply_type
        return handle_apply_type(expr, ssa_map, parent_func)
    end
    
    return nothing
end

function handle_literal_pow(expr, ssa_map, parent_func)
    # literal_pow(^, base, Val{N}()) -> base ^ N
    if length(expr.args) >= 4
        base = reconstruct_expr(expr.args[3], ssa_map, parent_func)
        exp_val = extract_exponent(expr.args[4], ssa_map)
        return Expr(:call, :^, base, exp_val)
    end
    return nothing
end

function extract_exponent(exp_arg, ssa_map)
    # Try to extract the exponent from Val{N}() pattern
    # This works across different IR versions by pattern matching
    
    if exp_arg isa Core.SSAValue
        val_expr = get(ssa_map, exp_arg, exp_arg)
        
        # Pattern: (%N)() where %N is apply_type(Val, exp)
        if val_expr isa Expr && val_expr.head == :call && length(val_expr.args) >= 1
            type_ref = val_expr.args[1]
            
            if type_ref isa Core.SSAValue
                apply_expr = get(ssa_map, type_ref, type_ref)
                
                # Pattern: apply_type(Val, N)
                if apply_expr isa Expr && apply_expr.head == :call && length(apply_expr.args) >= 3
                    func = apply_expr.args[1]
                    if (func isa GlobalRef && func.name == :apply_type) || func == :apply_type
                        return apply_expr.args[3]  # The exponent
                    end
                end
            end
        end
    end
    
    # Fallback: return as-is
    return exp_arg
end

function handle_getindex(expr, ssa_map, parent_func)
    # getindex(arr, i, j, ...) -> arr[i, j, ...]
    if length(expr.args) >= 2
        arr = reconstruct_expr(expr.args[2], ssa_map, parent_func)
        indices = [reconstruct_expr(arg, ssa_map, parent_func) for arg in expr.args[3:end]]
        return Expr(:ref, arr, indices...)
    end
    return nothing
end

function handle_getproperty(expr, ssa_map, parent_func)
    # getproperty(obj, :field) -> obj.field
    if length(expr.args) == 3
        obj = reconstruct_expr(expr.args[2], ssa_map, parent_func)
        field = expr.args[3]
        
        field_sym = if field isa QuoteNode
            field.value
        else
            reconstructed_field = reconstruct_expr(field, ssa_map, parent_func)
            reconstructed_field isa Symbol ? reconstructed_field : reconstructed_field
        end
        
        return Expr(:., obj, QuoteNode(field_sym))
    end
    return nothing
end

function handle_getfield(expr, ssa_map, parent_func)
    # getfield(#self#, :field) - extract captured variables from closure
    if length(expr.args) == 3
        obj = expr.args[2]
        field = expr.args[3]
        
        # Pattern: getfield(#self#, :field_name)
        if is_slot(obj) && field isa QuoteNode
            try
                # Extract the actual captured value from the closure
                return getfield(parent_func, field.value)
            catch
                # Fallback if extraction fails
                return Expr(:., :_closure_, QuoteNode(field.value))
            end
        end
    end
    return nothing
end

function handle_convert(expr, ssa_map, parent_func)
    # convert(T, x) - often noise, especially for constants
    if length(expr.args) == 3
        type_arg = reconstruct_expr(expr.args[2], ssa_map, parent_func)
        value_arg = reconstruct_expr(expr.args[3], ssa_map, parent_func)
        
        # If value is a literal, just return it (the type is obvious from the literal)
        if value_arg isa Number
            return value_arg
        end
        
        # If type is a placeholder/unknown and value is simple, skip conversion
        if (type_arg == :_T_ || type_arg == :Any) && (value_arg isa Number || value_arg isa Symbol)
            return value_arg
        end
        
        # Otherwise preserve the convert call
        return Expr(:call, :convert, type_arg, value_arg)
    end
    return nothing
end

function handle_vect(expr, ssa_map, parent_func)
    # vect(a, b, c) -> [a, b, c]
    elements = [reconstruct_expr(arg, ssa_map, parent_func) for arg in expr.args[2:end]]
    return Expr(:vect, elements...)
end

function handle_apply_type(expr, ssa_map, parent_func)
    # apply_type(Type, params...) - usually can be simplified
    # For display purposes, we often don't need the full parametric type
    if length(expr.args) >= 2
        base_type = reconstruct_expr(expr.args[2], ssa_map, parent_func)
        
        # For simple cases, just return the base type
        # Full type info: Expr(:curly, base_type, params...)
        return base_type
    end
    return nothing
end

# ============================================================================
# Post-processing Simplification
# ============================================================================

function simplify_expr(expr)
    # Final cleanup pass to remove obvious noise
    
    if expr isa Expr
        if expr.head == :call && length(expr.args) >= 2
            func = expr.args[1]
            
            # Simplify convert(T, literal) -> literal
            if func == :convert && length(expr.args) == 3 && expr.args[3] isa Number
                return expr.args[3]
            end
            
            # Recursively simplify arguments
            simplified_args = [simplify_expr(arg) for arg in expr.args]
            return Expr(expr.head, simplified_args...)
        elseif expr.head == :. && length(expr.args) == 2
            # Simplify property access
            obj = simplify_expr(expr.args[1])
            field = expr.args[2]
            return Expr(:., obj, field)
        else
            # Recursively simplify other expressions
            simplified_args = [simplify_expr(arg) for arg in expr.args]
            return Expr(expr.head, simplified_args...)
        end
    end
    
    return expr
end

# ============================================================================
# Display Integration
# ============================================================================

function Base.show(io::IO, d::DefExpr)
    result = expand_closure(d.f.obj[])
    
    # Special formatting for different types
    if result isa Float32
        print(io, repr(result))
    elseif result isa Number
        print(io, repr(result))
    else
        print(io, result)
    end
end

#=
 function Base.show(io::IO, d::DefExpr)
  #print(io, "DefExpr: ")
  res = expand_closure(d.f.obj[])
  if res isa Number
    print(io, repr(res))
  else
    print(io, res)
  end
end

# Main entry point
function expand_closure(f)
    ci = @code_lowered f()
    ssa_map = build_ssa_map(ci)
    
    # Find the return value
    return_val = find_return_value(ci)
    return reconstruct_expr(return_val, ssa_map, f)
end

# Build a map of SSA values to their definitions
function build_ssa_map(ci::Core.CodeInfo)
    ssa_map = Dict{Any, Any}()
    for (i, stmt) in enumerate(ci.code)
        if !(stmt isa Core.ReturnNode)
            ssa_map[Core.SSAValue(i)] = stmt
        end
    end
    return ssa_map
end

# Find what the function returns
function find_return_value(ci::Core.CodeInfo)
    for stmt in ci.code
        if stmt isa Core.ReturnNode
            return stmt.val
        end
    end
    # If no explicit return, last statement is returned
    return ci.code[end]
end

# Main reconstruction logic
function reconstruct_expr(val, ssa_map, parent_func)
    # Base cases
    val = resolve_ssa(val, ssa_map, parent_func)
    
    # Handle different value types
    if val isa GlobalRef
        return handle_globalref(val)
    elseif val isa Expr
        return handle_expr(val, ssa_map, parent_func)
    elseif val isa Number || val isa Symbol || val isa QuoteNode
        return val
    elseif val isa Core.SlotNumber || val isa Core.Argument
        return :_self_
    else
        return val
    end
end

# Resolve SSA values recursively
function resolve_ssa(val, ssa_map, parent_func)
    if val isa Core.SSAValue
        resolved = ssa_map[val]
        return reconstruct_expr(resolved, ssa_map, parent_func)
    end
    return val
end

# Handle GlobalRef - decide whether to show module prefix
function handle_globalref(gref::GlobalRef)
    # Always show bare symbol for Main
    if gref.mod === Main
        return gref.name
    end
    
    # Common functions/operators - show without module
    common_symbols = Set([
        :+, :-, :*, :/, :^, :<, :>, :<=, :>=, :(==), :≠,
        :sin, :cos, :tan, :asin, :acos, :atan,
        :sinh, :cosh, :tanh, :asinh, :acosh, :atanh,
        :sqrt, :exp, :log, :log10, :abs, :inv,
        :getindex, :getproperty, :setindex!, :setproperty!,
        :convert, :literal_pow, :vect
    ])
    
    if gref.name in common_symbols
        return gref.name
    end
    
    # User symbols from other modules - show with module prefix
    mod_name = nameof(gref.mod)
    return Expr(:., mod_name, QuoteNode(gref.name))
end

# Handle all expression types
function handle_expr(expr::Expr, ssa_map, parent_func)
    if expr.head == :call
        return handle_call_expr(expr, ssa_map, parent_func)
    elseif expr.head == :static_parameter
        return :_T_  # Type parameter placeholder
    else
        # Generic expression reconstruction
        return Expr(expr.head, [reconstruct_expr(arg, ssa_map, parent_func) for arg in expr.args]...)
    end
end
#=
# Handle call expressions with special cases
function handle_call_expr(expr::Expr, ssa_map, parent_func)
    func_ref = expr.args[1]
    
    # Dispatch to specific handlers based on function name
    if func_ref isa GlobalRef
        handler = get_call_handler(func_ref.name)
        if !isnothing(handler)
            result = handler(expr, ssa_map, parent_func)
            if !isnothing(result)
                return result
            end
        end
        
        # Try to expand nested closures
        try
            actual_func = getfield(func_ref.mod, func_ref.name)
            if applicable(actual_func) && length(expr.args) == 1
                return expand_closure(actual_func)
            end
        catch
        end
    end
    
    # Default: reconstruct all arguments
    reconstructed_args = [reconstruct_expr(arg, ssa_map, parent_func) for arg in expr.args]
    return Expr(:call, reconstructed_args...)
end
=#

# Handle call expressions with special cases
function handle_call_expr(expr::Expr, ssa_map, parent_func)
    func_ref = expr.args[1]
    
    # Check if we're calling a DefExpr (zero-arg call to something that resolved to a DefExpr)
    if length(expr.args) == 1  # Zero-arg call
        # Reconstruct what we're calling
        func_obj = reconstruct_expr(func_ref, ssa_map, parent_func)
        
        # If it's a DefExpr, expand it recursively
        if func_obj isa DefExpr
            return expand_closure(func_obj.f.obj[])
        end
        
        # If it's already a reconstructed expression, return it
        if !(func_obj isa GlobalRef) && !(func_obj isa Symbol)
            return func_obj
        end
    end
    
    # Dispatch to specific handlers based on function name
    if func_ref isa GlobalRef
        handler = get_call_handler(func_ref.name)
        if !isnothing(handler)
            result = handler(expr, ssa_map, parent_func)
            if !isnothing(result)
                return result
            end
        end
        
        # Try to expand nested closures
        try
            actual_func = getfield(func_ref.mod, func_ref.name)
            if applicable(actual_func) && length(expr.args) == 1
                return expand_closure(actual_func)
            end
        catch
        end
    end
    
    # Default: reconstruct all arguments
    reconstructed_args = [reconstruct_expr(arg, ssa_map, parent_func) for arg in expr.args]
    return Expr(:call, reconstructed_args...)
end

# Dispatch table for special call handlers
function get_call_handler(name::Symbol)
    handlers = Dict(
        :literal_pow => handle_literal_pow,
        :getindex => handle_getindex,
        :getproperty => handle_getproperty,
        :getfield => handle_getfield,
        :convert => handle_convert,
        :vect => handle_vect 
    )
    return get(handlers, name, nothing)
end

function handle_vect(expr, ssa_map, parent_func)
    # vect(1, 2, 3) -> [1, 2, 3]
    elements = [reconstruct_expr(arg, ssa_map, parent_func) for arg in expr.args[2:end]]
    return Expr(:vect, elements...)
end

# Specialized handlers for specific functions
function handle_literal_pow(expr, ssa_map, parent_func)
    base = reconstruct_expr(expr.args[3], ssa_map, parent_func)
    exp_val = extract_literal_pow_exponent(expr.args[4], ssa_map)
    return Expr(:call, :^, base, exp_val)
end

function handle_getindex(expr, ssa_map, parent_func)
    arr = reconstruct_expr(expr.args[2], ssa_map, parent_func)
    indices = [reconstruct_expr(arg, ssa_map, parent_func) for arg in expr.args[3:end]]
    return Expr(:ref, arr, indices...)
end

function handle_getproperty(expr, ssa_map, parent_func)
    obj = reconstruct_expr(expr.args[2], ssa_map, parent_func)
    field = expr.args[3]
    if field isa QuoteNode
        return Expr(:., obj, QuoteNode(field.value))
    else
        field_reconstructed = reconstruct_expr(field, ssa_map, parent_func)
        return Expr(:., obj, QuoteNode(field_reconstructed))
    end
end

function handle_getfield(expr, ssa_map, parent_func)
    # Only handle Core.getfield(#self#, :field) pattern
    if length(expr.args) == 3
        obj = expr.args[2]
        field = expr.args[3]
        
        if (obj isa Core.SlotNumber || obj isa Core.Argument) && field isa QuoteNode
            # Extract captured variable from closure
            try
                return getfield(parent_func, field.value)
            catch
                return Expr(:., :_closure_, QuoteNode(field.value))
            end
        end
    end
    return nothing  # Fall back to default handling
end

function handle_convert(expr, ssa_map, parent_func)
    if length(expr.args) == 3
        type_arg = reconstruct_expr(expr.args[2], ssa_map, parent_func)
        value_arg = reconstruct_expr(expr.args[3], ssa_map, parent_func)
        
        # If converting a simple number, just return the number
        if value_arg isa Number
            return value_arg
        end
        
        # Otherwise keep the convert call
        return Expr(:call, :convert, type_arg, value_arg)
    end
    return nothing
end

# Helper for extracting exponent from literal_pow
function extract_literal_pow_exponent(exp_ssa, ssa_map)
    if exp_ssa isa Core.SSAValue
        val_call = ssa_map[exp_ssa]
        if val_call isa Expr && val_call.head == :call && length(val_call.args) >= 1
            val_type_ssa = val_call.args[1]
            
            if val_type_ssa isa Core.SSAValue
                apply_type_call = ssa_map[val_type_ssa]
                if apply_type_call isa Expr && apply_type_call.head == :call && length(apply_type_call.args) >= 3
                    return apply_type_call.args[3]
                end
            end
        end
    end
    return exp_ssa
end
=#
#=
 function expand_closure(f)
    ci = @code_lowered f()
    
    # Build a map of SSA values to expressions
    ssa_map = Dict{Any, Any}()
    
    for (i, stmt) in enumerate(ci.code)
        if stmt isa Core.ReturnNode
            # Follow the SSA value back
            return reconstruct_expr(stmt.val, ssa_map, f)
        else
            # Store this SSA value
            ssa_map[Core.SSAValue(i)] = stmt
        end
    end
    
    # If no explicit return, use the last statement
    return reconstruct_expr(ci.code[end], ssa_map, f)
end

function reconstruct_expr(val, ssa_map, parent_func)
    # If it's an SSA value, look it up
    if val isa Core.SSAValue
        return reconstruct_expr(ssa_map[val], ssa_map, parent_func)
    end
    
if val isa GlobalRef
    # If it's from Main, just return the symbol
    if val.mod === Main
        return val.name
    # If it's a standard operator, just return the symbol without module
    elseif val.name in [:+, :-, :*, :/, :^, :<, :>, :<=, :>=, :(==), :≠, 
                        :getindex, :getproperty, :setindex!, :setproperty!,
                        :sin, :cos, :tan, :sqrt, :exp, :log, :abs, # add more as needed
                        :convert, :literal_pow]
        return val.name
    else
        # Get the module name as a symbol (without the Main. prefix)
        mod_name = nameof(val.mod)
        # Return as an Expr that will display nicely
        return Expr(:., mod_name, QuoteNode(val.name))
    end
end
    
    # If it's a Slot (like #self#), try to handle it
    if val isa Core.SlotNumber || val isa Core.Argument
        # This is tricky - for now, return a placeholder
        # We might need to inspect parent_func to get the actual value
        return :_self_
    end
    
    # If it's an expression, recursively reconstruct
    if val isa Expr
        if val.head == :call
            func_ref = val.args[1]
            
            # Handle Core.getfield(#self#, :field) - extract captured variable
            if func_ref isa GlobalRef && func_ref.name == :getfield && 
               func_ref.mod === Core && length(val.args) == 3
                obj = val.args[2]
                field = val.args[3]
                
                # If it's getfield(#self#, :field), get the actual captured value
                if (obj isa Core.SlotNumber || obj isa Core.Argument) && field isa QuoteNode
                    # Get the field value from the closure
                    try
                        field_val = getfield(parent_func, field.value)
                        # If it's a simple value, return it directly
                        if field_val isa Number
                            return field_val
                        end
                        return field_val
                    catch
                        return Expr(:., :_closure_, QuoteNode(field.value))
                    end
                end
            end
            
            # Handle literal_pow specially
            if func_ref isa GlobalRef && func_ref.name == :literal_pow
                base = reconstruct_expr(val.args[3], ssa_map, parent_func)
                exp_ssa = val.args[4]
                exp_val = extract_literal_pow_exponent(exp_ssa, ssa_map)
                return Expr(:call, :^, base, exp_val)
            end
            
            # Handle getindex: arr[i] instead of getindex(arr, i)
            if func_ref isa GlobalRef && func_ref.name == :getindex
                arr = reconstruct_expr(val.args[2], ssa_map, parent_func)
                indices = [reconstruct_expr(arg, ssa_map, parent_func) for arg in val.args[3:end]]
                return Expr(:ref, arr, indices...)
            end
            
            # Handle getproperty: obj.field instead of getproperty(obj, :field)
            if func_ref isa GlobalRef && func_ref.name == :getproperty
                obj = reconstruct_expr(val.args[2], ssa_map, parent_func)
                field = val.args[3]
                if field isa QuoteNode
                    return Expr(:., obj, QuoteNode(field.value))
                else
                    field_reconstructed = reconstruct_expr(field, ssa_map, parent_func)
                    return Expr(:., obj, QuoteNode(field_reconstructed))
                end
            end
            
            # Handle convert specially - if converting a constant, just show the constant
            if func_ref isa GlobalRef && func_ref.name == :convert && length(val.args) == 3
                type_arg = reconstruct_expr(val.args[2], ssa_map, parent_func)
                value_arg = reconstruct_expr(val.args[3], ssa_map, parent_func)
                
                # If converting a simple number, just return the number
                if value_arg isa Number
                    return value_arg
                end
                
                # Otherwise keep the convert call
                return Expr(:call, :convert, type_arg, value_arg)
            end
            
            if func_ref isa GlobalRef
                try
                    actual_func = getfield(func_ref.mod, func_ref.name)
                    # If it's a zero-arg closure, try to expand it
                    if applicable(actual_func) && length(val.args) == 1
                        return expand_closure(actual_func)
                    end
                catch
                end
            end
            
            # Otherwise, reconstruct the call
            reconstructed_args = [reconstruct_expr(arg, ssa_map, parent_func) for arg in val.args]
            
            # If it's a simple binary op, format nicely
            binary_ops = Set([:+, :-, :*, :/, :^, :<, :>, :<=, :>=, :(==), :≠])
            if length(reconstructed_args) == 3 && reconstructed_args[1] in binary_ops
                return Expr(:call, reconstructed_args...)
            end
            
            return Expr(:call, reconstructed_args...)
        elseif val.head == :static_parameter
            # This is a type parameter - skip it for display purposes
            return :_T_
        else
            # Reconstruct other expression types
            return Expr(val.head, [reconstruct_expr(arg, ssa_map, parent_func) for arg in val.args]...)
        end
    end
    
    return val
end
#=
 #=
function expand_closure(f)
    ci = @code_lowered f()
    
    # Build a map of SSA values to expressions
    ssa_map = Dict{Any, Any}()
    
    for (i, stmt) in enumerate(ci.code)
        if stmt isa Core.ReturnNode
            # Follow the SSA value back
            return reconstruct_expr(stmt.val, ssa_map, f)
        else
            # Store this SSA value
            ssa_map[Core.SSAValue(i)] = stmt
        end
    end
    
    # If no explicit return, use the last statement
    return reconstruct_expr(ci.code[end], ssa_map, f)
end
=#

function expand_closure(f)
    ci = @code_lowered f()
    
    # Check if this is just a simple constant return
    if length(ci.code) == 1 || (length(ci.code) == 2 && ci.code[2] isa Core.ReturnNode)
        stmt = ci.code[1]
        if stmt isa Core.ReturnNode
            stmt = stmt.val
        end
        # If it's a simple value, just return it
        if !(stmt isa Expr) && !(stmt isa Core.SSAValue) && !(stmt isa GlobalRef)
            return stmt
        end
    end
    
    # Build a map of SSA values to expressions
    ssa_map = Dict{Any, Any}()
    
    for (i, stmt) in enumerate(ci.code)
        if stmt isa Core.ReturnNode
            # Follow the SSA value back
            return reconstruct_expr(stmt.val, ssa_map, f)
        else
            # Store this SSA value
            ssa_map[Core.SSAValue(i)] = stmt
        end
    end
    
    # If no explicit return, use the last statement
    return reconstruct_expr(ci.code[end], ssa_map, f)
end

function reconstruct_expr(val, ssa_map, parent_func)
    # If it's an SSA value, look it up
    if val isa Core.SSAValue
        return reconstruct_expr(ssa_map[val], ssa_map, parent_func)
    end
    
    # If it's a GlobalRef, return the symbol
    if val isa GlobalRef
        return val.name
    end
    
    # If it's an expression, recursively reconstruct
    if val isa Expr
        if val.head == :call
            # Check if first arg is a closure we can expand
            func_ref = val.args[1]
            
            # Handle literal_pow specially
            if func_ref isa GlobalRef && func_ref.name == :literal_pow
                # literal_pow(%1, base, %4) where %4 = (%3)() and %3 = apply_type(Val, exp)
                base = reconstruct_expr(val.args[3], ssa_map, parent_func)
                exp_ssa = val.args[4]
                
                # Trace back to find the exponent value
                exp_val = extract_literal_pow_exponent(exp_ssa, ssa_map)
                
                return Expr(:call, :^, base, exp_val)
            end
            
            # Handle getindex: arr[i] instead of getindex(arr, i)
            if func_ref isa GlobalRef && func_ref.name == :getindex
                arr = reconstruct_expr(val.args[2], ssa_map, parent_func)
                indices = [reconstruct_expr(arg, ssa_map, parent_func) for arg in val.args[3:end]]
                return Expr(:ref, arr, indices...)
            end
            
            # Handle getproperty: obj.field instead of getproperty(obj, :field)
            if func_ref isa GlobalRef && func_ref.name == :getproperty
                obj = reconstruct_expr(val.args[2], ssa_map, parent_func)
                # The field is usually a QuoteNode
                field = val.args[3]
                if field isa QuoteNode
                    return Expr(:., obj, QuoteNode(field.value))
                else
                    field_reconstructed = reconstruct_expr(field, ssa_map, parent_func)
                    return Expr(:., obj, QuoteNode(field_reconstructed))
                end
            end
            
            if func_ref isa GlobalRef
                try
                    actual_func = getfield(func_ref.mod, func_ref.name)
                    # If it's a zero-arg closure, try to expand it
                    if applicable(actual_func) && length(val.args) == 1
                        return expand_closure(actual_func)
                    end
                catch
                end
            end
            
            # Otherwise, reconstruct the call
            reconstructed_args = [reconstruct_expr(arg, ssa_map, parent_func) for arg in val.args]
            
            # If it's a simple binary op, format nicely
            binary_ops = Set([:+, :-, :*, :/, :^, :<, :>, :<=, :>=, :(==), :≠])
            if length(reconstructed_args) == 3 && reconstructed_args[1] in binary_ops
                return Expr(:call, reconstructed_args...)
            end
            
            return Expr(:call, reconstructed_args...)
        else
            # Reconstruct other expression types
            return Expr(val.head, [reconstruct_expr(arg, ssa_map, parent_func) for arg in val.args]...)
        end
    end
    
    return val
end

=#

function extract_literal_pow_exponent(exp_ssa, ssa_map)
    # exp_ssa is something like %4
    # Look it up: %4 = (%3)()
    if exp_ssa isa Core.SSAValue
        val_call = ssa_map[exp_ssa]
        if val_call isa Expr && val_call.head == :call
            # (%3)() - the first arg is %3
            val_type_ssa = val_call.args[1]
            
            # Look up %3: Core.apply_type(Base.Val, 2)
            if val_type_ssa isa Core.SSAValue
                apply_type_call = ssa_map[val_type_ssa]
                if apply_type_call isa Expr && apply_type_call.head == :call
                    # Core.apply_type(Base.Val, 2) - the exponent is args[3]
                    if length(apply_type_call.args) >= 3
                        return apply_type_call.args[3]
                    end
                end
            end
        end
    end
    
    # Fallback
    return exp_ssa
end
=#
=#