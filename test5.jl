println("="^60)
println("EXTREME STRESS TEST SUITE")
println("="^60)

# Test 1: Deep nesting with mixed operations
println("\n[Test 1] Deep nesting (7 levels) with mixed ops:")
a, b, c, d, e, f, g = 1, 2, 3, 4, 5, 6, 7
l1 = () -> a + b
l2 = () -> l1() * c
l3 = () -> l2() - d
l4 = () -> l3() / e
l5 = () -> l4() ^ 2
l6 = () -> l5() + f
l7 = () -> l6() * g
println(expand_closure(l7))

# Test 2: Multiple closure calls with complex arithmetic
println("\n[Test 2] Multiple closure calls in one expression:")
x, y, z = 10, 20, 30
c1 = () -> x + y
c2 = () -> y * z
c3 = () -> x - z
mega = () -> (c1() * c2()) / (c3() + 1)
println(expand_closure(mega))

# Test 3: Array indexing madness
println("\n[Test 3] Nested array indexing:")
arr1 = [1, 2, 3, 4, 5]
arr2 = [10, 20, 30]
idx = 2
ai1 = () -> arr1[1] + arr2[2]
ai2 = () -> ai1() * arr1[idx]
ai3 = () -> ai2() - arr2[3]
println(expand_closure(ai3))

# Test 4: Struct property access with nesting
println("\n[Test 4] Nested struct property access:")
struct Point
    x::Float64
    y::Float64
end

struct Rectangle
    top_left::Point
    bottom_right::Point
end

p1 = Point(1.0, 2.0)
p2 = Point(5.0, 6.0)
rect = Rectangle(p1, p2)

sp1 = () -> rect.top_left.x + rect.top_left.y
sp2 = () -> rect.bottom_right.x - rect.bottom_right.y
sp3 = () -> sp1() * sp2()
println(expand_closure(sp3))

# Test 5: Math functions mixed with closures
println("\n[Test 5] Custom math functions with closures:")
double(x) = 2 * x
triple(x) = 3 * x
quadruple(x) = 4 * x

val1, val2 = 5, 7
m1 = () -> double(val1)
m2 = () -> triple(val2)
m3 = () -> m1() + m2()
m4 = () -> quadruple(m3())
println(expand_closure(m4))

# Test 6: Power operations chained
println("\n[Test 6] Chained power operations:")
base1, base2, base3 = 2, 3, 4
p1 = () -> base1 ^ 2
p2 = () -> base2 ^ 3
p3 = () -> base3 ^ 2
p4 = () -> p1() + p2() + p3()
println(expand_closure(p4))

# Test 7: Mixed array and struct access
println("\n[Test 7] Arrays + structs + closures:")
points = [Point(1.0, 2.0), Point(3.0, 4.0), Point(5.0, 6.0)]
mix1 = () -> points[1].x + points[2].y
mix2 = () -> points[3].x * points[1].y
mix3 = () -> mix1() - mix2()
println(expand_closure(mix3))

# Test 8: Same closure called multiple times in different contexts
println("\n[Test 8] Same closure reused multiple times:")
k = 100
reused = () -> k * 2
expr1 = () -> reused() + reused()
expr2 = () -> reused() * 3
expr3 = () -> expr1() - expr2()
println(expand_closure(expr3))

# Test 9: Complex parenthesization test
println("\n[Test 9] Complex nested parentheses:")
n1, n2, n3, n4 = 1, 2, 3, 4
paren1 = () -> (n1 + n2) * (n3 - n4)
paren2 = () -> (n1 * n2) + (n3 / n4)
paren3 = () -> paren1() ^ 2 - paren2() ^ 2
println(expand_closure(paren3))

# Test 10: Division chain
println("\n[Test 10] Division chain:")
d1, d2, d3, d4 = 1000, 10, 5, 2
div1 = () -> d1 / d2
div2 = () -> div1() / d3
div3 = () -> div2() / d4
println(expand_closure(div3))

# Test 11: Comparisons nested
println("\n[Test 11] Nested comparisons:")
comp_a, comp_b, comp_c = 10, 20, 15
cmp1 = () -> comp_a < comp_b
cmp2 = () -> comp_b > comp_c
# Note: these might get optimized to constants
println("cmp1: ", expand_closure(cmp1))
println("cmp2: ", expand_closure(cmp2))

# Test 12: Unary operators with nesting
println("\n[Test 12] Unary minus with nesting:")
un1, un2, un3 = 5, 10, 15
neg1 = () -> -un1
neg2 = () -> -un2
combined_neg = () -> neg1() + neg2() - un3
println(expand_closure(combined_neg))

# Test 13: Array with computed indices
println("\n[Test 13] Array indexing with expressions:")
data = [100, 200, 300, 400, 500]
i1, i2 = 1, 2
arr_expr1 = () -> data[i1] + data[i2]
arr_expr2 = () -> data[3] * 2
arr_expr3 = () -> arr_expr1() - arr_expr2()
println(expand_closure(arr_expr3))

# Test 14: Super deep nesting (10 levels!)
println("\n[Test 14] SUPER DEEP NESTING (10 levels):")
v = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
deep1 = () -> v[1] + v[2]
deep2 = () -> deep1() * v[3]
deep3 = () -> deep2() - v[4]
deep4 = () -> deep3() + v[5]
deep5 = () -> deep4() * v[6]
deep6 = () -> deep5() / v[7]
deep7 = () -> deep6() + v[8]
deep8 = () -> deep7() - v[9]
deep9 = () -> deep8() * v[10]
deep10 = () -> deep9() ^ 2
println(expand_closure(deep10))

# Test 15: Everything at once - the ultimate test
println("\n[Test 15] ULTIMATE COMBO TEST:")
struct Vector3D
    x::Float64
    y::Float64
    z::Float64
end

scale(v, s) = s
magnitude(x, y, z) = x + y + z

vec = Vector3D(1.0, 2.0, 3.0)
vectors = [Vector3D(1.0, 0.0, 0.0), Vector3D(0.0, 1.0, 0.0)]
scalars = [2.0, 3.0, 4.0]

ultimate1 = () -> vec.x + vec.y
ultimate2 = () -> vectors[1].x * scalars[1]
ultimate3 = () -> vectors[2].y ^ 2
ultimate4 = () -> ultimate1() + ultimate2()
ultimate5 = () -> ultimate4() - ultimate3()
ultimate6 = () -> scale(ultimate5(), scalars[3])
ultimate7 = () -> magnitude(ultimate6(), vec.z, scalars[2])
println(expand_closure(ultimate7))

println("\n" * "="^60)
println("STRESS TEST COMPLETE!")
println("="^60)

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