defmodule RpnTest do
  use ExUnit.Case
  doctest FormulaBuilder.Rpn

  alias FormulaBuilder.{Rpn}

  test "number -- integer" do
    assert Rpn.rpn([{:number, 1234}]) === [{:number, 1234}]
  end

  test "number -- float" do
    assert Rpn.rpn([{:number, 1234.0}]) === [{:number, 1234.0}]
  end

  test "add two numbers" do
    tokens = [{:number, 1.1}, {:operation, "+"}, {:number, 2}]
    assert Rpn.rpn(tokens) === [{:number, 1.1}, {:number, 2}, {:operation, "+"}]
  end

  test "and two conditions" do
    tokens = [
      {:number, 1.4}, {:operation, "=="}, {:number, 2},
      {:operation, "&&"},
      {:number, 3.4}, {:operation, "=="}, {:number, 3.4}
    ]
    assert Rpn.rpn(tokens) === [
      {:number, 1.4}, {:number, 2}, {:operation, "=="},
      {:number, 3.4}, {:number, 3.4}, {:operation, "=="},
      {:operation, "&&"}
    ]
  end

  test "parentheses - 1" do
    tokens = [
      {:open_parentheses, "("}, {:number, 1}, {:operation, "+"}, {:number, 2}, {:close_parentheses, ")"},
      {:operation, "-"},
      {:open_parentheses, "("}, {:number, 5}, {:operation, "*"}, {:number, 7}, {:close_parentheses, ")"}
    ]
    assert Rpn.rpn(tokens) === [
      {:number, 1}, {:number, 2}, {:operation, "+"},
      {:number, 5}, {:number, 7}, {:operation, "*"},
      {:operation, "-"}
    ]
  end

end
