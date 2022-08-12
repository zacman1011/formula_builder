defmodule FormulaBuilder.Rpn do

  import FormulaBuilder.Operations

  @operation_precedence operation_precedence()

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
  defp shunting([{:open_parentheses, _}=token | tokens], out, ops), do: shunting(tokens, out, [token | ops])
  defp shunting([{:close_parentheses, _} | tokens], out, ops) do
    {new_out, new_ops} = shunt_close_brace(out, ops)
    shunting(tokens, new_out, new_ops)
  end
  defp shunting([token | tokens], out, ops), do: shunting(tokens, [token | out], ops)

  defp shunt_ops(token, out, []), do: {out, [token]}
  defp shunt_ops(token, out, [{:open_parentheses, _}=op | ops]), do: {out, [token, op | ops]}
  defp shunt_ops(token, out, [op | ops]) do
    if comp_ops(token, op) do
      shunt_ops(token, [op | out], ops)
    else
      {out, [token, op | ops]}
    end
  end

  defp shunt_close_brace(out, []), do: {out, []}
  defp shunt_close_brace(out, [{:open_parentheses, _} | ops]) do
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

  defp comp_ops(_op1, {:open_parentheses, _}), do: false
  defp comp_ops(_op1, {:function, _function}), do: true
  defp comp_ops({:operation, op1}, {:operation, op2}), do: Map.get(@operation_precedence, op1) <= Map.get(@operation_precedence, op2)


end
