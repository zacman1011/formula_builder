defmodule FormulaBuilder do

  alias FormulaBuilder.{Tokeniser, Rpn, FunctionBuilder}

  def build_formula(formula_string) do
    formula_string
      |> Tokeniser.build_tokens()
      |> Rpn.rpn()
      |> FunctionBuilder.build_function()
  end
end
