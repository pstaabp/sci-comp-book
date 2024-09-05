module Poly

export Polynomial

struct Polynomial{T <: Number}
  coeffs::Vector{T}

  # function Polynomial(c::Vector{T}) where T <: Number
  #   new{T}(c)
  # end

  # function Polynomial(str::String)
  #   local terms = map(t -> polyTerm(t), splitPoly(str))
  #   local coeffs = zeros(Int,maximum(map(t -> t.pow, terms))+1)
  #   for term in terms
  #     coeffs[term.pow+1] = term.coeff
  #   end
  #   new{Int}(coeffs)
  # end
end



function Base.show(io::IO, p::Polynomial)
  print(io, strip(reduce((str, n) -> "$str $(n==1 ? "" : "+") $(p.coeffs[n]) x^$(n-1)", 1:length(p.coeffs), init="")))
end

function splitPoly(p::String)
  local terms = String[]
  # if the first character is a +/-, start the index at 2
  local ind1 = occursin(r"^[+-]",p) ? 2 : 1

  while true
    ind2 = findnext(r"[+-]", p, ind1)
    if isnothing(ind2)
      # Push the last term onto the term stack.
      push!(terms, string(SubString(p, ind1-1)))
      break
    end

    # The first time through the loop, the substring calculation is different.
    push!(terms, string(SubString(p,(ind1 == 1 ? 1 : ind1 -1):first(ind2)-1)))
    ind1 = first(ind2)+1
  end
  terms
end

function polyTerm(str::String)
  local poly_re = r"^([+-]?)(\d+)?(x(\^(\d+))?)?$"
  local m = match(poly_re, str)
  local c = "$(m[1])$(isnothing(m[2]) ? 1 : m[2])"
  (coeff = parse(Int, c), pow = m[3] == "x" ? 1 : m[5] !== nothing ? parse(Int, m[5]) : 0)
end

end