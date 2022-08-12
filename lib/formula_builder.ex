defmodule FormulaBuilder do

  alias FormulaBuilder.{Tokeniser, Rpn, FunctionBuilder}

  def build_formula(formula_string) do
    formula_string
      |> Tokeniser.build_tokens()
      |> print_me()
      |> Rpn.rpn()
      |> print_me()
      |> FunctionBuilder.build_function()
  end

  def print_me(me) do
    IO.puts "#{inspect me}"
    me
  end

end
