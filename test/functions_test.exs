defmodule FunctionsTest do
  use ExUnit.Case

  alias FormulaBuilder.{Functions, TestFormulaeFunctions}

  @one     Decimal.new(1)
  @two     Decimal.new(2)
  @three   Decimal.new(3)
  @six     Decimal.new(6)
  @neg_one Decimal.new(-1)

  describe "Functions testing" do

    setup do
      a = fn(_) -> @one end
      b = fn(_) -> @two end
      c = fn(_) -> @three end
      d = fn(_) -> @neg_one end

      true_func  = fn(_) -> true end
      false_func = fn(_) -> false end

      %{
        a: a,
        b: b,
        c: c,
        d: d,
        true_func:  true_func,
        false_func: false_func
      }
    end

    test "min", %{a: a, b: b} do
      assert Functions.min_func(a, b, %{}) == @one
    end

    test "max", %{a: a, b: b} do
      assert Functions.max_func(a, b, %{}) == @two
    end

    test "min3", %{a: a, b: b, c: c} do
      assert Functions.min3_func(a, b, c, %{}) == @one
    end

    test "max3", %{a: a, b: b, c: c} do
      assert Functions.max3_func(a, b, c, %{}) == @three
    end

    test "not", %{true_func: f1, false_func: f2} do
      refute Functions.not_func(f1, %{})
      assert Functions.not_func(f2, %{})
    end

    test "triad", %{a: a, b: b, c: c} do
      assert Functions.triad_func(a, b, c, %{}) == @six
    end

    test "neg", %{a: a, d: d} do
      assert Functions.neg_func(a, %{}) == @neg_one
      assert Functions.neg_func(d, %{}) == @one
    end

    test "abs", %{a: a, d: d} do
      assert Functions.abs_func(a, %{}) == @one
      assert Functions.abs_func(d, %{}) == @one
    end

  end

  describe "Helper functions testing" do

    test "function_names" do
      assert Functions.function_names() == [
        "abs",
        "max",
        "max3",
        "min",
        "min3",
        "neg",
        "not",
        "sub",
        "thrower",
        "triad",
        "zero"
      ]
    end

    test "functions" do
      assert Functions.functions() == %{
        "min"     => &Functions.min_func/3,
        "max"     => &Functions.max_func/3,
        "min3"    => &Functions.min3_func/4,
        "max3"    => &Functions.max3_func/4,
        "not"     => &Functions.not_func/2,
        "triad"   => &Functions.triad_func/4,
        "neg"     => &Functions.neg_func/2,
        "abs"     => &Functions.abs_func/2,
        "sub"     => &TestFormulaeFunctions.sub_func/3,
        "thrower" => &TestFormulaeFunctions.thrower_func/1,
        "zero"    => &TestFormulaeFunctions.zero_func/1
      }
    end

    test "function_arities" do
      assert Functions.function_arities() == %{
        "min"     => 2,
        "max"     => 2,
        "min3"    => 3,
        "max3"    => 3,
        "not"     => 1,
        "triad"   => 3,
        "neg"     => 1,
        "abs"     => 1,
        "sub"     => 2,
        "thrower" => 0,
        "zero"    => 0
      }
    end

  end

end
