defmodule FormulaBuilderTest do
  use ExUnit.Case
  doctest FormulaBuilder

  @one   Decimal.new(1)
  @two   Decimal.new(2)
  @three Decimal.new(3)
  @four  Decimal.new(4)

  test "number -- integer" do
    func = FormulaBuilder.build_formula("1234")

    assert func.(%{}) |> Decimal.compare(1234) == :eq
  end

  test "variable" do
    func = FormulaBuilder.build_formula("a")

    assert func.(%{"a" => 2}) |> Decimal.compare(@two) == :eq
  end

  test "boolean -- true" do
    func = FormulaBuilder.build_formula("true")

    assert func.(%{})
  end

  test "boolean -- false" do
    func = FormulaBuilder.build_formula("false")

    refute func.(%{})
  end

  test "boolean or variable -- true true" do
    func = FormulaBuilder.build_formula("true || a")

    assert func.(%{"a" => true})
  end

  test "boolean or variable -- true false" do
    func = FormulaBuilder.build_formula("true || a")

    assert func.(%{"a" => false})
  end

  test "boolean or variable -- false true" do
    func = FormulaBuilder.build_formula("false || a")

    assert func.(%{"a" => true})
  end

  test "boolean or variable -- false false" do
    func = FormulaBuilder.build_formula("false || a")

    refute func.(%{"a" => false})
  end

  test "minus a number from another" do
    func = FormulaBuilder.build_formula("5 - 2")

    assert func.(%{}) |> Decimal.compare(@three) == :eq
  end

  test "variable plus decimal" do
    func = FormulaBuilder.build_formula("a + 1.2")

    assert func.(%{"a" => 2}) |> Decimal.compare(Decimal.from_float(3.2)) == :eq
  end

  test "triad with variable and number and decimal" do
    func = FormulaBuilder.build_formula("triad a 2 1.2")

    assert func.(%{"a" => 2}) |> Decimal.compare(Decimal.from_float(5.2)) == :eq
  end

  test "triad with variable and number and decimal with function parentheses" do
    func = FormulaBuilder.build_formula("triad( a 2 1.2 )")

    assert func.(%{"a" => 2}) |> Decimal.compare(Decimal.from_float(5.2)) == :eq
  end

  test "contract comparison" do
    func = FormulaBuilder.build_formula("c1 - c2 < 50")

    assert func.(%{"c1" => 80, "c2" => 50}) == true
  end

  test "if block simple" do
    func = FormulaBuilder.build_formula("if cond do c+1 else d + 3 end")

    assert func.(%{"cond" => true, "c" => 1, "d" => 10}) |> Decimal.compare(2) == :eq
    assert func.(%{"cond" => false, "c" => 1, "d" => 10}) |> Decimal.compare(13) == :eq
  end

  test "min func" do
    func = FormulaBuilder.build_formula("min a b")

    assert func.(%{"a" => Decimal.new(5), "b" => Decimal.new(4)}) == Decimal.new(4)
    assert func.(%{"a" => Decimal.new(4), "b" => Decimal.new(5)}) == Decimal.new(4)
  end

  test "max func" do
    func = FormulaBuilder.build_formula("max a b")

    assert func.(%{"a" => Decimal.new(5), "b" => Decimal.new(4)}) == Decimal.new(5)
    assert func.(%{"a" => Decimal.new(4), "b" => Decimal.new(5)}) == Decimal.new(5)
  end

  test "min3 func" do
    func = FormulaBuilder.build_formula("min3 a b c")

    assert func.(%{"a" => Decimal.new(5), "b" => Decimal.new(4), "c" => Decimal.new(6)}) == Decimal.new(4)
    assert func.(%{"a" => Decimal.new(4), "b" => Decimal.new(5), "c" => Decimal.new(6)}) == Decimal.new(4)
    assert func.(%{"a" => Decimal.new(6), "b" => Decimal.new(5), "c" => Decimal.new(4)}) == Decimal.new(4)
  end

  test "max3 func" do
    func = FormulaBuilder.build_formula("max3 a b c")

    assert func.(%{"a" => Decimal.new(5), "b" => Decimal.new(4), "c" => Decimal.new(3)}) == Decimal.new(5)
    assert func.(%{"a" => Decimal.new(4), "b" => Decimal.new(5), "c" => Decimal.new(3)}) == Decimal.new(5)
    assert func.(%{"a" => Decimal.new(4), "b" => Decimal.new(3), "c" => Decimal.new(5)}) == Decimal.new(5)
  end

  test "not func" do
    func = FormulaBuilder.build_formula("not a")

    refute func.(%{"a" => true})
    assert func.(%{"a" => false})
  end

  test "triad func" do
    func = FormulaBuilder.build_formula("triad a b c")

    assert func.(%{"a" => Decimal.new(5), "b" => Decimal.new(4), "c" => Decimal.new(6)}) == Decimal.new(15)
  end

  test "neg func" do
    func = FormulaBuilder.build_formula("neg a")

    assert func.(%{"a" => Decimal.new(1)}) == Decimal.new(-1)
    assert func.(%{"a" => Decimal.new(-1)}) == Decimal.new(1)
  end

  test "abs func" do
    func = FormulaBuilder.build_formula("abs a")

    assert func.(%{"a" => Decimal.new(1)}) == Decimal.new(1)
    assert func.(%{"a" => Decimal.new(-1)}) == Decimal.new(1)
  end

  test "add two numbers" do
    func = FormulaBuilder.build_formula("1.1+2")

    assert func.(%{}) == Decimal.from_float(3.1)
  end

  test "minus two numbers" do
    func = FormulaBuilder.build_formula("1.1 - 2")

    assert func.(%{}) == Decimal.from_float(-0.9)
  end

  test "multiply two numbers" do
    func = FormulaBuilder.build_formula("1.1 * 2")

    assert func.(%{}) == Decimal.from_float(2.2)
  end

  test "divide two numbers" do
    func = FormulaBuilder.build_formula("2.2 / 2")

    assert func.(%{}) == Decimal.from_float(1.1)
  end

  test "integer divide two numbers" do
    func = FormulaBuilder.build_formula("2.1 // 2")

    assert func.(%{}) == Decimal.new(1)
  end

  test "modulo two numbers" do
    func = FormulaBuilder.build_formula("11 % 2")

    assert func.(%{}) == Decimal.new(1)
  end

  test "equals test two numbers" do
    func = FormulaBuilder.build_formula("1.1 == 2")

    refute func.(%{})
  end

  test "less than two numbers" do
    func = FormulaBuilder.build_formula("1.1 < 2")

    assert func.(%{})
  end

  test "greater than two numbers" do
    func = FormulaBuilder.build_formula("1.1 > 2")

    refute func.(%{})
  end

  test "less than or equal to two numbers" do
    func = FormulaBuilder.build_formula("1.1 <= 2")

    assert func.(%{})
  end

  test "more than or equal to two numbers" do
    func = FormulaBuilder.build_formula("1.1 >= 2")

    refute func.(%{})
  end

  test "min with brackets around second parameters" do
    func = FormulaBuilder.build_formula("min a (0-b)")

    assert func.(%{"a" => Decimal.new(5), "b" => Decimal.new(4)}) == Decimal.new(-4)
    assert func.(%{"a" => Decimal.new(4), "b" => Decimal.new(-5)}) == Decimal.new(4)
  end

  test "min with brackets and with brackets around second parameters" do
    func = FormulaBuilder.build_formula("min(a (0-b))")

    assert func.(%{"a" => Decimal.new(5), "b" => Decimal.new(4)}) == Decimal.new(-4)
    assert func.(%{"a" => Decimal.new(4), "b" => Decimal.new(-5)}) == Decimal.new(4)
  end

  test "min with brackets and with brackets around second parameter function call" do
    func = FormulaBuilder.build_formula("min(a (0 - min a b))")

    assert func.(%{"a" => Decimal.new(5), "b" => Decimal.new(4)}) == Decimal.new(-4)
    assert func.(%{"a" => Decimal.new(4), "b" => Decimal.new(-5)}) == Decimal.new(4)
  end

  test "min with if statement parameter 1st parameter" do
    func = FormulaBuilder.build_formula("min if cond do 3 else 6 end 5")

    assert func.(%{"cond" => true}) == Decimal.new(3)
    assert func.(%{"cond" => false}) == Decimal.new(5)
  end

  test "min with if statement parameter 2nd parameter" do
    func = FormulaBuilder.build_formula("min 5 if cond do 3 else 6 end")

    assert func.(%{"cond" => true}) == Decimal.new(3)
    assert func.(%{"cond" => false}) == Decimal.new(5)
  end

  test "min with if statement parameter 1st parameter with brackets" do
    func = FormulaBuilder.build_formula("min ((if cond do 3 else 6 end) 5)")

    assert func.(%{"cond" => true}) == Decimal.new(3)
    assert func.(%{"cond" => false}) == Decimal.new(5)
  end

  test "min with if statement parameter 2nd parameter with brackets" do
    func = FormulaBuilder.build_formula("min (5 (if cond do 3 else 6 end))")

    assert func.(%{"cond" => true}) == Decimal.new(3)
    assert func.(%{"cond" => false}) == Decimal.new(5)
  end

  test "complex if statement" do
    func = FormulaBuilder.build_formula("if cond && min a b > 0 do min (a (0 - min a b)) else false end")

    assert func.(%{"a" => Decimal.new(5), "b" => Decimal.new(4), "cond" => true}) == Decimal.new(-4)
    assert func.(%{"a" => Decimal.new(3), "b" => Decimal.new(4), "cond" => true}) == Decimal.new(-3)
    refute func.(%{"a" => Decimal.new(5), "b" => Decimal.new(4), "cond" => false})
    refute func.(%{"a" => Decimal.new(5), "b" => Decimal.new(-1), "cond" => true})
  end

  test "double nested if statement" do
    func = FormulaBuilder.build_formula("if a > 0 do if b > 0 do if c > 0 do 1 else 2 end else if d > 0 do 3 else 4 end end else if e > 0 do if f > 0 do 5 else 6 end else if g > 0 do 7 else 8 end end end")

    pos = Decimal.new(1)
    neg = Decimal.new(-1)

    assert func.(%{"a" => pos, "b" => pos, "c" => pos, "d" => pos, "e" => pos, "f" => pos, "g" => pos}) == Decimal.new(1)
    assert func.(%{"a" => pos, "b" => pos, "c" => neg, "d" => pos, "e" => pos, "f" => pos, "g" => pos}) == Decimal.new(2)
    assert func.(%{"a" => pos, "b" => neg, "c" => pos, "d" => pos, "e" => pos, "f" => pos, "g" => pos}) == Decimal.new(3)
    assert func.(%{"a" => pos, "b" => neg, "c" => pos, "d" => neg, "e" => pos, "f" => pos, "g" => pos}) == Decimal.new(4)
    assert func.(%{"a" => neg, "b" => pos, "c" => pos, "d" => pos, "e" => pos, "f" => pos, "g" => pos}) == Decimal.new(5)
    assert func.(%{"a" => neg, "b" => pos, "c" => pos, "d" => pos, "e" => pos, "f" => neg, "g" => pos}) == Decimal.new(6)
    assert func.(%{"a" => neg, "b" => pos, "c" => pos, "d" => pos, "e" => neg, "f" => pos, "g" => pos}) == Decimal.new(7)
    assert func.(%{"a" => neg, "b" => pos, "c" => pos, "d" => pos, "e" => neg, "f" => pos, "g" => neg}) == Decimal.new(8)
  end

  test "safety wrapper -- bad formula" do
    func = FormulaBuilder.build_formula("true < 0")

    refute func.(%{})
  end

  test "safety wrapper -- bad variable value" do
    func = FormulaBuilder.build_formula("num < 0")

    refute func.(%{"num" => true})
  end

  test "order of function arguments is correct" do
    func = FormulaBuilder.build_formula("sub 10 4")

    assert Decimal.eq?(func.(%{}), 6)
  end

  test "Bad formula that can't be tokenised returns :error" do
    assert FormulaBuilder.build_formula("@") == :error
  end

  test "Zero args function used with operation" do
    func = FormulaBuilder.build_formula("zero + 1")

    assert Decimal.eq?(func.(%{}), 1)
  end

  test "Atom gets returned" do
    func = FormulaBuilder.build_formula(":test_atom")

    assert func.(%{}) == :test_atom
  end

  test "Throwing function gets caught and returns :error" do
    func = FormulaBuilder.build_formula("thrower")

    refute func.(%{})
  end

  test "Simple tuple" do
    func = FormulaBuilder.build_formula("{1 2}")
    assert func.(%{}) == {@one, @two}

    func = FormulaBuilder.build_formula("{1}")
    assert func.(%{}) == {@one}
  end

  test "Parse tuple of mixed types" do
    func = FormulaBuilder.build_formula("{1 1.1 var min(1 2) :atom}")

    assert func.(%{"var" => "a"}) == {
      @one,
      Decimal.new("1.1"),
      "a",
      @one,
      :atom
    }
  end

  test "Parse tuple with functions" do
    func = FormulaBuilder.build_formula("{min(1 2) max 3 4}")

    assert func.(%{}) == {@one, @four}
  end

  test "Parse tuple with if statements" do
    func = FormulaBuilder.build_formula("{if bool1 do 1 else 2 end if bool2 do 3 else 4 end (bool1 && bool2) min(a b)}")

    assert func.(%{"bool1" => true, "bool2" => true, "a" => @one, "b" => @two}) == {@one, @three, true, @one}
    assert func.(%{"bool1" => true, "bool2" => false, "a" => @three, "b" => @two}) == {@one, @four, false, @two}
    assert func.(%{"bool1" => false, "bool2" => true, "a" => @four, "b" => @four}) == {@two, @three, false, @four}
  end

  test "If statements with multiple elifs" do
    func = FormulaBuilder.build_formula("if cond1 do 1 elif cond2 do 2 elif cond3 do 3 else 4 end")

    assert func.(%{"cond1" => true, "cond2" => false, "cond3" => false}) == @one
    assert func.(%{"cond1" => false, "cond2" => true, "cond3" => false}) == @two
    assert func.(%{"cond1" => false, "cond2" => false, "cond3" => true}) == @three
    assert func.(%{"cond1" => false, "cond2" => false, "cond3" => false}) == @four
  end

  test "Real scenario 1" do
    t = :take_profit
    formula = "if best_price - trade_price >= 1775 do {:take_profit best_price} else false end"

    func = FormulaBuilder.build_formula(formula)

    assert func.(%{"best_price" => Decimal.new(6000), "trade_price" => Decimal.new(2700)}) == {t, Decimal.new(6000)}
  end

end
