export Variable
export set_min!, set_max!, set_bounds!, set_value_and_bound!, set_vary!
export array_variable
export scalar_variable


mutable struct Variable
    value :: Real
    min :: Real
    max :: Real
    vary :: Bool

    function Variable(v)
        return new(v, v, v, false)
    end
end
value(v :: Variable) = v.value
min(v :: Variable) = v.min
max(v :: Variable) = v.max
vary(v :: Variable) = v.vary

const VariableGroup = Dict{Symbol,Union{Variable,AbstractArray{Variable}}}
const VariableContainer = Union{Variable,AbstractArray{Variable},VariableGroup}

function set_value!(v :: Variable, x :: Real)
    v.value = x
end
function set_min!(v :: Variable, x :: Real)
    v.min = x
end
function set_max!(v :: Variable, x :: Real)
    v.max = x
end
function set_bounds!(v :: Variable, x :: Real, y :: Real)
    set_min!(v, x)
    set_max!(v, y)
end
function set_value_and_bounds!(v :: Variable, x :: Real, y :: Real, z :: Real)
    set_value!(v, x)
    set_min!(v, y)
    set_max!(v, z)
end
function set_vary!(v :: Variable, x :: Bool)
    v.vary = x
end

##########

function randomize(v :: Variable)
    set_value!(v, rand() * (max(v) - min(v)) + min(v))
end

##########

function array_variable(; kwargs...)
    size_tuple = length.(i for i in values(kwargs))
    z = zeros(size_tuple...)
    v = Variable.(z)
    return AxisArray(v; kwargs...)
end

function scalar_variable()
    return Variable(0.0)
end

##########

function collect_variables(v :: Variable; only_vary=false)
    return (vary(v) || !only_vary) ? [v] : []
end
function collect_variables(v :: AbstractArray{Variable}; only_vary=false)
    array_result = map(x -> collect_variables(x; only_vary=only_vary), v)
    return collect(Iterators.flatten(array_result))
end
function collect_variables(v :: VariableGroup; only_vary=false)
    array_result = map(x -> collect_variables(x; only_vary=only_vary), values(v))
    return collect(Iterators.flatten(array_result))
end
