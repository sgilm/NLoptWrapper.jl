export Variable
# export value, min, max, vary
export set_value!, set_min!, set_max!, set_bounds!, set_value_and_bounds!, set_vary!
export randomize!
export variable_from_value
export empty_array_variable
export collect_variables


mutable struct Variable
    value :: Real
    min :: Real
    max :: Real
    vary :: Bool
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

function randomize!(v :: Variable)
    set_value!(v, rand() * (max(v) - min(v)) + min(v))
end

##########

function variable_from_value(v :: Real; vary=true)
    return Variable(v, v, v, vary)
end

function variable_from_value(v :: AxisArray{<:Real}; vary=true)
    w = variable_from_value.(v; vary=vary)
    return AxisArray(w, AxisArrays.axes(v))
end

function empty_array_variable(vary :: Bool; kwargs...)
    size_tuple = length.(i for i in values(kwargs))
    z = zeros(size_tuple...)
    return variable_from_value(AxisArray(z; kwargs...); vary=vary)
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
