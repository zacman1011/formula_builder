defmodule FormulaBuilder.Operations do

  @moduledoc """
    Defines the operations available for formulae to have.
    Every operation is a binary infix operation.
  """

  alias FormulaBuilder.Types

  @type input_map :: Types.input_map()
  @type formula_function :: Types.formula_function()
  @type formula_function_arity :: Types.formula_function_arity()
  @type operation_precedence :: Types.operation_precedence()

  ## banned_operations ".", 0-9, any letter
  @operation_definitions %{
    "+"  => {4, &FormulaBuilder.Operations.add/3},
    "-"  => {4, &FormulaBuilder.Operations.minus/3},
    "/"  => {5, &FormulaBuilder.Operations.divide/3},
    "*"  => {5, &FormulaBuilder.Operations.multiply/3},
    "%"  => {3, &FormulaBuilder.Operations.modulo/3},
    "//" => {5, &FormulaBuilder.Operations.integer_divide/3},
    "&&" => {1, &FormulaBuilder.Operations.and_func/3},
    "||" => {0, &FormulaBuilder.Operations.or_func/3},
    "==" => {2, &FormulaBuilder.Operations.equals_func/3},
    "!=" => {2, &FormulaBuilder.Operations.not_equals_func/3},
    "<"  => {2, &FormulaBuilder.Operations.less_than_func/3},
    ">"  => {2, &FormulaBuilder.Operations.more_than_func/3},
    "<=" => {2, &FormulaBuilder.Operations.less_than_equal_to_func/3},
    ">=" => {2, &FormulaBuilder.Operations.more_than_equal_to_func/3}
  }

  @operations Map.keys(@operation_definitions)

  @operation_functions Enum.into(@operation_definitions, %{}, fn({f, {_, func}}) -> {f, func} end)

  @operation_precedence Enum.into(@operation_definitions, %{}, fn({f, {arity, _}}) -> {f, arity} end)

  @spec operations :: [String.t()]
  def operations do
    @operations
  end

  @spec operation_functions :: %{optional(String.t()) => fun}
  def operation_functions do
    @operation_functions
  end

  @spec operation_precedence :: %{optional(nonempty_binary) => operation_precedence()}
  def operation_precedence do
    @operation_precedence
  end

  @spec add(formula_function(), formula_function(), input_map()) :: any
  def add(a, b, map), do: a.(map) + b.(map)

  @spec minus(formula_function(), formula_function(), input_map()) :: any
  def minus(a, b, map), do: b.(map) - a.(map)

  @spec divide(formula_function(), formula_function(), input_map()) :: any
  def divide(a, b, map), do: a.(map) / b.(map)

  @spec multiply(formula_function(), formula_function(), input_map()) :: any
  def multiply(a, b, map), do: a.(map) * b.(map)

  @spec integer_divide(formula_function(), formula_function(), input_map()) :: any
  def integer_divide(a, b, map), do: div(a.(map), b.(map))

  @spec modulo(formula_function(), formula_function(), input_map()) :: any
  def modulo(a, b, map), do: rem(a.(map), b.(map))

  @spec and_func(formula_function(), formula_function(), input_map()) :: any
  def and_func(a, b, map), do: a.(map) and b.(map)

  @spec or_func(formula_function(), formula_function(), input_map()) :: any
  def or_func(a, b, map), do: a.(map) or b.(map)

  @spec equals_func(formula_function(), formula_function(), input_map()) :: any
  def equals_func(a, b, map), do: a.(map) == b.(map)

  @spec not_equals_func(formula_function(), formula_function(), input_map()) :: any
  def not_equals_func(a, b, map), do: a.(map) != b.(map)

  @spec less_than_func(formula_function(), formula_function(), input_map()) :: any
  def less_than_func(a, b, map), do: a.(map) > b.(map)

  @spec more_than_func(formula_function(), formula_function(), input_map()) :: any
  def more_than_func(a, b, map), do: a.(map) < b.(map)

  @spec less_than_equal_to_func(formula_function(), formula_function(), input_map()) :: any
  def less_than_equal_to_func(a, b, map), do: a.(map) >= b.(map)

  @spec more_than_equal_to_func(formula_function(), formula_function(), input_map()) :: any
  def more_than_equal_to_func(a, b, map), do: a.(map) <= b.(map)

end
