module Rootfinding

using ForwardDiff

import Base.show

export Root, newton

struct Root
  root::Float64    #  approximate value of the root
  x_eps::Float64   #  estimate of the error in the x variable
  f_eps::Float64   #  function value at the root f(root)
  num_steps::Int   #  number of steps the method used
  converged::Bool  #  whether or not the stopping criterion was reached
  max_steps::Int   #  the maximum number of steps allowed
end

function Base.show(io::IO,r::Root)
  str = r.converged ? """The root is approximately x̂ = $(r.root)
    An estimate for the error is $(r.x_eps)
    with f(x̂) = $(r.f_eps)
    which took $(r.num_steps) steps""" :
    """The root was not found within $(r.max_steps) steps.
    Currently, the root is approximately x̂ = $(r.root).
    An estimate for the error is $(r.x_eps)
    with f(x̂) = $(r.f_eps)."""
  print(io,str)
end

function newton(f::Function, x0::Number; tol=1e-6, max_steps=10)
  tol > 0 || throw(ArgumentError("The parameter tol much be positive"))
  max_steps > 0 || throw(ArgumentError("The parameter max_steps much be positive"))

  local x1 = x0
  local dx = f(x1)/ForwardDiff.derivative(f,x1)
  local steps = 0

  while abs(dx)>tol && steps<max_steps
    x1 -= dx
    dx = f(x1)/ForwardDiff.derivative(f,x1)
    steps += 1
  end
  Root(x1,dx,f(x1),steps,steps<max_steps,max_steps)
end

end # module Rootfinding