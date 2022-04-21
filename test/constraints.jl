@testset "constraints" begin
    m = ModelInputs()

    x = Variable(0.0)
    y = Variable(0.0)

    add_function!(m, InputFunction(x, identity))
    add_function!(m, InputFunction(y, identity))

    con = SumEqualsConstraint([x, y], 1.0)
    f = NLOptWrapper.build_function(m.variable_map, con)

    @test f([1, 2]) == 2
    @test f([1, 0]) == 0
    @test f([0, 0]) == -1

    con = LessEqualConstraint([x], [y])
    f = NLOptWrapper.build_function(m.variable_map, con)

    @test f([1, 2]) == -1
    @test f([1, 0]) == 1
    @test f([0, 0]) == 0
end
