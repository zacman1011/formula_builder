defmodule FormulaBuilder.Types do

  @moduledoc """
    Describes the custom types used in this project.
  """

  @type token :: {:variable | :function | :operation, String.t()} |
                 {:number, Integer.t() | Float.t()}               |
                 {:boolean, boolean()}                            |
                 :open_parentheses | :close_parentheses           |
                 {:if, [token()], [token()], [token()]}

  @type formula_function :: (input_map() -> boolean())

  @type input_map :: %{optional(String.t()) => any()}

  @type formula_function_arity :: 0 | 1 | 2 | 3

  @type operation_precedence :: 0 | 1 | 2 | 3 | 4 | 5

end
