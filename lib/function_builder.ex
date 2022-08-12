defmodule FormulaBuilder.FunctionBuilder do

  import FormulaBuilder.Operations
  import FormulaBuilder.Functions

  @operation_functions operation_functions()
  @functions functions()
  @function_arity function_arities()

  def build_function(rpn_tokens) do
    {func, []} = eval_rpn(rpn_tokens)
    func
  end

  defp eval_rpn([{:operation, op} | tokens]) do
    {func1, rem_tokens1} = eval_rpn(tokens)
    {func2, rem_tokens2} = eval_rpn(rem_tokens1)

    func = &(Map.get(@operation_functions, op).(func1, func2, &1))

    ##eval_rpn([{:built, func} | rem_tokens2])
    {func, rem_tokens2}
  end
  defp eval_rpn([{:function, function} | tokens]) do
    case Map.get(@function_arity, function) do
      1 ->
        {func1, rem_tokens1} = eval_rpn(tokens)

        func = &(Map.get(@functions, function).(func1, &1))

        {func, rem_tokens1}

      2 ->
        {func1, rem_tokens1} = eval_rpn(tokens)
        {func2, rem_tokens2} = eval_rpn(rem_tokens1)

        func = &(Map.get(@functions, function).(func1, func2, &1))

        {func, rem_tokens2}

      3 ->
        {func1, rem_tokens1} = eval_rpn(tokens)
        {func2, rem_tokens2} = eval_rpn(rem_tokens1)
        {func3, rem_tokens3} = eval_rpn(rem_tokens2)

        func = &(Map.get(@functions, function).(func1, func2, func3, &1))

        {func, rem_tokens3}
    end
  end
  defp eval_rpn([{:number, number} | tokens]) do
    func = &(FormulaBuilder.FunctionBuilder.number(number, &1))
    {func, tokens}
  end
  defp eval_rpn([{:variable, variable} | tokens]) do
    func = &(Map.get(&1, variable))
    {func, tokens}
  end

  def number(number, _), do: number


end
