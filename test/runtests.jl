using AxisArrays
using NLOptWrapper
using Test



@testset "basic_variables" begin
    x = Variable(1.0)

    set_min!(x, 2.0)
    @test x.min == 2.0

    set_max!(x, 3.0)
    @test x.max == 3.0

    set_bounds!(x, 4.0, 5.0)
    @test (x.min == 4.0) && (x.max == 5.0)

    @test length(NLOptWrapper.collect_variables(x; only_vary=true)) == 0

    set_vary!(x, true)
    @test (x.vary == true)

    @test length(NLOptWrapper.collect_variables(x; only_vary=true)) == 1
end

@testset "array_variables" begin
    x = array_variable(; x=[1, 2, 3], y=['a', 'b'])
    
    @test typeof(x) <: AxisArray{Variable}
    @test size(x) == (3, 2)

    set_min!.(x, Ref(1.0))
    @test all(map(y -> y.min, x) .== 1.0)

    set_vary!.(x[:, 'a'], Ref(true))
    @test length(NLOptWrapper.collect_variables(x; only_vary=true)) == 3
end

@testset "model_inputs" begin
    m = ModelInputs()

    x = scalar_variable()
    y = scalar_variable()

    add_function(m, InputFunction(x, identity))
    add_function(m, InputFunction(y, identity))

    @test m.variable_map[x] == 1
    @test m.variable_map[y] == 2
end

@testset "constraints" begin
    m = ModelInputs()

    x = scalar_variable()
    y = scalar_variable()

    add_function(m, InputFunction(x, identity))
    add_function(m, InputFunction(y, identity))

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
