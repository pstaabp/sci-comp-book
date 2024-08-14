using .PlayingCards
using Test

function isequal(x::Card,y::Card)
    return x.rank==y.rank && x.suit==y.suit
end


## test the creation of a card


c1=Card(12)
c2=Card(12,1)
c3=Card(29)
c4=Card(3,3)

fh1 = Hand("4♠,4♢,4♣,A♣,A♡") # this is a full house
fh2 = Hand("3♠,3♢,3♣,A♣,3♡") # this is a 4-of-a-kind

@testset "Legal Card Constructor" begin
  @test isa(Card(1,3),Card)
  @test isa(Card(45),Card)
  @test isa(Card("3\u2660"),Card)
  @test isa(Card("T♣"),Card)
end

@testset "Illegal Cards throws exceptions" begin
  @test_throws ArgumentError Card(0,3)
  @test_throws ArgumentError Card(14,2)
  @test_throws ArgumentError Card(1,0)
  @test_throws ArgumentError Card(0,5)
  @test_throws ArgumentError Card("AS")
end

@testset "Legal Hand Constructor" begin
  @test isa(Hand([Card(4,1),Card(4,2),Card(4,3),Card(7,3),Card(7,4)]),Hand)
  @test isa(Hand(["2♢","Q♠","T♠","T♣","5♡"]),Hand)
  @test isa(Hand("3♠,4♢,A♠,A♣,K♡"),Hand)
end

@testset "Illegal Hand throws exceptions" begin
  @test_throws ArgumentError Hand([Card(0,3),Card(2,2),Card(4,3),Card(10,2),Card(13,1)]) # card rank not legal
  @test_throws ArgumentError Hand([Card(1,5),Card(2,2),Card(4,3),Card(10,2),Card(13,1)]) #card suit not legal
  @test_throws ArgumentError Hand([Card(1,0),Card(2,2),Card(4,3),Card(10,2),Card(13,1)]) # card suit not legal
  @test_throws ArgumentError Hand(["2♢","QD","T♠","T♣","5♡"]) # card suit not legal
  @test_throws ArgumentError Hand(["2♢","Q♢","T♠","T♣","1♡"]) # card rank not legal
end

@testset "Card Tests" begin
  @test isa(c1, Card)
  @test isequal(c1,c2)
  @test isequal(c3,c4)
end

@testset "Full House" begin
  @test isFullHouse(fh1)
  @test !isFullHouse(fh2)
end



