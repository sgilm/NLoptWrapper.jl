@testset "model_inputs" begin
    m = ModelInputs()

    x = Variable(0.0)
    y = Variable(0.0)

    add_function!(m, InputFunction(x, identity))
    add_function!(m, InputFunction(y, identity))

    @test m.variable_map[x] == 1
    @test m.variable_map[y] == 2
end
