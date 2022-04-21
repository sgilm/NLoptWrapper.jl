module NLOptWrapper

using AxisArrays
using NLopt

include("variables.jl")
include("model.jl")
include("functions.jl")
include("constraints.jl")
include("inputs.jl")

include("nlopt_problem.jl")

end
