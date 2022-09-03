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

  test "minus a number from another" do
    func = FormulaBuilder.build_formula("5 - 2")

    assert func.(%{}) == 3
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

  test "contract comparison" do
    func = FormulaBuilder.build_formula("c1 - c2 < 50")

    assert func.(%{"c1" => 80, "c2" => 50}) == true
  end

  test "if block simple" do
    func = FormulaBuilder.build_formula("if cond do c+1 else d + 3 end")

    assert func.(%{"cond" => true, "c" => 1, "d" => 10}) == 2
    assert func.(%{"cond" => false, "c" => 1, "d" => 10}) == 13
  end

end
