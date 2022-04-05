export ModelInputs
export add_function
export build_nlopt_objective


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
inputs_functions(m :: ModelInputs) = m.input_functions
constraints(m :: ModelInputs) = m.constraints
variable_map(m :: ModelInputs) = m.variable_map
variable_count(m :: ModelInputs) = m.variable_count

function inc_variable_count(m :: ModelInputs)
    m.variable_count = m.variable_count + 1
end

function safely_add_variable(m :: ModelInputs, v :: Variable)
    if !(v in keys(variable_map(m)))
        inc_variable_count(m)
        variable_map(m)[v] = variable_count(m)
    end
end

function add_function(m :: ModelInputs, i :: InputFunction)
    vars = collect_variables(variables(i))
    for var in vars
        safely_add_variable(m, var)
    end
    m.input_functions = vcat(m.input_functions, i)
end

function build_nlopt_objective(a :: AbstractModel, m :: ModelInputs)
    functions_to_apply = []
    vary_vars = []
    for i in input_functions(m)
        new_vars = collect_variables(variables(i); only_vary=true)
        if length(new_vars) > 0
            functions_to_apply = vcat(functions_to_apply, i)
            vary_vars = vcat(vary_vars, new_vars)
        end
    end

    function f(x :: Vector, g)
        for var in 1:length(var_vars)
            var_idx = variable_map(m)[var]
            set_value(var, x[var_idx])
        end
        for i in functions_to_apply
            func(i)(a, variables(i))
        end
    end

    return f, length(vary_vars)
end
