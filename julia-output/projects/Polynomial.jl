module Poly

import Base: show, +, -, *

export Polynomial

struct Polynomial{T<:Number}
    coeffs::Vector{T}

    function Polynomial(c::Vector{T}) where T<:Number
        new{T}(c)
    end

    function Polynomial(str::String)
        local terms = map(t -> parseTerm(t), splitPoly(str))
        local type = promote_type(map(t->typeof(t.coeff), terms)...)
        local coeffs = zeros(type, maximum(map(t -> t.pow, terms))+1)
        for term in terms
            coeffs[term.pow+1] = term.coeff
        end
        new{type}(coeffs)
    end
end



function Base.show(io::IO, p::Polynomial)
    print(io, strip(reduce((str, n) -> "$str $(n==1 ? "" : "+") $(p.coeffs[n]) x^$(n-1)", eachindex(p.coeffs), init="")))
end

function splitPoly(polyString::String)
    polyString = replace(polyString, r"\s+" => "")
    local terms = String[]
    # if the first character is a +/-, start the index at 2
    local ind1 = polyString[1] ∈ ['+', '-'] ? 2 : 1
    local start = 1  # keep track of the index of the terms. 
    local in_parens = false  # determines if there is a set of parentheses.
    for i=ind1:length(polyString)
        if polyString[i] == '('
            in_parens = true
        elseif polyString[i] == ')'
            in_parens = false
        end
        if !in_parens && polyString[i] ∈ ['+', '-']
            push!(terms, polyString[start:(i-1)])
            start = i
        end
    end
    push!(terms, polyString[start:end])
    terms
end

function parseConstant(str::AbstractString)
    local m1 = match(r"^([+-])?$", str)
    if !isnothing(m1) # this handles cases like "x^2", "-x^2", "+x^2"
        return isnothing(m1[1]) ? 1 : m1[1] == "+" ? 1 : -1
    end

    local m2 = match(r"^(([+-])?\d+(\.\d*)?)$", str)
    if !isnothing(m2) # the number is an integer or a float.
        return isnothing(m2[3]) ? parse(Int, m2[1]) : parse(Float64, m2[1])
    end

    local m3 = match(r"^([+-]?\d+//\d+)$", str)
    if !isnothing(m3)
        return parse(Rational{Int}, str)
    end

    # parse a number of (c) im
    local m4 = match(r"^([+-]?[\d\/.]*)?im$", str)
    if !isnothing(m4)
        return isnothing(m4[1]) ? im : parseConstant(m4[1]) *im
    end

    local m5 = match(r"^([+-]?[\d\/.*im]+)([+-])([\d\/.*im]+)$", str)
    if !isnothing(m5)
        arg1, arg2 = parseConstant(m5[1]), parseConstant(m5[3])
        return m5[2] == "+" ? arg1 + arg2 : arg1 - arg2
    end

    # If there are ( ) around the number
    local m6 = match(r"^([+-])?\(([\d/.+-im]+)\)$", str)
    if !isnothing(m6)
        return isnothing(m6[1]) ? parseConstant(m6[2]) : m6[1] == "+" ? parseConstant(m6[2]) : -1*parseConstant(m6[2])
    end

    error("The string: $str could not be parsed as a constant.")
end
function parseTerm(str::String)
    local term1_re = r"^(.*?)?(x(?:\^(\+?\d+))?)?$"
    local m1 = match(term1_re, str)
    local coeff, power
    isnothing(m1) && error("The term $str is not a polynomial term")
    # @show m1
    if isnothing(m1[2]) ## just a constant term.
        return (coeff=parseConstant(m1[1]), pow=0)
    elseif isnothing(m1[3]) ## just an x
        return (coeff=parseConstant(m1[1]), pow=1)
    else
        return (coeff=parseConstant(m1[1]), pow=parse(Int, m1[3]))
    end
end

# Operations on Polynomials

function +(p1::Polynomial{T1}, p2::Polynomial{T2}) where {T1<:Number,T2<:Number}
    S = promote_type(T1, T2)
    c1 = p1.coeffs
    c2 = p2.coeffs
    sum_array = zeros(S, max(length(c1), length(c2)))
    sum_array[1:length(c1)] .+= c1
    sum_array[1:length(c2)] .+= c2

    # strip any trailing zeros from the sum_array
    last_nonzero = findlast(!iszero, sum_array)
    if !isnothing(last_nonzero)
        sum_array = sum_array[1:last_nonzero]
    else
        sum_array = [zero(S)] # Default to [0] if all terms canceled
    end
    Polynomial(sum_array)
end

function -(p1::Polynomial{T1}, p2::Polynomial{T2}) where {T1<:Number,T2<:Number}
    S = promote_type(T1, T2)
    c1 = p1.coeffs
    c2 = p2.coeffs
    diff_array = zeros(S, max(length(c1), length(c2)))
    diff_array[1:length(c1)] .+= c1
    diff_array[1:length(c2)] .-= c2

    # strip any trailing zeros from the diff_array
    last_nonzero = findlast(!iszero, diff_array)
    if !isnothing(last_nonzero)
        diff_array = diff_array[1:last_nonzero]
    else
        diff_array = [zero(S)] # Default to [0] if all terms canceled
    end
    Polynomial(diff_array)
end

# Constant multiplication

function *(c::Number, p::Polynomial{<:Number})
    Polynomial(c * p.coeffs)
end

# Unary minus (negation)

function -(p::Polynomial{<:Number})
    Polynomial(-1 * p.coeffs)
end

# Multiplication 

function *(p1::Polynomial{T1}, p2::Polynomial{T2}) where {T1<:Number,T2<:Number}
    c1, c2 = p1.coeffs, p2.coeffs
    prod_array = zeros(promote_type(T1, T2), length(c1)+length(c2)-1)
    for i in eachindex(c1)
        for j in eachindex(c2)
            prod_array[i+j-1] += c1[i] * c2[j]
        end
    end

    # Trim trailing zeros if either polynomial was zero
    last_nonzero = findlast(!iszero, prod_array)
    clean_array = isnothing(last_nonzero) ? [zero(promote_type(T1, T2))] : prod_array[1:last_nonzero]
    Polynomial(clean_array)
end
end