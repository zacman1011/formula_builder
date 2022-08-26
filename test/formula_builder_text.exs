defmodule FormulaBuilderTest do
  use ExUnit.Case
  doctest FormulaBuilder

  test "number -- integer" do
    func = FormulaBuilder.build_formula("1234")

    assert func.(%{}) == 1234
  end

  test "variable" do
    func = FormulaBuilder.build_formula("a")

    assert func.(%{"a" => 2}) == 2
  end

  test "variable plus decimal" do
    func = FormulaBuilder.build_formula("a + 1.2")

    assert func.(%{"a" => 2}) == 3.2
  end

  test "triad with variable and number and decimal" do
    func = FormulaBuilder.build_formula("triad a 2 1.2")

    assert func.(%{"a" => 2}) == 5.2
  end

  test "triad with variable and number and decimal with function parentheses" do
    func = FormulaBuilder.build_formula("triad( a 2 1.2 )")

    assert func.(%{"a" => 2}) == 5.2
  end

end
