defmodule FormulaBuilder.Types do

  @moduledoc """
    Describes the custom types used in this project.
  """

  @typedoc """
    Tokens represent the components that a formula can be broken down into.
  """
  @type token :: {:variable | :function | :operation, String.t()} |
                 {:number, integer() | float()}                   |
                 {:boolean, boolean()}                            |
                 :open_parentheses | :close_parentheses           |
                 {:if, [token()], [token()], [token()]}

  @typedoc """
    The resulting function returned from building a formula.
  """
  @type formula_function :: (input_map() -> formula_function_return())

  @typedoc """
    The map taken as the sole parameter of a formula function.
    It should be empty or have string keys representing the variables and values will be inserted into the function in place of the variables at the time of calling.
  """
  @type input_map :: %{optional(String.t()) => any()}

  @typedoc """
    The available arities for functions used in a formula.
  """
  @type formula_function_arity :: 0 | 1 | 2 | 3

  @typedoc """
    The available list of precedences for the operations used in a formula.
  """
  @type operation_precedence :: 0 | 1 | 2 | 3 | 4 | 5

  @typedoc """
    Used to represent where a return from a formula function exists
  """
  @type formula_function_return() :: any()

end
