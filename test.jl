# Test 1: Triple nesting
a = 1
b = 2
c = 3
d = 4
f1 = () -> a + b
f2 = () -> f1() * c
f3 = () -> f2() - d

println("Test 1 - Triple nesting:")
println(expand_closure(f3))

# Test 2: Multiple closure calls in one expression
x = 5
y = 6
z = 7
g1 = () -> x + y
g2 = () -> y + z
g3 = () -> g1() * g2()

println("\nTest 2 - Multiple closure calls:")
println(expand_closure(g3))

# Test 3: Custom functions mixed with closures
mysum(a, b) = a + b
myprod(a, b) = a * b

p = 10
q = 20
r = 30
h1 = () -> mysum(p, q)
h2 = () -> myprod(h1(), r)

println("\nTest 3 - Custom functions:")
println(expand_closure(h2))

# Test 4: Nested with different operators
m = 1
n = 2
o = 3
p_var = 4
k1 = () -> m / n
k2 = () -> o ^ 2
k3 = () -> k1() + k2() - p_var

println("\nTest 4 - Mixed operators:")
println(expand_closure(k3))

# Test 5: Deep nesting (5 levels)
v1 = 1
v2 = 2
v3 = 3
v4 = 4
v5 = 5
deep1 = () -> v1 + v2
deep2 = () -> deep1() + v3
deep3 = () -> deep2() * v4
deep4 = () -> deep3() - v5
deep5 = () -> deep4() / 2

println("\nTest 5 - Deep nesting (5 levels):")
println(expand_closure(deep5))

# Test 6: Closures that reference the same base closure multiple times
base = () -> a + b
combo = () -> base() + base()

println("\nTest 6 - Same closure called twice:")
println(expand_closure(combo))