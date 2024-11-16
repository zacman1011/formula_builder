defmodule FormulaBuilder.Operations do

  @moduledoc """
    Defines the operations available for formulae to have.
    Every operation is a binary infix operation.
  """

  alias FormulaBuilder.Types

  require Decimal

  ## banned_operations ".", 0-9, any letter
  @operation_definitions %{
    "+"  => {4, &__MODULE__.add/3},
    "-"  => {4, &__MODULE__.minus/3},
    "/"  => {5, &__MODULE__.divide/3},
    "*"  => {5, &__MODULE__.multiply/3},
    "%"  => {3, &__MODULE__.modulo/3},
    "//" => {5, &__MODULE__.integer_divide/3},
    "==" => {2, &__MODULE__.equals_func/3},
    "!=" => {2, &__MODULE__.not_equals_func/3},
    "<"  => {2, &__MODULE__.less_than_func/3},
    ">"  => {2, &__MODULE__.more_than_func/3},
    "<=" => {2, &__MODULE__.less_than_equal_to_func/3},
    ">=" => {2, &__MODULE__.more_than_equal_to_func/3},
    "&&" => {1, &__MODULE__.and_func/3},
    "||" => {0, &__MODULE__.or_func/3}
  }

  @operations Map.keys(@operation_definitions)

  @operation_functions Enum.into(@operation_definitions, %{}, fn({f, {_, func}}) -> {f, func} end)

  @operation_precedence Enum.into(@operation_definitions, %{}, fn({f, {arity, _}}) -> {f, arity} end)

  @doc """
    The names of the operations compiled and ready to be used in the formulae.
  """
  @spec operations :: [String.t()]
  def operations do
    @operations
  end

  @doc """
    The operations compiled and ready to be used in the formulae.
  """
  @spec operation_functions :: %{String.t() => fun()}
  def operation_functions do
    @operation_functions
  end

  @doc """
    The operations' precedences compiled and ready to be used in the formulae in a map with the form operation name to precedence.
  """
  @spec operation_precedence :: %{String.t() => Types.operation_precedence()}
  def operation_precedence do
    @operation_precedence
  end


  #####################################################
  ##                                                 ##
  ##     Functions for operations using Decimals     ##
  ##                                                 ##
  #####################################################

  @doc """
    Adds two Decimal parameters together

    Formula representation: `+`
  """
  @spec add(Types.formula_function(), Types.formula_function(), Types.input_map()) :: Decimal.t()
  def add(a, b, map), do: Decimal.add(a.(map), b.(map))

  @doc """
    Subtracts the second Decimal parameter from the first

    Formula representation: `-`
  """
  @spec minus(Types.formula_function(), Types.formula_function(), Types.input_map()) :: Decimal.t()
  def minus(a, b, map), do: Decimal.sub(b.(map), a.(map))

  @doc """
    Divides the second Decimal parameter from the first

    Formula representation: `/`
  """
  @spec divide(Types.formula_function(), Types.formula_function(), Types.input_map()) :: Decimal.t()
  def divide(a, b, map), do: Decimal.div(b.(map), a.(map))

  @doc """
    Multiplies two Decimal parameters together

    Formula representation: `*`
  """
  @spec multiply(Types.formula_function(), Types.formula_function(), Types.input_map()) :: Decimal.t()
  def multiply(a, b, map), do: Decimal.mult(a.(map), b.(map))

  @doc """
    Integer divides the second Decimal parameter from the first

    Formula representation: `//`
  """
  @spec integer_divide(Types.formula_function(), Types.formula_function(), Types.input_map()) :: Decimal.t()
  def integer_divide(a, b, map), do: Decimal.div_int(b.(map), a.(map))

  @doc """
    Modulos (takes the remainder when dividing) the second Decimal parameter from the first

    Formula representation: `%`
  """
  @spec modulo(Types.formula_function(), Types.formula_function(), Types.input_map()) :: Decimal.t()
  def modulo(a, b, map), do: Decimal.rem(b.(map), a.(map))

  @doc """
    Compares two Decimal parameters and returns true if they are equal, false otherwise

    Formula representation: `==`
  """
  @spec equals_func(Types.formula_function(), Types.formula_function(), Types.input_map()) :: boolean()
  def equals_func(a, b, map), do: eq?(a.(map), b.(map))

  defp eq?(a, b) when Decimal.is_decimal(a) and Decimal.is_decimal(b) do
    Decimal.eq?(a, b)
  end
  defp eq?(a, b) do
    a == b
  end

  @doc """
    Compares two Decimal parameters and returns true if they are not equal, false otherwise

    Formula representation: `!=`
  """
  @spec not_equals_func(Types.formula_function(), Types.formula_function(), Types.input_map()) :: boolean()
  def not_equals_func(a, b, map), do: neq?(a.(map), b.(map))

  defp neq?(a, b) when Decimal.is_decimal(a) and Decimal.is_decimal(b) do
    Decimal.neq?(a, b)
  end
  defp neq?(a, b) do
    a != b
  end

  @doc """
    Compares two Decimal parameters and returns true if the first is less than the second, false otherwise

    Formula representation: `<`
  """
  @spec less_than_func(Types.formula_function(), Types.formula_function(), Types.input_map()) :: boolean()
  def less_than_func(a, b, map), do: Decimal.lt?(b.(map), a.(map))

  @doc """
    Compares two Decimal parameters and returns true if the first is more than the second, false otherwise

    Formula representation: `>`
  """
  @spec more_than_func(Types.formula_function(), Types.formula_function(), Types.input_map()) :: boolean()
  def more_than_func(a, b, map), do: Decimal.gt?(b.(map), a.(map))

  @doc """
    Compares two Decimal parameters and returns true if the first is less than or equal to the second, false otherwise

    Formula representation: `<=`
  """
  @spec less_than_equal_to_func(Types.formula_function(), Types.formula_function(), Types.input_map()) :: boolean()
  def less_than_equal_to_func(a, b, map), do: Decimal.lte?(b.(map), a.(map))

  @doc """
    Compares two Decimal parameters and returns true if the first is more than or equal to the second, false otherwise

    Formula representation: `>=`
  """
  @spec more_than_equal_to_func(Types.formula_function(), Types.formula_function(), Types.input_map()) :: boolean()
  def more_than_equal_to_func(a, b, map), do: Decimal.gte?(b.(map), a.(map))

  ####################################################
  ##                                                ##
  ##     Functions for operations using boolean     ##
  ##                                                ##
  ####################################################

  @doc """
    Runs the Elixir `and` on the two parameters and returns the result

    Formula representation: `&&`
  """
  @spec and_func(Types.formula_function(), Types.formula_function(), Types.input_map()) :: boolean()
  def and_func(a, b, map), do: a.(map) and b.(map)

  @doc """
    Runs the Elixir `or` on the two parameters and returns the result

    Formula representation: `||`
  """
  @spec or_func(Types.formula_function(), Types.formula_function(), Types.input_map()) :: boolean()
  def or_func(a, b, map), do: a.(map) or b.(map)

end
