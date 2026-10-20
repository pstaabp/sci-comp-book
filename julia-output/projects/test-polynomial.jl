using .Poly
using Test

import Base.==
import Base.≈

==(p1::Polynomial, p2::Polynomial) = p1.coeffs == p2.coeffs
≈(p1::Polynomial, p2::Polynomial) = p1.coeffs ≈ p2.coeffs

## test the creation polynomials

poly1 = Polynomial([1, 2, 3])
poly2 = Polynomial([1.0, 2.0, 3.0])
poly3 = Polynomial([2//3, 3//4, 5//8])
poly4 = Polynomial([im, 2+0im, 3-2im, -im])
poly5 = Polynomial([n for n=1:6])
poly6 = Polynomial([1, 1.5, 2//3])

@testset "Creating a Polynomial as a Vector of Coefficients" begin
    @test isa(poly1, Polynomial)
    @test typeof(poly1) == Polynomial{Int64}
    @test isa(poly2, Polynomial)
    @test typeof(poly2) == Polynomial{Float64}
    @test isa(poly3, Polynomial)
    @test typeof(poly3) == Polynomial{Rational{Int64}}
    @test isa(poly4, Polynomial)
    @test typeof(poly4) == Polynomial{Complex{Int64}}
    @test isa(poly5, Polynomial)
    @test typeof(poly5) == Polynomial{Int64}
    @test isa(poly6, Polynomial)
    @test typeof(poly6) == Polynomial{Float64}
end

@testset "Base.show" begin
    @test string(poly1) == "1 x^0 + 2 x^1 + 3 x^2"
    @test string(poly2) == "1.0 x^0 + 2.0 x^1 + 3.0 x^2"
    @test string(poly3) == "2//3 x^0 + 3//4 x^1 + 5//8 x^2"
end

@testset "Polynomial Addition Tests" begin

    # 1. Equal length vectors (Same Degree & Same Type)
    @testset "Same Length & Type" begin
        p1 = Polynomial([1, 2, 3])      # 3x² + 2x + 1
        p2 = Polynomial([4, 5, 6])      # 6x² + 5x + 4
        res = p1 + p2
        @test res.coeffs == [5, 7, 9]
        @test eltype(res.coeffs) == Int
    end

    # 2. Unequal length: First polynomial higher degree
    @testset "p1 Degree > p2 Degree" begin
        p1 = Polynomial([1, 2, 3, 4])   # 4x³ + 3x² + 2x + 1
        p2 = Polynomial([1, 1])         # x + 1
        @test p1 + p2 == Polynomial([2, 3, 3, 4])
    end

    # 3. Unequal length: Second polynomial higher degree
    @testset "p1 Degree < p2 Degree" begin
        p1 = Polynomial([1, 1])         # x + 1
        p2 = Polynomial([1, 2, 3, 4])   # 4x³ + 3x² + 2x + 1
        res = p1 + p2
        @test res.coeffs == [2, 3, 3, 4]
    end

    # 4. Type promotion: Int + Float64
    @testset "Type Promotion (Int + Float64)" begin
        p1 = Polynomial([1, 2])         # Int64
        p2 = Polynomial([1.5, 2.5])     # Float64
        res = p1 + p2
        @test res.coeffs == [2.5, 4.5]
        @test eltype(res.coeffs) == Float64
    end

    # 5. Type promotion: Int + Complex
    @testset "Type Promotion (Int + Complex)" begin
        p1 = Polynomial([1, 2])
        p2 = Polynomial([1 + 2im, 3 + 0im])
        res = p1 + p2
        @test res.coeffs == [2 + 2im, 5 + 0im]
        @test eltype(res.coeffs) == Complex{Int}
    end

    # 6. Addition with Zero Polynomial
    @testset "Addition with Zero" begin
        p1 = Polynomial([3, -2, 5])
        p_zero = Polynomial([0])
        res = p1 + p_zero
        @test res.coeffs == [3, -2, 5]
    end

    # 7. Complete Cancellation (Result is zero)
    @testset "Complete Term Cancellation" begin
        p1 = Polynomial([1, -2, 3])
        p2 = Polynomial([-1, 2, -3])
        res = p1 + p2
        @test res.coeffs == [0]
    end

    # 8. Leading/Highest-degree Term Cancellation (Degree drop)
    @testset "Highest Degree Term Cancellation" begin
        p1 = Polynomial([1, 2, 5])      #  5x² + 2x + 1
        p2 = Polynomial([3, 1, -5])     # -5x² +  x + 3
        res = p1 + p2
        @test res.coeffs == [4, 3]      # Degree drops to 1 (3x + 4)
    end

    # 9. Commutative Property Check (p1 + p2 == p2 + p1)
    @testset "Commutative Property" begin
        p1 = Polynomial([1, 4, 9])
        p2 = Polynomial([2.0, 3.0])
        @test (p1 + p2).coeffs == (p2 + p1).coeffs
    end

    # 10. Associative Property Check ((p1 + p2) + p3 == p1 + (p2 + p3))
    @testset "Associative Property" begin
        p1 = Polynomial([1, 2])
        p2 = Polynomial([3.5, 4.5, 5.5])
        p3 = Polynomial([10, 20])
        lhs = (p1 + p2) + p3
        rhs = p1 + (p2 + p3)
        @test lhs.coeffs ≈ rhs.coeffs
    end

end

@testset "Polynomial Subtraction Tests" begin

    # 1. Equal length vectors (Same Degree & Same Type)
    @testset "Same Length & Type" begin
        p1 = Polynomial([5, 7, 9])      # 9x² + 7x + 5
        p2 = Polynomial([4, 5, 6])      # 6x² + 5x + 4
        res = p1 - p2
        @test res.coeffs == [1, 2, 3]
        @test eltype(res.coeffs) == Int
    end

    # 2. Unequal length: Minuend (p1) higher degree
    @testset "p1 Degree > p2 Degree" begin
        p1 = Polynomial([1, 2, 3, 4])   # 4x³ + 3x² + 2x + 1
        p2 = Polynomial([1, 1])         # x + 1
        res = p1 - p2
        @test res.coeffs == [0, 1, 3, 4]
    end

    # 3. Unequal length: Subtrahend (p2) higher degree (Yields negative leading terms)
    @testset "p1 Degree < p2 Degree" begin
        p1 = Polynomial([1, 1])         # x + 1
        p2 = Polynomial([1, 2, 3, 4])   # 4x³ + 3x² + 2x + 1
        res = p1 - p2
        @test res.coeffs == [0, -1, -3, -4]
    end

    # 4. Type promotion: Int - Float64
    @testset "Type Promotion (Int - Float64)" begin
        p1 = Polynomial([5, 10])        # Int64
        p2 = Polynomial([1.5, 2.5])     # Float64
        res = p1 - p2
        @test res.coeffs == [3.5, 7.5]
        @test eltype(res.coeffs) == Float64
    end

    # 5. Self-Subtraction (A - A == 0)
    @testset "Self Subtraction Yields Zero" begin
        p = Polynomial([1, 2, 3, 4])
        res = p - p
        @test res.coeffs == [0]
    end

    # 6. Unary Minus (Negation)
    @testset "Unary Minus" begin
        p = Polynomial([1, -2, 3])
        res = -p
        @test res.coeffs == [-1, 2, -3]
    end

    # 7. Subtraction with Zero Polynomial
    @testset "Subtracting Zero" begin
        p = Polynomial([3, -2, 5])
        p_zero = Polynomial([0])
        res = p - p_zero
        @test res.coeffs == [3, -2, 5]
    end

    # 8. Highest Degree Cancellation (Degree reduction)
    @testset "Highest Degree Term Cancellation" begin
        p1 = Polynomial([1, 2, 5])      # 5x² + 2x + 1
        p2 = Polynomial([3, 1, 5])      # 5x² +  x + 3
        res = p1 - p2
        @test res.coeffs == [-2, 1]     # Degree drops to 1 (x - 2)
    end

    # 9. Anti-commutative Property (p1 - p2 == -(p2 - p1))
    @testset "Anti-commutative Property" begin
        p1 = Polynomial([1, 4, 9])
        p2 = Polynomial([2.0, 3.0])
        lhs = p1 - p2
        rhs = -(p2 - p1)
        @test lhs.coeffs ≈ rhs.coeffs
    end

    # 10. Identity Check: (p1 - p2) + p2 == p1
    @testset "Additive Inverse Identity" begin
        p1 = Polynomial([1, 5, 2, 8])
        p2 = Polynomial([3.5, 1.5])
        res = (p1 - p2) + p2
        @test res.coeffs ≈ p1.coeffs
    end

end

@testset "Polynomial Multiplication Tests" begin

    # 1. Standard Multiplication (Same Type)
    @testset "Standard Multiplication" begin
        # (2x + 1)(3x + 4) = 6x² + 11x + 4
        p1 = Polynomial([1, 2])
        p2 = Polynomial([4, 3])
        res = p1 * p2
        @test res == Polynomial([4, 11, 6])
        @test eltype(res.coeffs) == Int
    end

    # 2. Degree Additive Property: deg(p1 * p2) == deg(p1) + deg(p2)
    @testset "Degree Property" begin
        p1 = Polynomial([1, 0, 3])  # 3x² + 1 (length 3)
        p2 = Polynomial([2, 4])     # 4x + 2 (length 2)
        res = p1 * p2
        @test res == Polynomial([2, 4, 6, 12]) # 12x³ + 6x² + 4x + 2
        @test length(res.coeffs) == 4
    end

    # 3. Type Promotion (Int * Float64)
    @testset "Type Promotion (Int * Float64)" begin
        p1 = Polynomial([1, 2])      # Int64
        p2 = Polynomial([0.5, 1.5])  # Float64
        res = p1 * p2
        res ≈ Polynomial([0.5, 2.5, 3.0])
        @test eltype(res.coeffs) == Float64
    end

    # 4. Type Promotion (Int * Complex)
    @testset "Type Promotion (Int * Complex)" begin
        p1 = Polynomial([1, 2])
        p2 = Polynomial([1 + 2im, 0 + 1im])
        res = p1 * p2
        res == Polynomial([1 + 2im, 2 + 5im, 2im])
        @test eltype(res.coeffs) == Complex{Int}
    end

    # 5. Zero Element Absorbing Property (p * 0 == 0)
    @testset "Multiplication by Zero" begin
        p1 = Polynomial([1, 2, 3])
        p_zero = Polynomial([0])
        p1 * p_zero == p_zero
    end

    # 6. Multiplicative Identity (p * 1 == p)
    @testset "Multiplicative Identity" begin
        p1 = Polynomial([3, -2, 5])
        p_one = Polynomial([1])
        res = p1 * p_one
        @test res.coeffs == p1.coeffs
    end

    # 7. Difference of Squares: (x - a)(x + a) = x² - a²
    @testset "Difference of Squares" begin
        p1 = Polynomial([-3, 1]) # x - 3
        p2 = Polynomial([3, 1])   # x + 3
        p1 * p2 == Polynomial([-9, 0, 1]) # x² - 9
    end

    # 8. Commutative Property (p1 * p2 == p2 * p1)
    @testset "Commutative Property" begin
        p1 = Polynomial([1, 4, 9])
        p2 = Polynomial([2.0, 3.0])
        @test p1*p2 == p2 * p1
    end

    # 9. Associative Property ((p1 * p2) * p3 == p1 * (p2 * p3))
    @testset "Associative Property" begin
        p1 = Polynomial([1, 2])
        p2 = Polynomial([3.0, 1.0])
        p3 = Polynomial([2, 0, 1])
        @test (p1 * p2) * p3 == p1 * (p2 * p3)
    end

    # 10. Distributive Property: p1 * (p2 + p3) == (p1 * p2) + (p1 * p3)
    @testset "Distributive Property" begin
        p1 = Polynomial([2, 1])
        p2 = Polynomial([1, 3])
        p3 = Polynomial([4, 2, 1])
        @test p1 * (p2 + p3) == (p1 * p2) + (p1 * p3)
    end
end

@testset "parsing individual terms" begin
    @testset "parsing constant terms" begin
        @test Poly.parseTerm("1") == (coeff=1, pow=0)
        @test Poly.parseTerm("+5") == (coeff=5, pow=0)
        @test Poly.parseTerm("-1") == (coeff=-1, pow=0)
        @test Poly.parseTerm("0.5") == (coeff=0.5, pow=0)
    end

    @testset "parsing linear terms" begin
        @test Poly.parseTerm("x") == (coeff=1, pow=1)
        @test Poly.parseTerm("+x") == (coeff=1, pow=1)
        @test Poly.parseTerm("-x") == (coeff=-1, pow=1)
        @test Poly.parseTerm("10x") == (coeff=10, pow=1)
        @test Poly.parseTerm("0.5x") == (coeff=0.5, pow=1)
        @test Poly.parseTerm("-0.25x") == (coeff=-0.25, pow=1)
    end

    @testset "parsing higher order terms" begin
        @test Poly.parseTerm("x^2") == (coeff=1, pow=2)
        @test Poly.parseTerm("x^20") == (coeff=1, pow=20)
        @test Poly.parseTerm("3x^2") == (coeff=3, pow=2)
        @test Poly.parseTerm("+3x^2") == (coeff=3, pow=2)
        @test Poly.parseTerm("-3x^2") == (coeff=-3, pow=2)
    end

end


@testset "Creating a Polynomial from a string with integer coefficients" begin
    poly1 = Polynomial("-3+10x-5x^4")
    @test isa(poly1, Polynomial)
    @test typeof(poly1) == Polynomial{Int64}
    @test poly1 == Polynomial([-3, 10, 0, 0, -5])

    poly2 = Polynomial("x^2+2x+3")
    @test isa(poly2, Polynomial)
    @test typeof(poly2) == Polynomial{Int64}
    @test poly2 == Polynomial([3, 2, 1])

    poly3 = Polynomial("2x-1")
    @test isa(poly3, Polynomial)
    @test typeof(poly3) == Polynomial{Int64}
    @test poly3 == Polynomial([-1, 2])
end

@testset "Parsing strings with integer coefficients" begin
    poly1 = Polynomial("-3+10x-5x^4")
    poly2 = Polynomial("x^2+2x+3")
    poly3 = Polynomial("2x-1")
    poly4 = Polynomial("1+x+x^2")
    poly5 = Polynomial("x^2-7")

    @test isa(poly1, Polynomial)
    @test typeof(poly1) == Polynomial{Int64}
    @test poly1 == Polynomial([-3, 10, 0, 0, -5])
    @test isa(poly2, Polynomial)
    @test typeof(poly2) == Polynomial{Int64}
    @test poly2 == Polynomial([3, 2, 1])
    @test isa(poly3, Polynomial)
    @test typeof(poly3) == Polynomial{Int64}
    @test poly3 == Polynomial([-1, 2])
    @test poly4 == Polynomial([1, 1, 1])
    @test isa(poly4, Polynomial)
    @test typeof(poly4) == Polynomial{Int64}
    @test poly5 == Polynomial([-7, 0, 1])
    @test isa(poly5, Polynomial)
    @test typeof(poly5) == Polynomial{Int64}
end

@testset "Parsing string of polynomial with Floating Point coeffs" begin
    poly1 = Polynomial("3.0x^2+2.0x+1.0")
    @test isa(poly1, Polynomial)
    @test typeof(poly1) == Polynomial{Float64}
    @test poly1 == Polynomial([1.0, 2.0, 3.0])

    poly2 = Polynomial("-1.0x^3+4.0")
    @test isa(poly2, Polynomial)
    @test typeof(poly2) == Polynomial{Float64}
    @test poly2 == Polynomial([4.0, 0, 0, -1.0])

    poly3 = Polynomial("0.5+0.25x+0.125x^2+0.1x^3")
    @test isa(poly3, Polynomial)
    @test typeof(poly3) == Polynomial{Float64}
    @test poly3 == Polynomial([0.5, 0.25, 0.125, 0.1])
end

@testset "Parsing string of polynomial with rational coefficients" begin
    poly1 = Polynomial("1//4x^2+1//3x+1//2")
    @test isa(poly1, Polynomial)
    @test typeof(poly1) == Polynomial{Rational{Int}}
    @test poly1 == Polynomial([1//2, 1//3, 1//4])

    poly2 = Polynomial("1//6x^3+1")
    @test isa(poly2, Polynomial)
    @test typeof(poly2) == Polynomial{Rational{Int}}
    @test poly2 == Polynomial([1//1, 0, 0, 1//6])

    poly3 = Polynomial("x^4-1//8")
    @test isa(poly3, Polynomial)
    @test typeof(poly3) == Polynomial{Rational{Int}}
    @test poly3 == Polynomial([-1//8, 0, 0, 0, 1//1])


end



@testset "Parsing string of polynomial with complex coefficients" begin
    poly1 = Polynomial("(3-2im)x^2+(2+im)x+im")
    @test typeof(poly1) == Polynomial{Complex{Int}}
    @test poly1 == Polynomial([im, 2+im, 3-2im])
    poly2 = Polynomial("im+x^2")
    @test typeof(poly2) == Polynomial{Complex{Int}}
    @test poly2 == Polynomial([im, 0, 1+0im])
    poly3 = Polynomial("4x^3+3imx^2+2x+im")
    @test typeof(poly3) == Polynomial{Complex{Int}}
    @test poly3 == Polynomial([im, 2+0*im, 3im, 4+0*im])
end


