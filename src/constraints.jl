export SumEqualsConstraint
export LessEqualConstraint


abstract type AbstractConstraint end

# All AbstractConstraints should build a function that can be plugged into the NLOpt interface.
function build_function(:: Dict{Variable,Int}, :: AbstractConstraint) end

##########

struct SumEqualsConstraint <: AbstractConstraint
    variables :: VariableContainer
    rhs :: Real
end
variables(con :: SumEqualsConstraint) = con.variables
rhs(con :: SumEqualsConstraint) = con.rhs

function build_function(variable_map :: Dict{Variable,Int}, con :: SumEqualsConstraint)
    f(x) = sum(x[variable_map[v]] for v in variables(con)) - rhs(con)
    return f
end

##########

struct LessEqualConstraint <: AbstractConstraint
    lhs_variables :: VariableContainer
    rhs_variables :: VariableContainer
end
lhs_variables(con :: LessEqualConstraint) = con.lhs_variables
rhs_variables(con :: LessEqualConstraint) = con.rhs_variables

function build_function(variable_map :: Dict{Variable,Int}, con :: LessEqualConstraint)
    f(x) = (sum(x[variable_map[v]] for v in lhs_variables(con)) -
        sum(x[variable_map[v]] for v in rhs_variables(con)))
    return f
end
