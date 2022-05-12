mutable struct QuadraticModel <: NLoptWrapper.AbstractModel
    a :: Real
    b :: Real
    c :: Real
end
function evaluate(c :: QuadraticModel, x_vals :: Vector{<:Real})
    f(x) = c.a * x ^ 2 + c.b * x + c.c
    return f.(x_vals)
end
function NLoptWrapper.compute_loss(c :: QuadraticModel)
    ref_x = [1, 2, 3]

    true_model = QuadraticModel(1, 4, 2)
    true_points = evaluate(true_model, ref_x)

    computed_points = evaluate(c, ref_x)

    return sum(abs.(true_points .- computed_points))
end


@testset "quadratic_fit" begin
    m = ModelInputs()

    a = Variable(2.0, 0.0, 2.0, true)
    b = Variable(4.0)
    c = Variable(2.0)

    add_function!(m, InputFunction(a, (m, x) -> m.a = value(x)))
    add_function!(m, InputFunction(b, (m, x) -> m.b = value(x)))
    add_function!(m, InputFunction(c, (m, x) -> m.c = value(x)))

    model = QuadraticModel(0, 4, 2)
    prob = NLOptProblem(model, m)
    solve!(prob)

    @test isapprox(value(a), 1.0; atol=1e-3)
end
