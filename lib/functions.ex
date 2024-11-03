defmodule FormulaBuilder.Functions do

  @moduledoc """
    Defines the functions available for formulae to have, and adds config defined functions. Allowing user defined functions when using this application as a dependency.
    Every function can be used in the form ``` function_name (parameter1, parameter2) ```.
    Functions can have 1-3 parameters.

    The configuration function map passed in by a user must take the form
    ```
    %{
      function_name => {arity, function_pointer}
    }
    ```

    function_name :: String.t()
    arity :: 0 | 1 | 2 | 3
    function_pointer :: fun()

    The function pointer should point to a function that takes 1-3 other function pointers as a
  """

  alias FormulaBuilder.Types

  @config_functions Application.compile_env(:formula_builder, [FormulaBuilder.Functions, :functions], %{})

  @function_definitions %{
    "min"   => {2, &FormulaBuilder.Functions.min_func/3},
    "max"   => {2, &FormulaBuilder.Functions.max_func/3},
    "min3"  => {3, &FormulaBuilder.Functions.min3_func/4},
    "max3"  => {3, &FormulaBuilder.Functions.max3_func/4},
    "not"   => {1, &FormulaBuilder.Functions.not_func/2},
    "triad" => {3, &FormulaBuilder.Functions.triad_func/4},
    "neg"   => {1, &FormulaBuilder.Functions.neg_func/2},
    "abs"   => {1, &FormulaBuilder.Functions.abs_func/2}
  } |> Map.merge(@config_functions)

  @function_names Map.keys(@function_definitions)

  @functions Enum.into(@function_definitions, %{}, fn({f, {_, func}}) -> {f, func} end)

  @function_arities Enum.into(@function_definitions, %{}, fn({f, {arity, _}}) -> {f, arity} end)

  @doc """
    The names of the functions compiled and ready to be used in the formulae.
  """
  @spec function_names :: [String.t()]
  def function_names do
    @function_names
  end

  @doc """
    The functions compiled and ready to be used in the formulae as a map of function name to function.
  """
  @spec functions :: %{String.t() => fun()}
  def functions do
    @functions
  end

  @doc """
    The function arities compiled and ready to be used in the formulae as a map of function name to arity.
  """
  @spec function_arities :: %{String.t() => Types.formula_function_arity()}
  def function_arities do
    @function_arities
  end

  @doc """
    Returns the min of the two Decimal parameters
  """
  @spec min_func(Types.formula_function(), Types.formula_function(), Types.input_map()) :: Decimal.t()
  def min_func(a, b, map), do: Decimal.min(a.(map), b.(map))

  @doc """
    Returns the max of the two Decimal parameters
  """
  @spec max_func(Types.formula_function(), Types.formula_function(), Types.input_map()) :: Decimal.t()
  def max_func(a, b, map), do: Decimal.max(a.(map), b.(map))

  @doc """
    Returns the min of the three Decimal parameters
  """
  @spec min3_func(Types.formula_function(), Types.formula_function(), Types.formula_function(), Types.input_map()) :: Decimal.t()
  def min3_func(a, b, c, map), do: Decimal.min(Decimal.min(a.(map), b.(map)), c.(map))

  @doc """
    Returns the max of the three Decimal parameters
  """
  @spec max3_func(Types.formula_function(), Types.formula_function(), Types.formula_function(), Types.input_map()) :: Decimal.t()
  def max3_func(a, b, c, map), do: Decimal.max(Decimal.max(a.(map), b.(map)), c.(map))

  @doc """
    Returns the not of the parameter
  """
  @spec not_func(Types.formula_function(), Types.input_map()) :: boolean()
  def not_func(a, map), do: not a.(map)

  @doc """
    Returns the total of the three Decimal parameters
  """
  @spec triad_func(Types.formula_function(), Types.formula_function(), Types.formula_function(), Types.input_map()) :: Decimal.t()
  def triad_func(a, b, c, map), do: Decimal.add(a.(map), b.(map)) |> Decimal.add(c.(map))

  @doc """
    Returns the negated value of the Decimal parameter
  """
  @spec neg_func(Types.formula_function(), Types.input_map()) :: Decimal.t()
  def neg_func(a, map), do: Decimal.negate(a.(map))

  @doc """
    Returns the absolute of the Decimal parameter
  """
  @spec abs_func(Types.formula_function(), Types.input_map()) :: Decimal.t()
  def abs_func(a, map), do: Decimal.abs(a.(map))

end
