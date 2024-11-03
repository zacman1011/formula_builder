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

  test "two booleans and" do
    assert Rpn.rpn([{:boolean, true}, {:boolean, false}, {:operation, "&&"}]) === [
      {:operation, "&&"}, {:boolean, false}, {:boolean, true}
    ]
  end

  test "add two numbers" do
    tokens = [{:number, 1.1}, {:operation, "+"}, {:number, 2}]
    assert Rpn.rpn(tokens) === [{:operation, "+"}, {:number, 2}, {:number, 1.1}]
  end

  test "minus two numbers" do
    tokens = [
      {:number, 1.1}, {:operation, "-"}, {:number, 2}
    ]

    assert Rpn.rpn(tokens) === [
      {:operation, "-"}, {:number, 2}, {:number, 1.1}
    ]
  end

  test "multiply two numbers" do
    tokens = [
      {:number, 1.1}, {:operation, "*"}, {:number, 2}
    ]

    assert Rpn.rpn(tokens) === [
      {:operation, "*"}, {:number, 2}, {:number, 1.1}
    ]
  end

  test "divide two numbers" do
    tokens = [
      {:number, 1.1}, {:operation, "/"}, {:number, 2}
    ]

    assert Rpn.rpn(tokens) === [
      {:operation, "/"}, {:number, 2}, {:number, 1.1}
    ]
  end

  test "integer divide two numbers" do
    tokens = [
      {:number, 1.1}, {:operation, "//"}, {:number, 2}
    ]

    assert Rpn.rpn(tokens) === [
      {:operation, "//"}, {:number, 2}, {:number, 1.1}
    ]
  end

  test "modulo two numbers" do
    tokens = [
      {:number, 1.1}, {:operation, "%"}, {:number, 2}
    ]

    assert Rpn.rpn(tokens) === [
      {:operation, "%"}, {:number, 2}, {:number, 1.1}
    ]
  end

  test "equals test two numbers" do
    tokens = [
      {:number, 1.1}, {:operation, "=="}, {:number, 2}
    ]

    assert Rpn.rpn(tokens) === [
      {:operation, "=="}, {:number, 2}, {:number, 1.1}
    ]
  end

  test "less than two numbers" do
    tokens = [
      {:number, 1.1}, {:operation, "<"}, {:number, 2}
    ]

    assert Rpn.rpn(tokens) === [
      {:operation, "<"}, {:number, 2}, {:number, 1.1}
    ]
  end

  test "greater than two numbers" do
    tokens = [
      {:number, 1.1}, {:operation, ">"}, {:number, 2}
    ]

    assert Rpn.rpn(tokens) === [
      {:operation, ">"}, {:number, 2}, {:number, 1.1}
    ]
  end

  test "less than or equal to two numbers" do
    tokens = [
      {:number, 1.1}, {:operation, "<="}, {:number, 2}
    ]

    assert Rpn.rpn(tokens) === [
      {:operation, "<="}, {:number, 2}, {:number, 1.1}
    ]
  end

  test "more than or equal to two numbers" do
    tokens = [
      {:number, 1.1}, {:operation, ">="}, {:number, 2}
    ]

    assert Rpn.rpn(tokens) === [
      {:operation, ">="}, {:number, 2}, {:number, 1.1}
    ]
  end

  test "minus a number from another" do
    tokens = [{:number, 1.1}, {:operation, "-"}, {:number, 2}]
    assert Rpn.rpn(tokens) === [{:operation, "-"}, {:number, 2}, {:number, 1.1}]
  end

  test "and two conditions" do
    tokens = [
      {:number, 1.4}, {:operation, "=="}, {:number, 2},
      {:operation, "&&"},
      {:number, 3.4}, {:operation, "=="}, {:number, 3.4}
    ]
    assert Rpn.rpn(tokens) === [
      {:operation, "&&"},
      {:operation, "=="}, {:number, 3.4}, {:number, 3.4},
      {:operation, "=="}, {:number, 2}, {:number, 1.4}
    ]
  end

  test "parentheses - 1" do
    tokens = [
      :open_parentheses, {:number, 1}, {:operation, "+"}, {:number, 2}, :close_parentheses,
      {:operation, "-"},
      :open_parentheses, {:number, 5}, {:operation, "*"}, {:number, 7}, :close_parentheses
    ]
    assert Rpn.rpn(tokens) === [
      {:operation, "-"},
      {:operation, "*"}, {:number, 7}, {:number, 5},
      {:operation, "+"}, {:number, 2}, {:number, 1}
    ]
  end

  test "contract comparison" do
    tokens = [
      {:variable, "c1"}, {:operation, "-"}, {:variable, "c2"},
      {:operation, "<"},
      {:number, 50}
    ]

    assert Rpn.rpn(tokens) === [
      {:operation, "<"},
      {:number, 50},
      {:operation, "-"}, {:variable, "c2"}, {:variable, "c1"}
    ]
  end

  test "if block simple" do
    tokens = [
      {
        :if,
        [{:variable, "true"}],
        [{:variable, "c"}, {:operation, "+"}, {:number, 1}],
        [[{:variable, "d"}, {:operation, "+"}, {:number, 3}]]
      }
    ]

    assert Rpn.rpn(tokens) === [
      {
        :if,
        [{:variable, "true"}],
        [{:operation, "+"}, {:number, 1}, {:variable, "c"}],
        [[{:operation, "+"}, {:number, 3}, {:variable, "d"}]]
      }
    ]
  end

  test "min func" do
    tokens = [
      {:function, "min"}, {:variable, "a"}, {:variable, "b"}
    ]

    assert Rpn.rpn(tokens) === [
      {:function, "min"}, {:variable, "b"}, {:variable, "a"}
    ]
  end

  test "max func" do
    tokens = [
      {:function, "max"}, {:variable, "a"}, {:variable, "b"}
    ]

    assert Rpn.rpn(tokens) === [
      {:function, "max"}, {:variable, "b"}, {:variable, "a"}
    ]
  end

  test "not func" do
    tokens = [
      {:function, "not"}, {:variable, "a"}
    ]

    assert Rpn.rpn(tokens) === [
      {:function, "not"}, {:variable, "a"}
    ]
  end

  test "triad func" do
    tokens = [
      {:function, "triad"}, {:variable, "a"}, {:variable, "b"}, {:variable, "c"}
    ]

    assert Rpn.rpn(tokens) === [
      {:function, "triad"}, {:variable, "c"}, {:variable, "b"}, {:variable, "a"}
    ]
  end

  test "receives :error" do
    assert Rpn.rpn(:error) == :error
  end

  test "close_parentheses with no open is ignored" do
    assert Rpn.rpn([:close_parentheses]) === []

    tokens = [
      {:number, 1}, {:operation, "+"}, {:number, 1}, :close_parentheses
    ]

    assert Rpn.rpn(tokens) === [{:operation, "+"}, {:number, 1}, {:number, 1}]
  end

  test "function with brackets" do
    tokens = [
      {:function, "min"}, :open_parentheses, {:number, 1}, {:number, 2}, :close_parentheses
    ]

    assert Rpn.rpn(tokens) == [
      {:function, "min"}, {:number, 2}, {:number, 1}
    ]
  end

  test "Zero args function used with operation" do
    tokens = [
      {:function, "zero"}, {:operation, "+"}, {:number, 1}
    ]

    assert Rpn.rpn(tokens) == [
      {:operation, "+"}, {:number, 1}, {:function, "zero"}
    ]
  end

  test "Simple tuple" do
    tokens = [
      {:tuple, [{:number, 1}, {:number, 2}]}
    ]

    assert Rpn.rpn(tokens) == [
      {:tuple, [{:number, 2}, {:number, 1}]}
    ]
  end

  test "Tuple of multiple types" do
    tokens = [
      {:tuple, [
        {:number, 1},
        {:number, 1.1},
        {:variable, "var"},
        {:function, "min"}, :open_parentheses, {:number, 1}, {:number, 2}, :close_parentheses,
        {:atom, :atom}
      ]}
    ]

    assert Rpn.rpn(tokens) == [
      {:tuple, [
        {:atom, :atom},
        {:function, "min"}, {:number, 2}, {:number, 1},
        {:variable, "var"},
        {:number, 1.1},
        {:number, 1}
      ]}
    ]
  end

  test "Tuple with functions" do
    tokens = [
      {:tuple, [
        {:function, "min"}, :open_parentheses, {:number, 1}, {:number, 2}, :close_parentheses,
        {:function, "max"}, {:number, 3}, {:number, 4},
      ]}
    ]

    assert Rpn.rpn(tokens) == [
      {:tuple, [
        {:function, "max"}, {:number, 4}, {:number, 3},
        {:function, "min"}, {:number, 2}, {:number, 1}
      ]}
    ]
  end

end
