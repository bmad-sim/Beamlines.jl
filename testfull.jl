using Test
using InteractiveUtils

# Define test modules at top level
module TestModule
    K1 = 10.0
    K2 = 20.0
end

module AnotherModule
    other_var = 99
end

module Physics
    c = 3e8
end

module Constants
    pi_val = 3.14159
end

# Define test structs at top level
struct TestPoint
    x::Float64
    y::Float64
end

struct Vector2D
    x::Float64
    y::Float64
end

struct Line
    start::Vector2D
    stop::Vector2D
end

struct Item
    value::Int
end

struct Particle
    mass::Float64
    velocity::Float64
end

struct Config
    scale::Float64
end

# Assume DefExpr and expand_closure are already defined
# We'll create a comprehensive test suite

@testset "Closure Expansion Test Suite" begin
    
    # ========================================================================
    # Basic Operations
    # ========================================================================
    
    @testset "Basic Arithmetic" begin
        a, b, c = 1, 2, 3
        
        @test expand_closure(() -> a + b) == :(a + b)
        @test expand_closure(() -> a - b) == :(a - b)
        @test expand_closure(() -> a * b) == :(a * b)
        @test expand_closure(() -> a / b) == :(a / b)
        @test expand_closure(() -> a ^ b) == :(a ^ b)
        
        # Chained operations
        @test expand_closure(() -> a + b + c) == :(a + b + c)
        @test expand_closure(() -> a * b * c) == :(a * b * c)
        @test expand_closure(() -> a + b - c) == :(a + b - c)
        @test expand_closure(() -> a * b / c) == :(a * b / c)
    end
    
    @testset "Unary Operations" begin
        x = 5
        @test expand_closure(() -> -x) == :(-x)
        @test expand_closure(() -> +x) == :(+x)
    end
    
    @testset "Comparisons" begin
        x, y = 10, 20
        
        @test expand_closure(() -> x < y) == :(x < y)
        @test expand_closure(() -> x > y) == :(x > y)
        @test expand_closure(() -> x <= y) == :(x <= y)
        @test expand_closure(() -> x >= y) == :(x >= y)
        @test expand_closure(() -> x == y) == :(x == y)
    end
    
    @testset "Power Operations" begin
        base = 2
        
        @test expand_closure(() -> base ^ 2) == :(base ^ 2)
        @test expand_closure(() -> base ^ 3) == :(base ^ 3)
        @test expand_closure(() -> base ^ 10) == :(base ^ 10)
    end
    
    # ========================================================================
    # Constants and Literals
    # ========================================================================
    
    @testset "Literals" begin
        @test expand_closure(() -> 42) == 42
        @test expand_closure(() -> 3.14) == 3.14
        @test expand_closure(() -> 0.0f0) == 0.0f0
        
        x = 5
        @test expand_closure(() -> x + 10) == :(x + 10)
        @test expand_closure(() -> 100 - x) == :(100 - x)
    end
    
    @testset "Float32 Preservation" begin
        val32 = 1.5f0
        result = expand_closure(() -> val32)
        @test result isa Float32
        @test result == 1.5f0
    end
    
    # ========================================================================
    # Nested Closures
    # ========================================================================
    
    @testset "Simple Nesting" begin
        a, b, c = 1, 2, 3
        
        f1 = () -> a + b
        f2 = () -> f1() + c
        @test expand_closure(f2) == :((a + b) + c)
        
        g1 = () -> a * b
        g2 = () -> g1() - c
        @test expand_closure(g2) == :(a * b - c)
    end
    
    @testset "Deep Nesting (5 levels)" begin
        v1, v2, v3, v4, v5 = 1, 2, 3, 4, 5
        
        d1 = () -> v1 + v2
        d2 = () -> d1() * v3
        d3 = () -> d2() - v4
        d4 = () -> d3() / v5
        d5 = () -> d4() ^ 2
        
        result = expand_closure(d5)
        @test result == :(((v1 + v2) * v3 - v4) / v5 ^ 2)
    end
    
    @testset "Multiple Closure Calls" begin
        x, y, z = 10, 20, 30
        
        c1 = () -> x + y
        c2 = () -> y * z
        combined = () -> c1() + c2()
        
        @test expand_closure(combined) == :((x + y) + y * z)
    end
    
    @testset "Closure Reuse" begin
        k = 100
        reused = () -> k * 2
        expr1 = () -> reused() + reused()
        
        result = expand_closure(expr1)
        @test result == :(k * 2 + k * 2)
    end
    
    # ========================================================================
    # Array Operations
    # ========================================================================
    
    @testset "Array Indexing" begin
        arr = [1, 2, 3, 4, 5]
        
        @test expand_closure(() -> arr[1]) == :(arr[1])
        @test expand_closure(() -> arr[3]) == :(arr[3])
        
        idx = 2
        @test expand_closure(() -> arr[idx]) == :(arr[idx])
    end
    
    @testset "Array Operations" begin
        arr1 = [1, 2, 3]
        arr2 = [4, 5, 6]
        
        @test expand_closure(() -> arr1[1] + arr2[1]) == :(arr1[1] + arr2[1])
        @test expand_closure(() -> arr1[2] * arr2[3]) == :(arr1[2] * arr2[3])
    end
    
    @testset "Nested Array Indexing" begin
        matrix = [[1, 2], [3, 4]]
        
        # Note: This might show as (matrix[1])[1] or similar
        result = expand_closure(() -> matrix[1][1])
        @test result isa Expr
        # Just check it contains the right elements
        @test occursin("matrix", string(result))
    end
    
    @testset "Array Literals" begin
        result = expand_closure(() -> [1, 2, 3])
        @test result == :([1, 2, 3])
        
        x, y, z = 1, 2, 3
        result = expand_closure(() -> [x, y, z])
        @test result == :([x, y, z])
    end
    
    # ========================================================================
    # Struct Operations
    # ========================================================================
    
    @testset "Property Access" begin
        p = TestPoint(1.0, 2.0)
        
        @test expand_closure(() -> p.x) == :(p.x)
        @test expand_closure(() -> p.y) == :(p.y)
        @test expand_closure(() -> p.x + p.y) == :(p.x + p.y)
    end
    
    @testset "Nested Property Access" begin
        line = Line(Vector2D(0.0, 0.0), Vector2D(1.0, 1.0))
        
        result = expand_closure(() -> line.start.x)
        @test result == :(line.start.x)
        
        result = expand_closure(() -> line.start.x + line.stop.y)
        @test result == :(line.start.x + line.stop.y)
    end
    
    @testset "Mixed Array and Struct Access" begin
        items = [Item(1), Item(2), Item(3)]
        
        result = expand_closure(() -> items[1].value)
        # Should contain both indexing and property access
        @test result isa Expr
        @test occursin("items", string(result))
        @test occursin("value", string(result))
    end
    
    # ========================================================================
    # Module Scoping
    # ========================================================================
    
    @testset "Module Scoping" begin
        result = expand_closure(() -> TestModule.K1)
        @test result == :(TestModule.K1)
        
        result = expand_closure(() -> TestModule.K1 + TestModule.K2)
        @test result == :(TestModule.K1 + TestModule.K2)
    end
    
    @testset "Main vs Other Modules" begin
        # Main module variables should not show module prefix
        global test_var_main = 42
        result = expand_closure(() -> test_var_main)
        @test result == :test_var_main
        
        # Other modules should show prefix
        result = expand_closure(() -> AnotherModule.other_var)
        @test result == :(AnotherModule.other_var)
    end
    
    # ========================================================================
    # Math Functions
    # ========================================================================
    
    @testset "Trigonometric Functions" begin
        x = 1.0
        
        @test expand_closure(() -> sin(x)) == :(sin(x))
        @test expand_closure(() -> cos(x)) == :(cos(x))
        @test expand_closure(() -> tan(x)) == :(tan(x))
        @test expand_closure(() -> asin(x)) == :(asin(x))
        @test expand_closure(() -> acos(x)) == :(acos(x))
        @test expand_closure(() -> atan(x)) == :(atan(x))
    end
    
    @testset "Hyperbolic Functions" begin
        x = 1.0
        
        @test expand_closure(() -> sinh(x)) == :(sinh(x))
        @test expand_closure(() -> cosh(x)) == :(cosh(x))
        @test expand_closure(() -> tanh(x)) == :(tanh(x))
    end
    
    @testset "Exponential and Logarithmic" begin
        x = 2.0
        
        @test expand_closure(() -> exp(x)) == :(exp(x))
        @test expand_closure(() -> log(x)) == :(log(x))
        @test expand_closure(() -> log10(x)) == :(log10(x))
        @test expand_closure(() -> sqrt(x)) == :(sqrt(x))
    end
    
    @testset "Other Math Functions" begin
        x = -5.0
        
        @test expand_closure(() -> abs(x)) == :(abs(x))
        @test expand_closure(() -> sign(x)) == :(sign(x))
    end
    
    @testset "Nested Math Functions" begin
        x, y = 1.0, 2.0
        
        @test expand_closure(() -> sin(x) + cos(y)) == :(sin(x) + cos(y))
        @test expand_closure(() -> exp(log(x))) == :(exp(log(x)))
        @test expand_closure(() -> sqrt(x ^ 2 + y ^ 2)) == :(sqrt(x ^ 2 + y ^ 2))
    end
    
    # ========================================================================
    # Custom Functions
    # ========================================================================
    
    @testset "Custom Functions" begin
        double(x) = 2x
        triple(x) = 3x
        
        val = 10
        
        # Custom functions should be preserved, not expanded
        @test expand_closure(() -> double(val)) == :(double(val))
        @test expand_closure(() -> triple(val)) == :(triple(val))
        @test expand_closure(() -> double(val) + triple(val)) == :(double(val) + triple(val))
    end
    
    @testset "Custom Functions with Closures" begin
        myfunc(x, y) = x + y
        
        a, b, c = 1, 2, 3
        f1 = () -> a + b
        combined = () -> myfunc(f1(), c)
        
        @test expand_closure(combined) == :(myfunc(a + b, c))
    end
    
    # ========================================================================
    # DefExpr Integration Tests (if available)
    # ========================================================================
    
    if isdefined(Main, :DefExpr)
        @testset "DefExpr Arithmetic" begin
            d1 = DefExpr(() -> 1)
            d2 = DefExpr(() -> 2)
            
            result = d1 + d2
            @test expand_closure(result.f.obj[]) == :(1 + 2)
            
            d3 = DefExpr(() -> 3)
            result = d1 * d3
            @test expand_closure(result.f.obj[]) == :(1 * 3)
        end
        
        @testset "DefExpr with Variables" begin
            x = 10
            dx = DefExpr(() -> x)
            dy = DefExpr(() -> 20)
            
            result = dx + dy
            expanded = expand_closure(result.f.obj[])
            @test expanded == :(x + 20)
        end
        
        @testset "Nested DefExpr" begin
            a, b, c = 1, 2, 3
            
            f1 = () -> a + b
            f2 = () -> f1() + c
            d2 = DefExpr(f2)
            
            @test expand_closure(d2.f.obj[]) == :((a + b) + c)
        end
    end
    
    # ========================================================================
    # Complex Mixed Cases
    # ========================================================================
    
    @testset "Complex Expression 1: Everything Mixed" begin
        particles = [Particle(1.0, 2.0), Particle(2.0, 3.0)]
        
        scale(x) = x * 1.5
        
        result = expand_closure(() -> particles[1].mass * particles[1].velocity ^ 2 / Physics.c)
        
        # Check it has the right components
        result_str = string(result)
        @test occursin("particles", result_str)
        @test occursin("mass", result_str)
        @test occursin("velocity", result_str)
        @test occursin("Physics.c", result_str)
    end
    
    @testset "Complex Expression 2: Deep Nesting with Everything" begin
        arr = [1, 2, 3]
        config = Config(2.0)
        
        l1 = () -> arr[1] + config.scale
        l2 = () -> l1() * Constants.pi_val
        l3 = () -> sin(l2()) ^ 2
        
        result = expand_closure(l3)
        
        # Verify structure
        @test result isa Expr
        result_str = string(result)
        @test occursin("arr", result_str)
        @test occursin("config", result_str)
        @test occursin("Constants", result_str)
        @test occursin("sin", result_str)
    end
    
    @testset "Complex Expression 3: Multiple Closure Reuse" begin
        x, y, z = 1, 2, 3
        
        base = () -> x + y
        expr1 = () -> base() * z
        expr2 = () -> base() ^ 2
        combined = () -> expr1() + expr2()
        
        result = expand_closure(combined)
        
        # Should have multiple instances of (x + y)
        result_str = string(result)
        count_xy = length(collect(eachmatch(r"x \+ y", result_str)))
        @test count_xy >= 2
    end
    
    # ========================================================================
    # Edge Cases
    # ========================================================================
    
    @testset "Parenthesization" begin
        a, b, c, d = 1, 2, 3, 4
        
        # Test that parentheses are preserved correctly
        f1 = () -> (a + b) * (c + d)
        result = expand_closure(f1)
        @test result == :((a + b) * (c + d))
        
        f2 = () -> a + b * c + d
        result = expand_closure(f2)
        @test result == :(a + b * c + d)
    end
    
    @testset "Division Associativity" begin
        a, b, c = 100, 10, 2
        
        f = () -> a / b / c
        result = expand_closure(f)
        @test result == :(a / b / c)
    end
    
    @testset "Subtraction Associativity" begin
        a, b, c = 10, 5, 2
        
        f = () -> a - b - c
        result = expand_closure(f)
        @test result == :(a - b - c)
    end
    
    @testset "Mixed Operators" begin
        a, b, c, d = 2, 3, 4, 5
        
        f = () -> a + b * c - d / 2
        result = expand_closure(f)
        @test result == :(a + b * c - d / 2)
    end
    
    @testset "Zero Values" begin
        zero_val = 0
        @test expand_closure(() -> zero_val) == :zero_val
        @test expand_closure(() -> 0) == 0
        @test expand_closure(() -> 0.0) == 0.0
        @test expand_closure(() -> 0.0f0) == 0.0f0
    end
    
    @testset "Negative Numbers" begin
        neg = -5
        @test expand_closure(() -> neg) == :neg
        @test expand_closure(() -> -10) == -10
        @test expand_closure(() -> -neg) == :(-neg)
    end
    
    # ========================================================================
    # Type Preservation
    # ========================================================================
    
    @testset "Type Preservation in Literals" begin
        f32 = 1.5f0
        f64 = 1.5
        i32 = Int32(10)
        i64 = Int64(10)
        
        @test expand_closure(() -> f32) isa Float32
        @test expand_closure(() -> f64) isa Float64
        @test expand_closure(() -> i32) isa Int32
        @test expand_closure(() -> i64) isa Int64
    end
    
    # ========================================================================
    # Performance Edge Cases
    # ========================================================================
    
    @testset "Very Deep Nesting (15 levels)" begin
        vals = 1:15
        
        # Create a chain of 15 nested closures
        closures = Function[]
        push!(closures, () -> vals[1] + vals[2])
        
        for i in 3:15
            let prev = closures[end], idx = i
                push!(closures, () -> prev() + vals[idx])
            end
        end
        
        # This should not crash or hang
        result = expand_closure(closures[end])
        @test result isa Expr
    end
    
    @testset "Wide Expression (many terms)" begin
        a = 1; b = 2; c = 3; d = 4; e = 5; f_var = 6; g = 7; h = 8; i = 9; j = 10
        
        wide = () -> a + b + c + d + e + f_var + g + h + i + j
        result = expand_closure(wide)
        
        @test result isa Expr
        # Should have 10 variables
        result_str = string(result)
        for var in [:a, :b, :c, :d, :e, :f_var, :g, :h, :i, :j]
            @test occursin(string(var), result_str)
        end
    end
    
    # ========================================================================
    # Regression Tests
    # ========================================================================
    
    @testset "Regression: convert() Removal" begin
        # Make sure convert() calls are removed for literals
        f = () -> convert(Float32, 0.0)
        result = expand_closure(f)
        @test result == 0.0  # Should be simplified
    end
    
    @testset "Regression: Module Prefix for Operators" begin
        # Operators should not show module prefix
        a, b = 1, 2
        f = () -> a + b
        result = expand_closure(f)
        @test result == :(a + b)
        # Should NOT have module prefix
        result_str = string(result)
        @test !occursin(".:+", result_str)
    end
    
    @testset "Regression: Array Literal Display" begin
        # [1,2,3] should display as [1, 2, 3], not Base.vect(1, 2, 3)
        f = () -> [1, 2, 3]
        result = expand_closure(f)
        @test result == :([1, 2, 3])
        @test !occursin("vect", string(result))
    end
    
end

println("\n" * "="^70)
println("ALL TESTS COMPLETE!")
println("="^70)