defmodule FormulaBuilder.Functions do

  @function_names ["min", "max", "not", "triad"]

  @functions %{
    "min" => &FormulaBuilder.Functions.min_func/3,
    "max" => &FormulaBuilder.Functions.max_func/3,
    "not" => &FormulaBuilder.Functions.not_func/2,
    "triad" => &FormulaBuilder.Functions.triad_func/4
  }

  @function_arities %{
    "min" => 2,
    "max" => 2,
    "not" => 1,
    "triad" => 3
  }

  def function_names do
    @function_names
  end

  def functions do
    @functions
  end

  def function_arities do
    @function_arities
  end

  def min_func(a, b, map), do: min(a.(map), b.(map))
  def max_func(a, b, map), do: max(a.(map), b.(map))
  def not_func(a, map), do: not a.(map)
  def triad_func(a, b, c, map), do: a.(map) + b.(map) + c.(map)

end
