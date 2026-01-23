module PlayingCards

import Base.show
import Random: shuffle!

export Card, Hand, isFullHouse, isequal, runTrials, isRun, isOneSuit, isRoyalFlush

ranks = ['A','2','3','4','5','6','7','8','9','T','J','Q','K']
suits = ['\u2660','\u2661','\u2662','\u2663']

struct Card
    rank::Int
    suit::Int

    # construct a card based on the rank and suit
    function Card(r::Int,s::Int)
        1 <= r <=13  || throw(ArgumentError("The rank must be an integer between 1 and 13."))
        1 <= s <= 4  || throw(ArgumentError("The suit must be an integer between 1 and 4."))
        new(r,s)
    end

    # construct a card based on the number in a deck
    function Card(i::Int)
        1 <= i <= 52 || throw(ArgumentError("The argument must be an integer between 1 and 52"))
        i%13==0 ? new(13,div(i,13)) : new(i%13,div(i,13)+1)
    end

    # construct a card based on a string representation of the card
    function Card(str::String)
        length(str)==2 || throw(ArgumentError("The string should only be 2 characters"))
        local r = findfirst(a->a==str[1],ranks)
        !isnothing(r) &&  1 <= r <= 13 || throw(ArgumentError(string("The first character should be one of ",join(ranks,","))))
        local s=findfirst(a->a==str[2],suits)
        !isnothing(s) && 1<= s <= 4 || throw(ArgumentError(string("The second character should be one of ",join(suits,","))))
        new(r,s)
    end
end


struct Hand
  cards::Vector{Card}

  # constructors
  Hand(cards::Vector{Card}) = new(cards)
  Hand(cards::Vector{String}) = new(map(Card,cards))
  Hand(s::String) = new(map(Card,map(String,split(s,','))))
end

function Base.show(io::IO, c::Card)
  print(io,string(ranks[c.rank],suits[c.suit]))
end

function Base.show(io::IO, h::Hand)
  print(io,string("[",join(map(c->string(ranks[c.rank],suits[c.suit]),h.cards),",")),"]")
end

function isFullHouse(h::Hand)
  local cranks=sort(map(c->c.rank,h.cards))
  cranks[2]==cranks[1] && cranks[5]==cranks[4] && (cranks[3]==cranks[2] || cranks[4]==cranks[3]) &&
  cranks[2] != cranks[4]
end

function isequal(x::Card,y::Card)
  x.rank==y.rank && x.suit==y.suit
end

function isOneSuit(h::Hand)
  local s = map(c->c.suit,h.cards)
  s[1]==s[2]==s[3]==s[4]==s[5]
end

function isRun(h::Hand)
  local r = sort(map(c->c.rank,h.cards))
  r[2]==r[1]+1 && r[3]==r[2]+1 && r[4]==r[3]+1 && r[5]==r[4]+1 ||
  r[1]==1 && r[2]==10 && r[3]==11 && r[4]==12 && r[5]==13 ## ace high run
end

function isRoyalFlush(h::Hand)
  local r = sort(map(c->c.rank,h.cards))
  r[1]==1 && r[2]==10 && r[3]==11 && r[4]==12 && r[5]==13 && isOneSuit(h)
end

function runTrials(f::Function, trials::Integer)
  local deck=collect(1:52) # creates the array [1,2,3,...,52]
  local num_hands=0
  for i=1:trials
    shuffle!(deck)
    h = Hand(map(Card,deck[1:5])) # creates a hand of the first five cards of the shuffled deck
    if f(h)
      num_hands+=1
    end
  end
  num_hands/trials
end

end #module PlayingCards