defmodule FormulaBuilder.FunctionBuilder do

  @moduledoc """
    Responsible for turning a list of tokens in the RPN form into one function that takes a map of variables to values.
  """

  import FormulaBuilder.Operations
  import FormulaBuilder.Functions

  alias FormulaBuilder.Types

  require Logger

  @operation_functions operation_functions()
  @functions functions()
  @function_arity function_arities()

  @doc """
    Builds the function that takes a map of variables and returns a value.
    Input is a list of tokens in RPN.
    Output is a function pointer with arity 1.
  """
  @spec build_function(:error | [Types.token()]) :: :error | Types.formula_function()
  def build_function(rpn_tokens)
  def build_function(:error), do: :error
  def build_function(rpn_tokens) do
    {func, []} = eval_rpn(rpn_tokens)

    &(safety_wrapper(func, &1))
  end

  defp eval_rpn([{:operation, op} | tokens]) do
    ## currently all operations are arity 2
    ## func1 and func2 are the functions that represent the two parameters of the operation that are invoked to get the values
    {func1, rem_tokens1} = eval_rpn(tokens)
    {func2, rem_tokens2} = eval_rpn(rem_tokens1)

    func = &(Map.get(@operation_functions, op).(func1, func2, &1))

    {func, rem_tokens2}
  end
  defp eval_rpn([{:function, function} | tokens]) do
    ## functions can have arity 0-3 as it stands and the function build_inbuilt_function/3 deals with making them
    arity = Map.get(@function_arity, function)
    build_inbuilt_function(arity, function, tokens)
  end
  defp eval_rpn([{:number, number} | tokens]) do
    ## a number still requires a function to be invoked so that other functions in the build are naive to the type of parameters they have
    ## this function simply returns the number and ignores the map provided
    func = fn(_) -> variable(number) end
    {func, tokens}
  end
  defp eval_rpn([{:boolean, bool} | tokens]) do
    ## same as the number case above
    ## can use the number function here as it will pass through to the final case and just return the boolean value itself
    func = fn(_) -> variable(bool) end
    {func, tokens}
  end
  defp eval_rpn([{:variable, variable} | tokens]) do
    ## provides a function that gets the variable from the function-provided map and converts it to the correct value type
    func = &(Map.get(&1, variable) |> variable())
    {func, tokens}
  end
  defp eval_rpn([{:atom, atom} | tokens]) do
    ## provides a function that returns the atom
    func = fn(_) -> atom end
    {func, tokens}
  end
  defp eval_rpn([{:if, condition, true_clause, elifs_else} | tokens]) do
    ## deals with each clause of the if block as a separate function
    condition_func = build_function(condition)
    true_clause_func = build_function(true_clause)
    elifs_else_funcs = Enum.map(elifs_else, &build_function/1)

    ## executes as an if block
    func = &(if_block(condition_func, true_clause_func, elifs_else_funcs, &1))
    {func, tokens}
  end
  defp eval_rpn([{:tuple, elements} | tokens]) do
    element_funcs = create_tuple_elements(elements)
    func = &(tuple_func(element_funcs, &1))
    {func, tokens}
  end

  @doc """
    If a variable is a bool then it is returned as a bool, if its a number then it is converted to a Decimal.t().
  """
  @spec variable(any()) :: Types.formula_function_return()
  def variable(variable)
  def variable(bool) when is_boolean(bool),     do: bool
  def variable(number) when is_integer(number), do: Decimal.new(number)
  def variable(number) when is_float(number),   do: Decimal.from_float(number)
  def variable(other), do: other

  defp create_tuple_elements(elements, acc \\ []) do
    case eval_rpn(elements) do
      {func, []} ->
        [func | acc]

      {func, remaining} ->
        create_tuple_elements(remaining, [func | acc])
    end
  end

  @doc """
    Executes an if block from the formula. Does so in a way that means only the clause necessary is executed.
  """
  @spec if_block(Types.formula_function(), Types.formula_function(), [Types.formula_function()], Types.input_map()) :: Types.formula_function_return()
  def if_block(condition, true_clause, elifs_else, map) do
    if condition.(map) do
      true_clause.(map)
    else
      execute_elifs_else(elifs_else, map)
    end
  end

  defp execute_elifs_else([condition, clause | rest], map) do
    if condition.(map) do
      clause.(map)
    else
      execute_elifs_else(rest, map)
    end
  end
  defp execute_elifs_else([false_clause], map) do
    false_clause.(map)
  end

  @doc """
    Executes a tuple's elements individually and returns a tuple of the size of the elements
  """
  @spec tuple_func([Types.formula_function()], Types.input_map()) :: Types.formula_function_return()
  def tuple_func(element_funcs, map) do
    element_funcs
    |> Enum.map(&(&1.(map)))
    |> List.to_tuple()
  end

  defp build_inbuilt_function(arity, function, tokens) do
    ## recursively get each parameter and evaluate it into a function that can be invoked for its value
    {rem_tokens, functions} = do_build_inbuilt_function(arity, tokens, [])

    ## Have not thought of a way to metacode this yet - there are plenty of tests so try anything out
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

  @doc """
    Returns false in error case so that if this function return is used in an if statement it does not consider the answer as true
  """
  @spec safety_wrapper(Types.formula_function(), Types.input_map()) :: Types.formula_function_return()
  def safety_wrapper(func, map) do
    try do
      func.(map)

    rescue
      err ->
        "Formula has crashed: #{Exception.format(:error, err, __STACKTRACE__)} with map input: #{inspect map}."
        |> Logger.error()
        false

    catch
      err ->
        "Formula has crashed: #{Exception.format(:error, err, __STACKTRACE__)} with map input: #{inspect map}."
        |> Logger.error()
        false
    end
  end
end
