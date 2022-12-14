defmodule FormulaBuilder.FunctionBuilder do

  @moduledoc """
    Responsible for turning a list of tokens in the RPN form into one function that takes a map of variables to values
  """

  import FormulaBuilder.Operations
  import FormulaBuilder.Functions

  alias FormulaBuilder.Types

  @type token() :: Types.token()
  @type formula_function :: Types.formula_function()

  @operation_functions operation_functions()
  @functions functions()
  @function_arity function_arities()

  @doc """
    Builds the function that takes a map of variables and returns a value.
    Input is a list of tokens in RPN.
    Output is a function pointer with arity 1.
  """
  @spec build_function(:error | [token()]) :: :error | formula_function()
  def build_function(rpn_tokens)
  def build_function(:error), do: :error
  def build_function(rpn_tokens) do
    {func, []} = eval_rpn(rpn_tokens)
    func
  end

  defp eval_rpn([{:operation, op} | tokens]) do
    {func1, rem_tokens1} = eval_rpn(tokens)
    {func2, rem_tokens2} = eval_rpn(rem_tokens1)

    func = &(Map.get(@operation_functions, op).(func1, func2, &1))

    {func, rem_tokens2}
  end
  defp eval_rpn([{:function, function} | tokens]) do
    arity = Map.get(@function_arity, function)
    build_inbuilt_function(arity, function, tokens)
  end
  defp eval_rpn([{:number, number} | tokens]) do
    func = &(FormulaBuilder.FunctionBuilder.number(number, &1))
    {func, tokens}
  end
  defp eval_rpn([{:boolean, boolean} | tokens]) do
    func = &(FormulaBuilder.FunctionBuilder.number(boolean, &1))
    {func, tokens}
  end
  defp eval_rpn([{:variable, variable} | tokens]) do
    func = &(Map.get(&1, variable) |> variable())
    {func, tokens}
  end
  defp eval_rpn([{:if, condition, true_clause, false_clause} | tokens]) do
    condition_func = build_function(condition)
    true_clause_func = build_function(true_clause)
    false_clause_func = build_function(false_clause)

    func = &(FormulaBuilder.FunctionBuilder.if_block(condition_func, true_clause_func, false_clause_func, &1))
    {func, tokens}
  end

  def number(number, _) when is_integer(number), do: Decimal.new(number)
  def number(number, _) when is_float(number), do: Decimal.from_float(number)
  def number(number, _), do: number ## assuming Decimal.t() or boolean

  def variable(bool) when is_boolean(bool), do: bool
  def variable(number), do: number(number, nil)

  def if_block(condition, true_clause, false_clause, map) do
    if condition.(map) do
      true_clause.(map)
    else
      false_clause.(map)
    end
  end

  defp build_inbuilt_function(arity, function, tokens) do
    {rem_tokens, functions} = do_build_inbuilt_function(arity, tokens, [])
    functions = Enum.reverse(functions)

    func = case arity do
      0 -> &(Map.get(@functions, function).(&1))
      1 -> &(Map.get(@functions, function).(Enum.at(functions, 0), &1))
      2 -> &(Map.get(@functions, function).(Enum.at(functions, 0), Enum.at(functions, 1), &1))
      3 -> &(Map.get(@functions, function).(Enum.at(functions, 0), Enum.at(functions, 1), Enum.at(functions, 2), &1))
    end

    {func, rem_tokens}
  end

  defp do_build_inbuilt_function(0, tokens, functions), do: {tokens, functions}
  defp do_build_inbuilt_function(counter, tokens, functions) do
    {func, rem_tokens} = eval_rpn(tokens)

    do_build_inbuilt_function(counter-1, rem_tokens, [func | functions])
  end
end
