defmodule FormulaBuilder.Tokeniser do
  import FormulaBuilder.Operations
  import FormulaBuilder.Functions

  @operations operations()
  @function_names function_names()

  @whitespace ["\s", "\t", "\n"]

  def build_tokens(formula_string) do
    case String.graphemes(formula_string) do
      [] -> nil
      formula_graphemes ->
        case interpret_graphemes(formula_graphemes, []) do
          :error -> :error
          tokens -> tokens
        end
    end
  end

  defp interpret_graphemes([], tokens) do
    Enum.reduce(tokens, [], fn next, acc ->
      case next do
        :ignore ->
          acc

        _ ->
          [next | acc]
      end
    end)
  end
  defp interpret_graphemes([whitespace | tokens], acc) when whitespace in @whitespace, do: interpret_graphemes(tokens, acc)
  defp interpret_graphemes(["i", "f", whitespace | tokens], acc) when whitespace in @whitespace do
    case do_if_block(tokens) do
      {:ok, {:if, _condition, _true_clause, _false_clause}=if_block, remaining} -> interpret_graphemes(remaining, [if_block | acc])
      :error -> :error
    end
  end
  defp interpret_graphemes(["d", "o", whitespace | tokens], acc) when whitespace in @whitespace do
    {:do, tokens, acc}
  end
  defp interpret_graphemes(["e", "l", "s", "e", whitespace | tokens], acc) when whitespace in @whitespace do
    {:else, tokens, acc}
  end
  defp interpret_graphemes(["e", "n", "d", whitespace | tokens], acc) when whitespace in @whitespace do
    {:end, tokens, acc}
  end
  defp interpret_graphemes(["e", "n", "d"], acc) do
    {:end, [], acc}
  end
  defp interpret_graphemes([op | tokens], acc) when op in @operations, do: interpret_graphemes(tokens, [{:operation, op} | acc])
  defp interpret_graphemes([op1, op2 | tokens], acc) when (op1 <> op2) in @operations, do: interpret_graphemes(tokens, [{:operation, op1 <> op2} | acc])
  defp interpret_graphemes(["(" | tokens], acc), do: interpret_graphemes(tokens, [{:open_parentheses, "("} | acc])
  defp interpret_graphemes([")" | tokens], acc), do: interpret_graphemes(tokens, [{:close_parentheses, ")"} | acc])
  defp interpret_graphemes([next | tokens], acc) do
    if integer_grapheme?(next) do
      ## number
      {number, remaining} = find_number(tokens, next)
      interpret_graphemes(remaining, [{:number, number} | acc])
    else
      ## not a number
      {token_seq, remaining} = find_func_or_var(tokens)
      token_seq = next <> token_seq
      result = if token_seq in @function_names do
        {:function, token_seq}
      else
        {:variable, token_seq}
      end
      interpret_graphemes(remaining, [result | acc])
    end
  end

  defp find_func_or_var([]), do: {"", []}
  defp find_func_or_var([token | tokens]) do
    if token =~ ~r/[a-zA-Z0-9_]/ do
      {token_seq, rem_tokens} = find_func_or_var(tokens)
      {token <> token_seq, rem_tokens}
    else
      {"", [token | tokens]}
    end
  end

  defp find_number(graphemes, number_start) do
    {number_string, remaining, has_decimal} = find_number(graphemes, number_start, false)
    number = if has_decimal do
      {num, _} = Float.parse(number_string)
      num
    else
      {num, _} = Integer.parse(number_string)
      num
    end

    {number, remaining}
  end
  defp find_number([], number, has_decimal), do: {number, [], has_decimal}
  defp find_number(graphemes = [next | tail], number, has_decimal) do
    if integer_grapheme?(next) do
      find_number(tail, number <> next, has_decimal)
    else
      if next == "." and not has_decimal do
        find_number(tail, number <> next, true)
      else
        {number, graphemes, has_decimal}
      end
    end
  end

  defp integer_grapheme?(grapheme) do
    case Integer.parse(grapheme) do
      {_, ""} ->
        true

      {_, _} ->
        raise("Error interpreting grapheme to integer - seems to be more than one grapheme")

      _ ->
        false
    end
  end

  defp do_if_block(tokens) do
    case interpret_graphemes(tokens, []) do
      :error -> :error
      {:do, rem, condition} ->
        case interpret_graphemes(rem, []) do
          :error -> :error
          {:else, rem, true_clause} ->
            case interpret_graphemes(rem, []) do
              :error -> :error
              {:end, rem, false_clause} ->
                {:ok, {:if, Enum.reverse(condition), Enum.reverse(true_clause), Enum.reverse(false_clause)}, rem}
            end
        end
    end
  end
end
