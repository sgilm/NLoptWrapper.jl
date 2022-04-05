export InputFunction


struct InputFunction
    variables :: VariableContainer
    func :: Function
end
variables(i :: InputFunction) = i.variables
func(i :: InputFunction) = i.func
