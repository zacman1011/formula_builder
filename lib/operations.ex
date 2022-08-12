defmodule FormulaBuilder.Operations do

  ## banned_operations ".", 0-9, any letter
  @operations ["+", "-", "/", "*", "%", "//", "&&", "||", "==", "!="]

  @operation_functions %{
    "+" => &FormulaBuilder.Operations.add/3,
    "-" => &FormulaBuilder.Operations.minus/3,
    "/" => &FormulaBuilder.Operations.divide/3,
    "*" => &FormulaBuilder.Operations.multiply/3,
    "%" => &FormulaBuilder.Operations.modulo/3,
    "//" => &FormulaBuilder.Operations.integer_divide/3,
    "&&" => &FormulaBuilder.Operations.and_func/3,
    "||" => &FormulaBuilder.Operations.or_func/3,
    "==" => &FormulaBuilder.Operations.equals_func/3,
    "!=" => &FormulaBuilder.Operations.not_equals_func/3
  }

  @operation_precedence %{
    "||" => 0,
    "&&" => 1,
    "==" => 2,
    "!=" => 2,
    "%"  => 3,
    "+"  => 4,
    "-"  => 4,
    "/"  => 5,
    "*"  => 5,
    "//" => 5,
  }

  def operations do
    @operations
  end

  def operation_functions do
    @operation_functions
  end

  def operation_precedence do
    @operation_precedence
  end

  def add(a, b, map), do: a.(map) + b.(map)
  def minus(a, b, map), do: b.(map) - a.(map)
  def divide(a, b, map), do: a.(map) / b.(map)
  def multiply(a, b, map), do: a.(map) * b.(map)
  def integer_divide(a, b, map), do: div(a.(map), b.(map))
  def modulo(a, b, map), do: rem(a.(map), b.(map))
  def and_func(a, b, map), do: a.(map) and b.(map)
  def or_func(a, b, map), do: a.(map) or b.(map)
  def equals_func(a, b, map), do: a.(map) == b.(map)
  def not_equals_func(a, b, map), do: a.(map) != b.(map)

end
