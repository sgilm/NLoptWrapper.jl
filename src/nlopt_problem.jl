export NLoptProblem
export model, inputs
export update_model!
export solve!


struct NLoptProblem
    model :: AbstractModel
    inputs :: ModelInputs
end
model(P :: NLoptProblem) = P.model
inputs(P :: NLoptProblem) = P.inputs

function compute_loss(:: NLoptProblem) end

function update_model!(P :: NLoptProblem)
    for i in input_functions(inputs(P))
        apply!(model(P), i)
    end
end

function build_apply_function(P :: NLoptProblem)

    vary_vars, functions_to_apply = collect_vary_variables(inputs(P))

    function apply_function!(x :: Vector)
        for (i, v) in enumerate(vary_vars)
            # var_idx = variable_map(inputs(P))[v]
            set_value!(v, x[i])
        end
        for i in functions_to_apply
            apply!(model(P), i)
        end
    end

    return apply_function!, length(vary_vars)
end

function solve!(P :: NLoptProblem; max_evals=max_evals)

    update_model!(P)
    apply_function!, n = build_apply_function(P)
    
    eval_count = 0
    function nlopt_obj!(x :: Vector, :: Any)
        
        # Wrap in try/catch to return any errors from the model function.
        try
        
            # Update the model, then compute the loss.
            apply_function!(x)
            loss = compute_loss(P)
            eval_count += 1

            if eval_count % (max_evals ÷ 10) == 1
                @info "$eval_count evaluation(s): objective = $loss"
            end
            
            return loss

        catch e
            bt = catch_backtrace()
            showerror(stdout, e, bt)
            rethrow(e)
        end
    end

    lbs, ubs = get_bounds(inputs(P))
    init_x = get_values(inputs(P))

    opt = Opt(:LN_BOBYQA, n)
    opt.lower_bounds = collect(lbs)
    opt.upper_bounds = collect(ubs)
    opt.xtol_rel = 1e-4
    opt.min_objective = nlopt_obj!
    opt.maxeval = max_evals

    min_obj, opt_x, status = optimize(opt, init_x)

    set_values!(inputs(P), opt_x)
    update_model!(P)

    return min_obj, status
end
