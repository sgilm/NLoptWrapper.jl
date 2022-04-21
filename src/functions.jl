export InputFunction
export apply!


struct InputFunction
    variables :: VariableContainer
    func :: Function
end
variables(i :: InputFunction) = i.variables
func(i :: InputFunction) = i.func

function apply!(a :: AbstractModel, i :: InputFunction)
    func(i)(a, variables(i))
end
