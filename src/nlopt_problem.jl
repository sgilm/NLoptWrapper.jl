export NLOptProblem
export solve!


struct NLOptProblem
    model :: AbstractModel
    inputs :: ModelInputs
end
model(P :: NLOptProblem) = P.model
inputs(P :: NLOptProblem) = P.inputs


function update_model!(P :: NLOptProblem)
    for i in input_functions(inputs(P))
        apply!(model(P), i)
    end
end

function build_apply_function(P :: NLOptProblem)

    vary_vars, functions_to_apply = collect_vary_variables(inputs(P))

    function apply_function!(x :: Vector)
        for v in vary_vars
            var_idx = variable_map(inputs(P))[v]
            set_value!(v, x[var_idx])
        end
        for i in functions_to_apply
            apply!(model(P), i)
        end
    end

    return apply_function!, length(vary_vars)
end

function solve!(P :: NLOptProblem)

    apply_function!, n = build_apply_function(P)
    
    function nlopt_obj!(x :: Vector, :: Any)

        # Update model.
        apply_function!(x)
        return compute_loss(model(P))
    end

    lbs, ubs = get_bounds(inputs(P))
    init_x = get_values(inputs(P))

    opt = Opt(:LN_COBYLA, n)
    opt.lower_bounds = collect(lbs)
    opt.upper_bounds = collect(ubs)
    opt.xtol_rel = 1e-4
    opt.min_objective = nlopt_obj!

    min_obj, opt_x, status = optimize(opt, init_x)

    set_values!(inputs(P), opt_x)
    update_model!(P)

    return min_obj, status
end
