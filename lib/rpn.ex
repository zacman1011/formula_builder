defmodule FormulaBuilder.Rpn do

  @moduledoc """
    Responsible for changing the functions from infix form to RPN form so that the function builder can understand them functionally
  """

  import FormulaBuilder.Operations

  alias FormulaBuilder.Types

  @type token() :: Types.token()

  @operation_precedence operation_precedence()

  @doc """
    Converts a list of tokens in infix order to RPN
  """
  @spec rpn(:error | [token()]) :: :error | [token()]
  def rpn(tokens)
  def rpn(:error), do: :error
  def rpn(tokens) do
    shunting(tokens, [], [])
  end

  defp shunting([], out, ops) do
    Enum.reverse(ops) ++ out
  end
  defp shunting([{:function, _function}=token | tokens], out, ops), do: shunting(tokens, out, [token | ops])
  defp shunting([{:operation, _operation}=token | tokens], out, ops) do
    {new_out, new_ops} = shunt_ops(token, out, ops)
    shunting(tokens, new_out, new_ops)
  end
  defp shunting([:open_parentheses = token | tokens], out, ops), do: shunting(tokens, out, [token | ops])
  defp shunting([:close_parentheses | tokens], out, ops) do
    {new_out, new_ops} = shunt_close_brace(out, ops)
    shunting(tokens, new_out, new_ops)
  end
  defp shunting([{:if, condition, true_clause, false_clause} | tokens], out, ops) do
    condition = shunting(condition, [], [])
    true_clause = shunting(true_clause, [], [])
    false_clause = shunting(false_clause, [], [])
    shunting(tokens, [{:if, condition, true_clause, false_clause} | out], ops)
  end
  defp shunting([token | tokens], out, ops), do: shunting(tokens, [token | out], ops)

  defp shunt_ops(token, out, []), do: {out, [token]}
  defp shunt_ops(token, out, [:open_parentheses = op | ops]), do: {out, [token, op | ops]}
  defp shunt_ops(token, out, [op | ops]) do
    if comp_ops(token, op) do
      shunt_ops(token, [op | out], ops)
    else
      {out, [token, op | ops]}
    end
  end

  defp shunt_close_brace(out, []), do: {out, []}
  defp shunt_close_brace(out, [:open_parentheses | ops]) do
    case ops do
      [] ->
        {out, []}

      [{:function, _function}=func | rem_ops] ->
        {[func | out], rem_ops}

      _ ->
        {out, ops}
    end
  end
  defp shunt_close_brace(out, [op | ops]) do
    shunt_close_brace([op | out], ops)
  end

  defp comp_ops(_op1, :open_parentheses), do: false
  defp comp_ops(_op1, {:function, _function}), do: true
  defp comp_ops({:operation, op1}, {:operation, op2}), do: Map.get(@operation_precedence, op1) <= Map.get(@operation_precedence, op2)


end
