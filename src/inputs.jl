export ModelInputs
export add_function!
export add_constraint!
export collect_vary_variables
export build_apply_function
export build_nlopt_objective

export get_bounds
export get_values


mutable struct ModelInputs

    # Structs holding the necessary information to inject variable values into a model.
    input_functions :: Vector{InputFunction}

    # Constraints on the variable values.
    constraints :: Vector{AbstractConstraint}

    # Maps input variables onto indices in the 'flat' input vector.
    variable_map :: Dict{Variable,Int}

    # Keep track of the number of variables already added.
    variable_count :: Int

    function ModelInputs()
        return new([], [], Dict(), 0)
    end
end
input_functions(m :: ModelInputs) = m.input_functions
constraints(m :: ModelInputs) = m.constraints
variable_map(m :: ModelInputs) = m.variable_map
variable_count(m :: ModelInputs) = m.variable_count

function inc_variable_count!(m :: ModelInputs)
    m.variable_count = variable_count(m) + 1
end

function safely_add_variable(m :: ModelInputs, v :: Variable)
    if !(v in keys(variable_map(m)))
        inc_variable_count!(m)
        variable_map(m)[v] = variable_count(m)
    end
end

function add_function!(m :: ModelInputs, i :: InputFunction)
    vars = collect_variables(variables(i))
    for var in vars
        safely_add_variable(m, var)
    end
    m.input_functions = vcat(m.input_functions, i)
end

function add_constraint!(m :: ModelInputs, con :: AbstractConstraint)
    push!(m.constraints, con)
end

function collect_vary_variables(m :: ModelInputs)

    # Empty lists of the variables being collected, and their corresponding functions.
    vary_vars = []
    functions_to_apply = []

    # Strip out varying variables and record the functions that need to be applied.
    for i in input_functions(m)
        new_vars = collect_variables(variables(i); only_vary=true)
        if length(new_vars) > 0
            functions_to_apply = vcat(functions_to_apply, i)
            vary_vars = vcat(vary_vars, new_vars)
        end
    end

    return vary_vars, functions_to_apply
end

function get_bounds(m :: ModelInputs)

    vary_vars, _ = collect_vary_variables(m)
    bounds = map(x -> [min(x), max(x)], vary_vars)

    return collect(zip(bounds...))
end

function get_values(m :: ModelInputs)

    vary_vars, _ = collect_vary_variables(m)

    return value.(vary_vars)
end

function set_values!(m :: ModelInputs, x :: Vector{<:Real})
    vary_vars, _ = collect_vary_variables(m)
    set_value!.(vary_vars, x)
end
