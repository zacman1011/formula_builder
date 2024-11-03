import Config

config :formula_builder, FormulaBuilder.Functions,
  functions: %{
    "sub"     => {2, &FormulaBuilder.TestFormulaeFunctions.sub_func/3},
    "zero"    => {0, &FormulaBuilder.TestFormulaeFunctions.zero_func/1},
    "thrower" => {0, &FormulaBuilder.TestFormulaeFunctions.thrower_func/1}
  }
