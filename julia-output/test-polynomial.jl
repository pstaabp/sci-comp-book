using .Poly
using Test

function isequal(x::Polynomial,y::Polynomial)
    return x.coeffs == y.coeffs
end

## test the creation polynomials

poly1 = Polynomial([1,2,3])
poly2 = Polynomial([1.0,2.0,3.0])
poly3 = Polynomial([2//3,3//4,5//8])
poly4 = Polynomial([im,2+0im,3-2im,-im])
poly5 = Polynomial([n for n=1:6])
poly6 = Polynomial([1,1.5,2//3])

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

poly10 = Polynomial([1, 2, 3])
poly11 = Polynomial([-2,1,0,1])

@testset "Addition, Subtraction and Constant Multiplication" begin
 @test poly10+poly11 == Polynomial([-1,3,3,1])
 @test poly11-poly10 == Polynomial([-3,-1,-3,1])
 @test 4*poly10 == Polynomial([4,8,12])
 @test poly10*poly11 == Polynomial([-2,-3,-4,4,3])
end

poly21 = Polynomial("-3+10x-5x^4")
poly22 = Polynomial("x^2+2x+3")
poly23 = Polynomial("2x-1")


@testset "Creating a Polynomial from a string with integer coefficients" begin
  @test isa(poly21, Polynomial)
  @test typeof(poly21) == Polynomial{Int64}
  @test isequal(poly21, Polynomial([-3,10,0,0,-5]))
  @test isa(poly22, Polynomial)
  @test typeof(poly22) == Polynomial{Int64}
  @test isequal(poly22, Polynomial([3,2,1]))
  @test isa(poly23, Polynomial)
  @test typeof(poly23) == Polynomial{Int64}
  @test isequal(poly23, Polynomial([-1,2]))
end

poly31 = Polynomial([1.0, 2.0, 3.0])
poly32 = Polynomial([0,4.0,0,-1.0])
poly33 = Polynomial([1/2,1/4,1/8,1/10])

poly34 = Polynomial("3.0x^2+2.0x+1.0")
poly35 = Polynomial("-1.0x^3+4.0")
poly36 = Polynomial("0.5+0.25x+0.125x^2+0.1x^3")


poly41 = Polynomial([1//2, 1//3, 1//4])
poly42 = Polynomial([1,0,0,1//6])
poly43 = Polynomial([-1//8,0,0,0,1])

poly44 = Polynomial("1//4x^2+1//3x+1//2")
poly45 = Polynomial("1//6x^3+1")
poly46 = Polynomial("x^4-1//8")

poly51 = Polynomial([im, 2+im, 3-2im])
poly52 = Polynomial([im,0,1])
poly53 = Polynomial([im,2,3im,4])

poly54 = Polynomial("(3-2im)x^2+(2+im)x+im")
poly55 = Polynomial("im+x^2")
poly56 = Polynomial("4x^3+3imx^2+2x+im")


@testset "Evaluating polynomial with integer coeffs" begin
  @test eval(poly10, 2) == 17
  @test eval(poly10, -1) == 2

end
