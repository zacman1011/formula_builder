defmodule FormulaBuilder do

  @moduledoc """
    The FormulaBuilder is the primary entry point to the library and can be used without interaction with any other part of the system.

    Formulae made by this library will be returned as a function which takes a map as its sole argument. This map is to store the name of each variable in the formula to the value that should be used in the formula.
  """

  require Logger

  alias FormulaBuilder.{Tokeniser, Rpn, FunctionBuilder, Types}

  @doc """
    Takes a formula as a string and returns a function which takes just a map as its only parameter.
  """
  @spec build_formula(String.t()) :: :error | Types.formula_function()
  def build_formula(formula_string) do
    formula_string
    |> Tokeniser.build_tokens()
    |> Rpn.rpn()
    |> FunctionBuilder.build_function()
  end
end
