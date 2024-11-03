defmodule FormulaBuilder.TestFormulaeFunctions do

  @moduledoc false

  def sub_func(a, b, map) do
    Decimal.sub(a.(map), b.(map))
  end

  def zero_func(_map) do
    Decimal.new(0)
  end

  def thrower_func(_map) do
    throw({:test_error, "This is a test error"})
  end

end
