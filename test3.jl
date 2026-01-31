# Test 11: What about array indexing?
arr = [1, 2, 3]
f_arr = () -> arr[1]
println("\nTest 11 - Array indexing:")
println(expand_closure(f_arr))

# Test 12: Nested with function calls AND closures
helper(x) = x * 2
val = 10
inner = () -> helper(val)
outer = () -> inner() + 5
println("\nTest 12 - Function call inside nested closure:")
println(expand_closure(outer))

# Test 13: Logical operators
bool_a = true
bool_b = false
f_and = () -> bool_a && bool_b
f_or = () -> bool_a || bool_b
println("\nTest 13 - Logical operators:")
println("AND: ", expand_closure(f_and))
println("OR: ", expand_closure(f_or))

# Test 14: Ternary operator
cond = true
yes_val = 1
no_val = 2
f_ternary = () -> cond ? yes_val : no_val
println("\nTest 14 - Ternary:")
println(expand_closure(f_ternary))
