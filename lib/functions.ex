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

  @type input_map :: Types.input_map()
  @type formula_function :: Types.formula_function()
  @type formula_function_arity :: Types.formula_function_arity()

  @config_functions Application.compile_env(:formula_builder, [FormulaBuilder.Functions, :functions], %{})

  @function_definitions %{
    "min"   => {2, &FormulaBuilder.Functions.min_func/3},
    "max"   => {2, &FormulaBuilder.Functions.max_func/3},
    "not"   => {1, &FormulaBuilder.Functions.not_func/2},
    "triad" => {3, &FormulaBuilder.Functions.triad_func/4}
  } |> Map.merge(@config_functions)

  @function_names Map.keys(@function_definitions)

  @functions Enum.into(@function_definitions, %{}, fn({f, {_, func}}) -> {f, func} end)

  @function_arities Enum.into(@function_definitions, %{}, fn({f, {arity, _}}) -> {f, arity} end)

  @spec function_names :: [String.t()]
  def function_names do
    @function_names
  end

  @spec functions :: %{optional(String.t()) => fun}
  def functions do
    @functions
  end

  @spec function_arities :: %{optional(String.t()) => formula_function_arity()}
  def function_arities do
    @function_arities
  end

  @spec min_func(formula_function(), formula_function(), input_map()) :: any
  def min_func(a, b, map), do: Decimal.min(a.(map), b.(map))

  @spec max_func(formula_function(), formula_function(), input_map()) :: any
  def max_func(a, b, map), do: Decimal.max(a.(map), b.(map))

  @spec not_func(formula_function(), input_map()) :: any
  def not_func(a, map), do: not a.(map)

  @spec triad_func(formula_function(), formula_function(), formula_function(), input_map()) :: any
  def triad_func(a, b, c, map), do: Decimal.add(a.(map), b.(map)) |> Decimal.add(c.(map))

end
