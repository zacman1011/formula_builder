defmodule OperationsTest do
  use ExUnit.Case

  alias FormulaBuilder.Operations

  @one     Decimal.new(1)
  @two     Decimal.new(2)
  @three   Decimal.new(3)
  @neg_one Decimal.new(-1)

  describe "Functions testing" do

    setup do
      a = fn(_) -> @one end
      b = fn(_) -> @two end
      c = fn(_) -> @three end
      d = fn(_) -> @neg_one end
      atom1 = fn(_) -> :test1 end
      atom2 = fn(_) -> :test2 end

      true_func  = fn(_) -> true end
      false_func = fn(_) -> false end

      %{
        a: a,
        b: b,
        c: c,
        d: d,
        atom1: atom1,
        atom2: atom2,
        true_func:  true_func,
        false_func: false_func
      }
    end

    test "add", %{a: a, b: b} do
      assert Operations.add(a, b, %{}) == @three
    end

    test "minus", %{a: a, b: b} do
      assert Operations.minus(a, b, %{}) == @one
    end

    test "divide", %{a: a, b: b} do
      assert Operations.divide(a, b, %{}) == @two
    end

    test "multiply", %{a: a, b: b} do
      assert Operations.multiply(a, b, %{}) == @two
    end

    test "modulo", %{c: c, b: b} do
      assert Operations.modulo(b, c, %{}) == @one
    end

    test "integer_divide", %{c: c, b: b} do
      assert Operations.integer_divide(b, c, %{}) == @one
    end

    test "equals", %{a: a, b: b, atom1: atom1, atom2: atom2} do
      assert Operations.equals_func(a, a, %{})
      assert Operations.equals_func(atom1, atom1, %{})
      refute Operations.equals_func(a, b, %{})
      refute Operations.equals_func(atom1, atom2, %{})
      refute Operations.equals_func(atom1, b, %{})
      refute Operations.equals_func(a, atom2, %{})
    end

    test "not_equals", %{a: a, b: b, atom1: atom1, atom2: atom2} do
      refute Operations.not_equals_func(a, a, %{})
      assert Operations.not_equals_func(a, b, %{})
      assert Operations.not_equals_func(atom1, atom2, %{})
    end

    test "less_than", %{a: a, b: b} do
      refute Operations.less_than_func(a, a, %{})
      refute Operations.less_than_func(a, b, %{})
      assert Operations.less_than_func(b, a, %{})
    end

    test "more_than", %{a: a, b: b} do
      refute Operations.more_than_func(a, a, %{})
      assert Operations.more_than_func(a, b, %{})
      refute Operations.more_than_func(b, a, %{})
    end

    test "less_than_equal", %{a: a, b: b} do
      assert Operations.less_than_equal_to_func(a, a, %{})
      refute Operations.less_than_equal_to_func(a, b, %{})
      assert Operations.less_than_equal_to_func(b, a, %{})
    end

    test "more_than_equal", %{a: a, b: b} do
      assert Operations.more_than_equal_to_func(a, a, %{})
      assert Operations.more_than_equal_to_func(a, b, %{})
      refute Operations.more_than_equal_to_func(b, a, %{})
    end

    test "and", %{true_func: true_func, false_func: false_func} do
      assert Operations.and_func(true_func,  true_func, %{})
      refute Operations.and_func(true_func,  false_func, %{})
      refute Operations.and_func(false_func, true_func, %{})
      refute Operations.and_func(false_func, false_func, %{})
    end

    test "or", %{true_func: true_func, false_func: false_func} do
      assert Operations.or_func(true_func,  true_func, %{})
      assert Operations.or_func(true_func,  false_func, %{})
      assert Operations.or_func(false_func, true_func, %{})
      refute Operations.or_func(false_func, false_func, %{})
    end

  end

  describe "Helper functions testing" do

    test "operations" do
      assert Operations.operations() == [
        "!=",
        "%",
        "&&",
        "*",
        "+",
        "-",
        "/",
        "//",
        "<",
        "<=",
        "==",
        ">",
        ">=",
        "||"
      ]
    end

    test "operation_functions" do
      assert Operations.operation_functions() == %{
        "+"  => &Operations.add/3,
        "-"  => &Operations.minus/3,
        "/"  => &Operations.divide/3,
        "*"  => &Operations.multiply/3,
        "%"  => &Operations.modulo/3,
        "//" => &Operations.integer_divide/3,
        "==" => &Operations.equals_func/3,
        "!=" => &Operations.not_equals_func/3,
        "<"  => &Operations.less_than_func/3,
        ">"  => &Operations.more_than_func/3,
        "<=" => &Operations.less_than_equal_to_func/3,
        ">=" => &Operations.more_than_equal_to_func/3,
        "&&" => &Operations.and_func/3,
        "||" => &Operations.or_func/3
      }
    end

    test "operation_precedence" do
      assert Operations.operation_precedence() == %{
        "+"  => 4,
        "-"  => 4,
        "/"  => 5,
        "*"  => 5,
        "%"  => 3,
        "//" => 5,
        "==" => 2,
        "!=" => 2,
        "<"  => 2,
        ">"  => 2,
        "<=" => 2,
        ">=" => 2,
        "&&" => 1,
        "||" => 0
      }
    end

  end

end
