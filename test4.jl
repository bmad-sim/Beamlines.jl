# Test with array indexing
arr = [1, 2, 3]
f_arr = () -> arr[1] + arr[2]
println("Array indexing: ", expand_closure(f_arr))

# Test with structs
struct MyStruct
    a::Int
    b::Int
end

obj = MyStruct(10, 20)
f_prop = () -> obj.a + obj.b
println("Property access: ", expand_closure(f_prop))

# Combined test
nested_arr = () -> arr[1]
combined = () -> nested_arr() + obj.a
println("Combined: ", expand_closure(combined))