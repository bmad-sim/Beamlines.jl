# Test 7: What about unary operators?
neg_a = -5
f_unary = () -> -neg_a
println("\nTest 7 - Unary operator:")
println(expand_closure(f_unary))

# Test 8: Comparisons
cmp_a = 10
cmp_b = 20
f_cmp = () -> cmp_a < cmp_b
println("\nTest 8 - Comparison:")
println(expand_closure(f_cmp))

# Test 9: Multiple operations in sequence
seq_a = 1
seq_b = 2
seq_c = 3
f_seq = () -> seq_a + seq_b + seq_c
println("\nTest 9 - Chained operations:")
println(expand_closure(f_seq))

# Test 10: What if we mix literals?
lit_a = 5
f_lit = () -> lit_a + 100
println("\nTest 10 - With literals:")
println(expand_closure(f_lit))