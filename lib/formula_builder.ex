defmodule FormulaBuilder do

  alias FormulaBuilder.{Tokeniser, Rpn, FunctionBuilder, Types}

  @type formula_function :: Types.formula_function()

  @spec build_formula(String.t()) :: :error | formula_function()
  def build_formula(formula_string) do
    formula_string
      |> Tokeniser.build_tokens()
      |> Rpn.rpn()
      |> FunctionBuilder.build_function()
  end
end
