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

  @use_decimal Application.compile_env(:formula_builder, [FormulaBuilder.Operations, :use_decimal], false)

  @boolean_operation_definitions %{
    "&&" => {1, &FormulaBuilder.Operations.and_func/3},
    "||" => {0, &FormulaBuilder.Operations.or_func/3}
  }

  ## banned_operations ".", 0-9, any letter
  @number_operation_definitions %{
    "+"  => {4, &FormulaBuilder.Operations.add/3},
    "-"  => {4, &FormulaBuilder.Operations.minus/3},
    "/"  => {5, &FormulaBuilder.Operations.divide/3},
    "*"  => {5, &FormulaBuilder.Operations.multiply/3},
    "%"  => {3, &FormulaBuilder.Operations.modulo/3},
    "//" => {5, &FormulaBuilder.Operations.integer_divide/3},
    "==" => {2, &FormulaBuilder.Operations.equals_func/3},
    "!=" => {2, &FormulaBuilder.Operations.not_equals_func/3},
    "<"  => {2, &FormulaBuilder.Operations.less_than_func/3},
    ">"  => {2, &FormulaBuilder.Operations.more_than_func/3},
    "<=" => {2, &FormulaBuilder.Operations.less_than_equal_to_func/3},
    ">=" => {2, &FormulaBuilder.Operations.more_than_equal_to_func/3}
  } |> Map.merge(@boolean_operation_definitions)

  @decimal_operation_definitions %{
    "+"  => {4, &FormulaBuilder.Operations.decimal_add/3},
    "-"  => {4, &FormulaBuilder.Operations.decimal_minus/3},
    "/"  => {5, &FormulaBuilder.Operations.decimal_divide/3},
    "*"  => {5, &FormulaBuilder.Operations.decimal_multiply/3},
    "%"  => {3, &FormulaBuilder.Operations.decimal_modulo/3},
    "//" => {5, &FormulaBuilder.Operations.decimal_integer_divide/3},
    "==" => {2, &FormulaBuilder.Operations.decimal_equals_func/3},
    "!=" => {2, &FormulaBuilder.Operations.decimal_not_equals_func/3},
    "<"  => {2, &FormulaBuilder.Operations.decimal_less_than_func/3},
    ">"  => {2, &FormulaBuilder.Operations.decimal_more_than_func/3},
    "<=" => {2, &FormulaBuilder.Operations.decimal_less_than_equal_to_func/3},
    ">=" => {2, &FormulaBuilder.Operations.decimal_more_than_equal_to_func/3}
  }|> Map.merge(@boolean_operation_definitions)

  @operation_definitions if @use_decimal, do: @decimal_operation_definitions, else: @number_operation_definitions

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


  ################################################################
  ##                                                            ##
  ##     Functions for operations using integers and floats     ##
  ##                                                            ##
  ################################################################

  @spec decimal_add(formula_function(), formula_function(), input_map()) :: any
  def decimal_add(a, b, map), do: Decimal.add(a.(map), b.(map))

  @spec decimal_minus(formula_function(), formula_function(), input_map()) :: any
  def decimal_minus(a, b, map), do: Decimal.sub(b.(map), a.(map))

  @spec decimal_divide(formula_function(), formula_function(), input_map()) :: any
  def decimal_divide(a, b, map), do: Decimal.div(a.(map), b.(map))

  @spec decimal_multiply(formula_function(), formula_function(), input_map()) :: any
  def decimal_multiply(a, b, map), do: Decimal.mult(a.(map), b.(map))

  @spec decimal_integer_divide(formula_function(), formula_function(), input_map()) :: any
  def decimal_integer_divide(a, b, map), do: Decimal.div_int(a.(map), b.(map))

  @spec decimal_modulo(formula_function(), formula_function(), input_map()) :: any
  def decimal_modulo(a, b, map), do: Decimal.rem(a.(map), b.(map))

  @spec decimal_equals_func(formula_function(), formula_function(), input_map()) :: any
  def decimal_equals_func(a, b, map), do: Decimal.compare(a.(map), b.(map)) == :eq

  @spec decimal_not_equals_func(formula_function(), formula_function(), input_map()) :: any
  def decimal_not_equals_func(a, b, map), do: Decimal.compare(a.(map), b.(map)) != :eq

  @spec decimal_less_than_func(formula_function(), formula_function(), input_map()) :: any
  def decimal_less_than_func(a, b, map), do: Decimal.compare(b.(map), a.(map)) == :lt

  @spec decimal_more_than_func(formula_function(), formula_function(), input_map()) :: any
  def decimal_more_than_func(a, b, map), do: Decimal.compare(b.(map), a.(map)) == :gt

  @spec decimal_less_than_equal_to_func(formula_function(), formula_function(), input_map()) :: any
  def decimal_less_than_equal_to_func(a, b, map), do: Decimal.compare(b.(map), a.(map)) != :gt

  @spec decimal_more_than_equal_to_func(formula_function(), formula_function(), input_map()) :: any
  def decimal_more_than_equal_to_func(a, b, map), do: Decimal.compare(b.(map), a.(map)) != :lt


  #####################################################
  ##                                                 ##
  ##     Functions for operations using Decimals     ##
  ##                                                 ##
  #####################################################

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


  ####################################################
  ##                                                ##
  ##     Functions for operations using boolean     ##
  ##                                                ##
  ####################################################

  @spec and_func(formula_function(), formula_function(), input_map()) :: any
  def and_func(a, b, map), do: a.(map) and b.(map)

  @spec or_func(formula_function(), formula_function(), input_map()) :: any
  def or_func(a, b, map), do: a.(map) or b.(map)

end
