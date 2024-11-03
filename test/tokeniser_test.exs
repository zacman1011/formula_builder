defmodule TokeniserTest do
  use ExUnit.Case
  doctest FormulaBuilder.Tokeniser

  alias FormulaBuilder.{Tokeniser}

  test "greets the world" do
    assert Tokeniser.build_tokens("hello world") == [{:variable, "hello"}, {:variable, "world"}]
  end

  test "empty string" do
    assert Tokeniser.build_tokens("") == :error
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

  test "variable" do
    assert Tokeniser.build_tokens("a") === [
      {:variable, "a"}
    ]
  end

  test "boolean -- true" do
    assert Tokeniser.build_tokens("true") === [
      {:boolean, true}
    ]
  end

  test "boolean -- false" do
    assert Tokeniser.build_tokens("false") === [
      {:boolean, false}
    ]
  end

  test "add two numbers" do
    assert Tokeniser.build_tokens("1.1+2") === [
      {:number, 1.1}, {:operation, "+"}, {:number, 2}
    ]
  end

  test "minus two numbers" do
    assert Tokeniser.build_tokens("1.1 - 2") === [
      {:number, 1.1}, {:operation, "-"}, {:number, 2}
    ]
  end

  test "multiply two numbers" do
    assert Tokeniser.build_tokens("1.1 * 2") === [
      {:number, 1.1}, {:operation, "*"}, {:number, 2}
    ]
  end

  test "divide two numbers" do
    assert Tokeniser.build_tokens("1.1 / 2") === [
      {:number, 1.1}, {:operation, "/"}, {:number, 2}
    ]
  end

  test "integer divide two numbers" do
    assert Tokeniser.build_tokens("1.1 // 2") === [
      {:number, 1.1}, {:operation, "//"}, {:number, 2}
    ]
  end

  test "modulo two numbers" do
    assert Tokeniser.build_tokens("1.1 % 2") === [
      {:number, 1.1}, {:operation, "%"}, {:number, 2}
    ]
  end

  test "equals test two numbers" do
    assert Tokeniser.build_tokens("1.1 == 2") === [
      {:number, 1.1}, {:operation, "=="}, {:number, 2}
    ]
  end

  test "less than two numbers" do
    assert Tokeniser.build_tokens("1.1 < 2") === [
      {:number, 1.1}, {:operation, "<"}, {:number, 2}
    ]
  end

  test "greater than two numbers" do
    assert Tokeniser.build_tokens("1.1 > 2") === [
      {:number, 1.1}, {:operation, ">"}, {:number, 2}
    ]
  end

  test "less than or equal to two numbers" do
    assert Tokeniser.build_tokens("1.1 <= 2") === [
      {:number, 1.1}, {:operation, "<="}, {:number, 2}
    ]
  end

  test "more than or equal to two numbers" do
    assert Tokeniser.build_tokens("1.1 >= 2") === [
      {:number, 1.1}, {:operation, ">="}, {:number, 2}
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
      {:variable, "a"}, {:operation, "+"}, :open_parentheses, {:variable, "hello"}, {:operation, "+"}, {:variable, "world"}, :close_parentheses
    ]
  end

  test "func on variables" do
    assert Tokeniser.build_tokens("min a b") === [
      {:function, "min"}, {:variable, "a"}, {:variable, "b"}
    ]
  end

  test "func on variables and parentheses" do
    assert Tokeniser.build_tokens("min a (b + 1)") === [
      {:function, "min"}, {:variable, "a"}, :open_parentheses, {:variable, "b"}, {:operation, "+"}, {:number, 1}, :close_parentheses
    ]
  end

  test "test" do
    assert Tokeniser.build_tokens("min 1 (a - 2)") === [
      {:function, "min"}, {:number, 1}, :open_parentheses, {:variable, "a"}, {:operation, "-"}, {:number, 2}, :close_parentheses
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
      :open_parentheses, {:number, 1}, {:operation, "+"}, {:number, 2}, :close_parentheses,
      {:operation, "-"},
      :open_parentheses, {:number, 5}, {:operation, "*"}, {:number, 7}, :close_parentheses
    ]
  end

  test "contract comparison" do
    assert Tokeniser.build_tokens("c1 - c2 < 50") === [
      {:variable, "c1"}, {:operation, "-"}, {:variable, "c2"},
      {:operation, "<"},
      {:number, 50}
    ]
  end

  test "contract comparison 2" do
    assert Tokeniser.build_tokens("c1 - c2 <= 50") === [
      {:variable, "c1"}, {:operation, "-"}, {:variable, "c2"},
      {:operation, "<="},
      {:number, 50}
    ]
  end

  test "if block simple" do
    assert Tokeniser.build_tokens("if true do c+1 else d + 3 end") === [
      {
        :if,
        [{:boolean, true}],
        [{:variable, "c"}, {:operation, "+"}, {:number, 1}],
        [[{:variable, "d"}, {:operation, "+"}, {:number, 3}]]
      }
    ]
  end

  test "if block in brackets" do
    assert Tokeniser.build_tokens("(if true do c+1 else d + 3 end)") === [
      :open_parentheses,
      {
        :if,
        [{:boolean, true}],
        [{:variable, "c"}, {:operation, "+"}, {:number, 1}],
        [[{:variable, "d"}, {:operation, "+"}, {:number, 3}]]
      },
      :close_parentheses
    ]
  end

  test "if block in whitespace" do
    assert Tokeniser.build_tokens(" if true do c+1 else d + 3 end ") === [
      {
        :if,
        [{:boolean, true}],
        [{:variable, "c"}, {:operation, "+"}, {:number, 1}],
        [[{:variable, "d"}, {:operation, "+"}, {:number, 3}]]
      }
    ]
  end

  test "if block broken condition" do
    assert Tokeniser.build_tokens("if h@g do c+1 else d + 3 end") === :error
  end

  test "if block broken true clause" do
    assert Tokeniser.build_tokens("if true do c@1 else d + 3 end") === :error
  end

  test "if block broken false clause" do
    assert Tokeniser.build_tokens("if true do c+1 else d @ 3 end") === :error
  end

  test "min func" do
    assert Tokeniser.build_tokens("min a b") === [
      {:function, "min"}, {:variable, "a"}, {:variable, "b"}
    ]
  end

  test "max func" do
    assert Tokeniser.build_tokens("max a b") === [
      {:function, "max"}, {:variable, "a"}, {:variable, "b"}
    ]
  end

  test "not func" do
    assert Tokeniser.build_tokens("not a") === [
      {:function, "not"}, {:variable, "a"}
    ]
  end

  test "triad func" do
    assert Tokeniser.build_tokens("triad a b c") === [
      {:function, "triad"}, {:variable, "a"}, {:variable, "b"}, {:variable, "c"}
    ]
  end

  test "broken function parameter" do
    assert Tokeniser.build_tokens("triad a b@2 c") === :error
  end

  test "min with if statement parameter 1st parameter with brackets" do
    tokens = Tokeniser.build_tokens("min ((if cond do 3 else 6 end) 5)")

    assert tokens === [
      {:function, "min"}, :open_parentheses, :open_parentheses, {:if, [{:variable, "cond"}], [{:number, 3}], [[{:number, 6}]]}, :close_parentheses, {:number, 5}, :close_parentheses
    ]
  end

  test "Rejected unacceptable variables" do
    assert Tokeniser.build_tokens("@hello") === :error
    assert Tokeniser.build_tokens("h@ello") === :error
    assert Tokeniser.build_tokens("hello@") === :error
    assert Tokeniser.build_tokens("_hello") === :error
    assert Tokeniser.build_tokens("_") === :error
    assert Tokeniser.build_tokens("_7") === :error
  end

  test "Parse atom" do
    tokens = Tokeniser.build_tokens(":test_atom")

    assert tokens == [{:atom, :test_atom}]
  end

  test "Unknown atom causes error" do
    tokens = Tokeniser.build_tokens(":test_atom_unknown")

    assert tokens == :error
  end

  test "Parse simple tuple" do
    assert Tokeniser.build_tokens("{1 2}") == [
      {:tuple, [{:number, 1}, {:number, 2}]}
    ]
  end

  test "Parse tuple of mixed types" do
    assert Tokeniser.build_tokens("{1 1.1 var min(1 2) :atom}") == [
      {:tuple, [
        {:number, 1},
        {:number, 1.1},
        {:variable, "var"},
        {:function, "min"}, :open_parentheses, {:number, 1}, {:number, 2}, :close_parentheses,
        {:atom, :atom}
      ]}
    ]
  end

  test "Parse tuple with functions" do
    assert Tokeniser.build_tokens("{min(1 2) min 1 2}") == [
      {:tuple, [
        {:function, "min"}, :open_parentheses, {:number, 1}, {:number, 2}, :close_parentheses,
        {:function, "min"}, {:number, 1}, {:number, 2},
      ]}
    ]
  end

  test "Parse tuple with missing bracket" do
    assert Tokeniser.build_tokens("{1 2") == :error
    assert Tokeniser.build_tokens("1 2}") == :error
  end

  test "Single elif" do
    assert Tokeniser.build_tokens("if cond1 do 1 elif cond2 do 2 else 3 end") == [{:if,
      [{:variable, "cond1"}],
      [{:number, 1}],
      [
        [{:variable, "cond2"}],
        [{:number, 2}],
        [{:number, 3}]
      ]
    }]
  end

  test "Multiple elifs" do
    assert Tokeniser.build_tokens("if cond1 do 1 elif cond2 do 2 elif cond3 do 3 else 4 end") == [{:if,
      [{:variable, "cond1"}],
      [{:number, 1}],
      [
        [{:variable, "cond2"}],
        [{:number, 2}],
        [{:variable, "cond3"}],
        [{:number, 3}],
        [{:number, 4}]
      ]
    }]
  end

  describe "find_variables/1" do

    test "variable" do
      assert Tokeniser.find_variables("a") == ["a"]
    end

    test "If cond" do
      assert Tokeniser.find_variables("if cond do 1 else 2 end") == ["cond"]
    end

    test "If true statement" do
      assert Tokeniser.find_variables("if true do a else 2 end") == ["a"]
    end

    test "If elif cond" do
      assert Tokeniser.find_variables("if true do 1 elif cond do 3 else 2 end") == ["cond"]
    end

    test "If elif true statement" do
      assert Tokeniser.find_variables("if true do 1 elif true do a else 2 end") == ["a"]
    end

    test "If else statement -- with elif" do
      assert Tokeniser.find_variables("if true do 1 elif true do 3 else a end") == ["a"]
    end

    test "If else statement -- without elif" do
      assert Tokeniser.find_variables("if true do 1 else a end") == ["a"]
    end

    test "If statement all" do
      assert Tokeniser.find_variables("if a do b elif c do d else e end") == ["e", "d", "c", "b", "a"]
    end

    test "Tuple first element" do
      assert Tokeniser.find_variables("{a 1}") == ["a"]
      assert Tokeniser.find_variables("{a 1 2}") == ["a"]
    end

    test "Tuple second element" do
      assert Tokeniser.find_variables("{1 a}") == ["a"]
      assert Tokeniser.find_variables("{1 a 1}") == ["a"]
    end

    test "Tuple third element" do
      assert Tokeniser.find_variables("{1 1 a}") == ["a"]
    end

    test "Tuple all elements" do
      assert Tokeniser.find_variables("{a b c}") == ["c", "b", "a"]
    end

    test "Nested if statement" do
      inner_if = "(if aa do bb elif cc do dd else ee end)"
      assert Tokeniser.find_variables("if #{inner_if} do b elif c do d else e end") == ["e", "d", "c", "b", "ee", "dd", "cc", "bb", "aa"]
      assert Tokeniser.find_variables("if a do #{inner_if} elif c do d else e end") == ["e", "d", "c", "ee", "dd", "cc", "bb", "aa", "a"]
      assert Tokeniser.find_variables("if a do b elif #{inner_if} do d else e end") == ["e", "d", "ee", "dd", "cc", "bb", "aa", "b", "a"]
      assert Tokeniser.find_variables("if a do b elif c do #{inner_if} else e end") == ["e", "ee", "dd", "cc", "bb", "aa", "c", "b", "a"]
      assert Tokeniser.find_variables("if a do b elif c do d else #{inner_if} end") == ["ee", "dd", "cc", "bb", "aa", "d", "c", "b", "a"]
    end

    test "Function parameter" do
      assert Tokeniser.find_variables("min(a b)") == ["b", "a"]
      assert Tokeniser.find_variables("min(a 1)") == ["a"]
      assert Tokeniser.find_variables("min(1 b)") == ["b"]
      assert Tokeniser.find_variables("min a b") == ["b", "a"]
      assert Tokeniser.find_variables("min a 1") == ["a"]
      assert Tokeniser.find_variables("min 1 b") == ["b"]
    end

    test "With operator" do
      assert Tokeniser.find_variables("a + b") == ["b", "a"]
      assert Tokeniser.find_variables("a + 1") == ["a"]
      assert Tokeniser.find_variables("1 + b") == ["b"]
    end

  end

  describe "to_string/1" do

    test "number" do
      formula = "1"
      assert_to_string(formula)

      formula = "1.2"
      assert_to_string(formula)
    end

    test "boolean" do
      formula = "true"
      assert_to_string(formula)

      formula = "false"
      assert_to_string(formula)
    end

    test "variable" do
      formula = "a"
      assert_to_string(formula)

      formula = "a_1"
      assert_to_string(formula)
    end

    test "atom" do
      formula = ":atom"
      assert_to_string(formula)
    end

    test "num op num" do
      formula = "1 + 12"
      assert_to_string(formula)

      formula = "1.6 / 0.4"
      assert_to_string(formula)
    end

    test "bool op bool" do
      formula = "false or true"
      assert_to_string(formula)

      formula = "true and false"
      assert_to_string(formula)

      formula = "not false"
      assert_to_string(formula)
    end

    test "function - no parameters" do
      formula = "zero"
      assert_to_string(formula)

      formula = "zero ( )"
      assert_to_string(formula)
    end

    test "function - one parameter" do
      formula = "neg 1"
      assert_to_string(formula)

      formula = "neg ( 1 )"
      assert_to_string(formula)
    end

    test "function - multiple parameters" do
      formula = "min3 1 a 1.3"
      assert_to_string(formula)

      formula = "neg ( a 1.3 1 )"
      assert_to_string(formula)
    end

    test "tuple" do
      formula = "{1}"
      assert_to_string(formula)

      formula = "{a 1.3 1}"
      assert_to_string(formula)
    end

    test "if statement - no elif" do
      formula = "if cond do {:atom 12.4} else abs ( a ) end"
      assert_to_string(formula)

      formula = "if cond do {:atom 12.4} elif cond2 or cond3 do 4.5 else abs ( a ) end"
      assert_to_string(formula)

      formula = "if cond do {:atom 12.4} elif cond2 do true elif cond3 do false else abs ( a ) end"
      assert_to_string(formula)
    end

  end

  defp assert_to_string(formula) do
    assert formula
    |> Tokeniser.build_tokens()
    |> Tokeniser.tokens_to_string()
    == formula
  end

end
