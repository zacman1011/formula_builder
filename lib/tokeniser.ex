defmodule FormulaBuilder.Tokeniser do

  @moduledoc """
    Responsible for taking a string containing a formula and converting it into a list of acceptable tokens.
  """

  import FormulaBuilder.Operations
  import FormulaBuilder.Functions

  alias FormulaBuilder.Types

  @operations operations()
  @function_names function_names()

  @whitespace ["\s", "\t", "\n", "\r"]

  @doc """
    Converts a string containing a formula into tokens that can be interpreted by the Rpn and FunctionBuilder modules
  """
  @spec build_tokens(String.t()) :: [Types.token()] | :error
  def build_tokens(formula_string) do
    case String.graphemes(formula_string) do
      [] -> :error
      formula_graphemes ->
        case interpret_graphemes(formula_graphemes, []) do
          :error ->
            :error

          tokens when is_list(tokens) ->
            tokens

          _ ->
            :error
        end
    end
  end

  defp interpret_graphemes([], tokens) do
    ## finished interpretation - reverse tokens due to accumulating nature
    Enum.reverse(tokens)
  end
  defp interpret_graphemes([whitespace | tokens], acc) when whitespace in @whitespace do
    ## ignore whitespace
    interpret_graphemes(tokens, acc)
  end
  defp interpret_graphemes(["i", "f", whitespace | tokens], acc) when whitespace in @whitespace do
    ## the start of an if_block - so use function do_if_block/1 to complete the if block or return an error
    case do_if_block(tokens) do
      {:ok, {:if, _condition, _true_clause, _false_clause}=if_block, remaining} ->
        ## add if block and continue if successful
        interpret_graphemes(remaining, [if_block | acc])

      :error ->
        ## an error occurred inside one of the if block clauses so stop and error
        :error
    end
  end
  defp interpret_graphemes(["d", "o", whitespace | tokens], acc) when whitespace in @whitespace do
    ## denotes the end of the if condition so acc is returned as the condition expression
    {:do, tokens, acc}
  end
  defp interpret_graphemes(["e", "l", "i", "f", whitespace | tokens], acc) when whitespace in @whitespace do
    ## denotes the end of the true/if clause in the acc so acc is returned as the true case expression
    {:elif, tokens, acc}
  end
  defp interpret_graphemes(["e", "l", "s", "e", whitespace | tokens], acc) when whitespace in @whitespace do
    ## denotes the end of the true/elif clause in the acc so acc is returned as the true case expression
    {:else, tokens, acc}
  end
  defp interpret_graphemes(["e", "n", "d", ")" | tokens], acc) do
    ## denotes the end of the false clause and the end of the if statement so returns the acc as the false case expression
    {:end, [")" | tokens], acc}
  end
  defp interpret_graphemes(["e", "n", "d", whitespace | tokens], acc) when whitespace in @whitespace do
    ## denotes the end of the false clause and the end of the if statement so returns the acc as the false case expression
    {:end, tokens, acc}
  end
  defp interpret_graphemes(["e", "n", "d"], acc) do
    ## denotes the end of the false clause and the end of the if statement so returns the acc as the false case expression
    {:end, [], acc}
  end
  defp interpret_graphemes(["t", "r", "u", "e" | tokens], acc) do
    ## denotes a boolean true expression
    interpret_graphemes(tokens, [{:boolean, true} | acc])
  end
  defp interpret_graphemes(["f", "a", "l", "s", "e" | tokens], acc) do
    ## denotes a boolean false expression
    interpret_graphemes(tokens, [{:boolean, false} | acc])
  end
  defp interpret_graphemes([op1, op2 | tokens], acc) when (op1 <> op2) in @operations do
    ## checking for two character operations
    interpret_graphemes(tokens, [{:operation, op1 <> op2} | acc])
  end
  defp interpret_graphemes([op | tokens], acc) when op in @operations do
    ## checking for single character operations
    interpret_graphemes(tokens, [{:operation, op} | acc])
  end
  defp interpret_graphemes(["(" | tokens], acc), do: interpret_graphemes(tokens, [:open_parentheses | acc])
  defp interpret_graphemes([")" | tokens], acc), do: interpret_graphemes(tokens, [:close_parentheses | acc])
  defp interpret_graphemes(["{" | tokens], acc) do
    case do_tuple(tokens) do
      {tuple, remaining} ->
        interpret_graphemes(remaining, [tuple | acc])

      :error ->
        :error
    end
  end
  defp interpret_graphemes(["}" | tokens], acc) do
    {:close_tuple, tokens, acc}
  end
  defp interpret_graphemes([":" | tokens], acc) do
    {token_seq, remaining} = find_func_or_var(tokens)
    try do
      atom = String.to_existing_atom(token_seq)
      interpret_graphemes(remaining, [{:atom, atom} | acc])
    rescue
      ArgumentError ->
        :error
    end
  end
  defp interpret_graphemes([next | tokens], acc) do
    ## is this next token an integer and the start of a number
    if digit_grapheme?(next) do
      ## gets all the characters from tokens that make up a number
      {number, remaining} = find_number(tokens, next)
      interpret_graphemes(remaining, [{:number, number} | acc])
    else
      ## this is not a number and therefore makes up a function or variable name
      {token_seq, remaining} = find_func_or_var(tokens)
      token_seq = next <> token_seq
      ## is the sequence of tokens a known function name
      if token_seq in @function_names do
        interpret_graphemes(remaining, [{:function, token_seq} | acc])
      else
        ## Checking the entirety of variable is allowed
        case validate_variable(token_seq) do
          {:variable, ^token_seq} ->
            interpret_graphemes(remaining, [{:variable, token_seq} | acc])

          :error ->
            :error
        end
      end
    end
  end

  defp validate_variable(suspect_variable) do
    ## Is the entire variable allowed (checks the first character too)
    if Regex.match?(~r/^[a-zA-Z][a-zA-Z\d_]*$/, suspect_variable) do
      {:variable, suspect_variable}
    else
      :error
    end
  end

  defp find_func_or_var([]), do: {"", []}
  defp find_func_or_var([token | tokens]) do
    ## is this an allowed character?
    if token =~ ~r/[a-zA-Z\d_]/ do
      ## yes and carry on
      {token_seq, rem_tokens} = find_func_or_var(tokens)
      {token <> token_seq, rem_tokens}
    else
      ## no so prepend to tokens as it might be part of the next operation (for non-whitespaced formulae)
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
    if digit_grapheme?(next) do
      find_number(tail, number <> next, has_decimal)
    else
      if next == "." and not has_decimal do
        find_number(tail, number <> next, true)
      else
        {number, graphemes, has_decimal}
      end
    end
  end

  defp digit_grapheme?(grapheme) do
    Regex.match?(~r/\d/, grapheme)
  end

  defp do_if_block(tokens) do
    with {:do,   rem, condition}    <- interpret_graphemes(tokens, []),
         {elifs_else, rem}          <- do_elifs(rem),
         {:end,  rem, false_clause} <- interpret_graphemes(rem,    [])
    do
      [true_clause | elifs_else] = Enum.reverse([false_clause | elifs_else])
      {:ok, {:if, Enum.reverse(condition), Enum.reverse(true_clause), Enum.map(elifs_else, &Enum.reverse/1)}, rem}

    else
      :error ->
        :error
    end
  end

  defp do_elifs(tokens, acc \\ []) do
    case interpret_graphemes(tokens, []) do
      {:do, rem, condition} ->
        do_elifs(rem,[condition | acc])

      {:elif, rem, prev_clause} ->
        do_elifs(rem, [prev_clause | acc])

      {:else, rem, prev_clause} ->
        {[prev_clause | acc], rem}

      _ ->
        :error
    end
  end

  defp do_tuple(tokens) do
    case interpret_graphemes(tokens, []) do
      {:close_tuple, tokens, elements} ->
        elements = elements
        |> Enum.reverse()
        {{:tuple, elements}, tokens}
      _ ->
        :error
    end
  end

  @doc """
    Finds all the variables within a formula
  """
  @spec find_variables(String.t()) :: [String.t()]
  def find_variables(formula_string) do
    build_tokens(formula_string)
    |> variables_from_tokens([])
  end

  defp variables_from_tokens([], acc), do: acc
  defp variables_from_tokens([{:variable, variable} | tokens], acc) do
    variables_from_tokens(tokens, [variable | acc])
  end
  defp variables_from_tokens([{:if, cond_tokens, true_tokens, elif_else_tokens} | tokens], acc) do
    acc = variables_from_tokens(cond_tokens, acc)
    acc = variables_from_tokens(true_tokens, acc)
    acc = Enum.reduce(elif_else_tokens, acc, fn(inner_tokens, inner_acc) ->
      variables_from_tokens(inner_tokens, inner_acc)
    end)
    variables_from_tokens(tokens, acc)
  end
  defp variables_from_tokens([{:tuple, elements_tokens} | tokens], acc) do
    acc = variables_from_tokens(elements_tokens, acc)
    variables_from_tokens(tokens, acc)
  end
  defp variables_from_tokens([_ | tokens], acc) do
    variables_from_tokens(tokens, acc)
  end

  @doc """
    Takes a list of tokens and turns them back into a string
  """
  @spec tokens_to_string([Types.token()]) :: String.t()
  def tokens_to_string(tokens) do
    to_string(tokens, "")
  end

  defp to_string([], acc), do: String.trim(acc)
  defp to_string([{:number, num} | tail], acc) do
    to_string(tail, "#{acc} #{num}")
  end
  defp to_string([{:boolean, bool} | tail], acc) do
    to_string(tail, "#{acc} #{bool}")
  end
  defp to_string([{:variable, var} | tail], acc) do
    to_string(tail, "#{acc} #{var}")
  end
  defp to_string([{:operation, op} | tail], acc) do
    to_string(tail, "#{acc} #{op}")
  end
  defp to_string([{:function, func} | tail], acc) do
    to_string(tail, "#{acc} #{func}")
  end
  defp to_string([{:atom, atom} | tail], acc) do
    to_string(tail, "#{acc} :#{atom}")
  end
  defp to_string([:open_parentheses | tail], acc) do
    to_string(tail, "#{acc} (")
  end
  defp to_string([:close_parentheses | tail], acc) do
    to_string(tail, "#{acc} )")
  end
  defp to_string([{:tuple, elems} | tail], acc) do
    to_string(tail, "#{acc} {#{to_string(elems, "")}}")
  end
  defp to_string([{:if, condition, true_clause, elif_else} | tail], acc) do
    if_statement = "if #{to_string(condition, "")} do #{to_string(true_clause, "")}#{elif_else_to_string(elif_else, "")}"

    to_string(tail, "#{acc} #{if_statement}")
  end

  defp elif_else_to_string([tokens], acc), do: "#{acc} else #{to_string(tokens, "")} end"
  defp elif_else_to_string([condition, clause | tail], acc) do
    elif_else_to_string(tail, "#{acc} elif #{to_string(condition, "")} do #{to_string(clause, "")}")
  end

end
