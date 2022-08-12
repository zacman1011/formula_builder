defmodule TokeniserTest do
  use ExUnit.Case
  doctest FormulaBuilder.Tokeniser

  alias FormulaBuilder.{Tokeniser}

  test "greets the world" do
    assert Tokeniser.build_tokens("hello world") == [{:variable, "hello"}, {:variable, "world"}]
  end

  test "number -- integer" do
    assert Tokeniser.build_tokens("1234") === [
      {:number, 1234}
    ]
  end

  test "number -- float" do
    assert Tokeniser.build_tokens("1234.0") === [
      {:number, 1234.0}
    ]
  end

  test "add two numbers" do
    assert Tokeniser.build_tokens("1.1+2") === [
      {:number, 1.1}, {:operation, "+"}, {:number, 2}
    ]
  end

  test "add variables" do
    assert Tokeniser.build_tokens("a+ hello") === [
      {:variable, "a"}, {:operation, "+"}, {:variable, "hello"}
    ]
  end

  test "and variables" do
    assert Tokeniser.build_tokens("a&&hello") === [
      {:variable, "a"}, {:operation, "&&"}, {:variable, "hello"}
    ]
  end

  test "add variables with parentheses" do
    assert Tokeniser.build_tokens("a+ (hello+world)") === [
      {:variable, "a"}, {:operation, "+"}, {:open_parentheses, "("}, {:variable, "hello"}, {:operation, "+"}, {:variable, "world"}, {:close_parentheses, ")"}
    ]
  end

  test "func on variables" do
    assert Tokeniser.build_tokens("min a b") === [
      {:function, "min"}, {:variable, "a"}, {:variable, "b"}
    ]
  end

  test "func on variables and parentheses" do
    assert Tokeniser.build_tokens("min a (b + 1)") === [
      {:function, "min"}, {:variable, "a"}, {:open_parentheses, "("}, {:variable, "b"}, {:operation, "+"}, {:number, 1}, {:close_parentheses, ")"}
    ]
  end

  test "test" do
    assert Tokeniser.build_tokens("min 1 (a - 2)") === [
      {:function, "min"}, {:number, 1}, {:open_parentheses, "("}, {:variable, "a"}, {:operation, "-"}, {:number, 2}, {:close_parentheses, ")"}
    ]
  end

  test "and two conditions" do
    assert Tokeniser.build_tokens("1.4==2 && 3.4==3.4") === [
      {:number, 1.4}, {:operation, "=="}, {:number, 2},
      {:operation, "&&"},
      {:number, 3.4}, {:operation, "=="}, {:number, 3.4}
    ]
  end

  test "parentheses - 1" do
    assert Tokeniser.build_tokens("(1+2)-(5*7)") === [
      {:open_parentheses, "("}, {:number, 1}, {:operation, "+"}, {:number, 2}, {:close_parentheses, ")"},
      {:operation, "-"},
      {:open_parentheses, "("}, {:number, 5}, {:operation, "*"}, {:number, 7}, {:close_parentheses, ")"}
    ]
  end

end
