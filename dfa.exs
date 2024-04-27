#
#Programming a DFA that recognize different tokens
#
#Diego Valencia Moreno
#
#2024-04-26


defmodule TokenList do

  # Function to tokenize a string using a given automaton
  def arithmetic_lexer(string) do
    # Define the automaton with transitions, states, and accept states
    automata = {&TokenList.delta_arithmetic/2, [:var, :oper, :int, :float, :exp, :space, :paren_open, :paren_close, :comment], :start}
    # Split the string into individual characters
    string
    |> String.graphemes()
    # Evaluate the DFA (automaton) with the input string
    |> eval_dfa(automata, [])
  end

  # Function to evaluate the DFA with no more characters left
  def eval_dfa([], {_delta, accept, state}, tokens) do
    # If the DFA is in an accept state, return the tokens
    if Enum.member?(accept, state) do
      {:ok, Enum.reverse(tokens)}
    else
      # Otherwise, return an error message
      {:error, "Invalid input"}
    end
  end

  def eval_dfa([], _state, _input, _tokens), do: {:error, "Invalid input"}

  # Function to evaluate the DFA with characters remaining
  def eval_dfa([char | tail], {delta, accept, state}, input, tokens) do
    # Determine the next state and whether a token is found based on the current state and character
    [new_state, found] = delta.(state, char)
    # Depending on whether a token is found, recursively evaluate the DFA with the remaining characters
    cond do
      found -> eval_dfa(tail, {delta, accept, new_state}, [char | input], [{found, Enum.reverse(input)} | tokens])
      true -> eval_dfa(tail, {delta, accept, new_state}, [char | input], tokens)
    end
  end

  # Define transition rules for the DFA
  def delta_arithmetic(:start, "/") do
    {:comment_start, false}
  end

  def delta_arithmetic(:comment_start, "/") do
    {:comment_line, false}
  end

  def delta_arithmetic(:comment_line, "\n"), do: {:start, :comment}
  def delta_arithmetic(_, "\n"), do: {:start, :comment}

  # Define transition rules for other states and characters
  def delta_arithmetic(state, char) do
    case state do
      :start -> cond do
        is_sign(char) -> [:sign, false]
        is_digit(char) -> [:int, false]
        is_alapha(char) -> [:var, false]
        char == "(" -> [:paren_open, false]
        char == ")" -> [:paren_close, false]
        char == " " -> [:space, false]
        true -> [:fail, false]
      end
      :var -> cond do
        is_alapha(char) -> [:var, false]
        true -> [:fail, false]
      end
      :int -> cond do
        is_digit(char) -> [:int, false]
        is_operator(char) -> [:oper, :int]
        char == "." -> [:dot, false]
        true -> [:fail, false]
      end
      :dot -> cond do
        is_digit(char) -> [:float, false]
        true -> [:fail, false]
      end
      :float -> cond do
        is_digit(char) -> [:float, false]
        is_operator(char) -> [:oper, :float]
        char == "e" -> [:exp, false]
        true -> [:fail, false]
      end
      :exp -> cond do
        is_sign(char) -> [:sign, false]
        is_digit(char) -> [:exp, false]
        true -> [:fail, false]
      end
      :oper -> cond do
        is_sign(char) -> [:sign, false]
        is_digit(char) -> [:int, false]
        true -> [:fail, false]
      end
      :sign -> cond do
        is_digit(char) -> [:int, false]
        true -> [:fail, false]
      end
      :paren_open -> cond do
        true -> [:fail, false]
      end
      :paren_close -> cond do
        true -> [:fail, false]
      end
      :space -> cond do
        true -> [:fail, false]
      end
      :comment_start -> cond do
        true -> [:fail, false]
      end
      :comment_line -> cond do
        true -> [:fail, false]
      end
      :fail -> [:fail, false]
    end
  end

  # Helper function to check if a character is a digit
  def is_digit(char) do
    "0123456789"
    |> String.graphemes()
    |> Enum.member?(char)
  end

  # Helper function to check if a character is an alphabet
  def is_alapha(char) do
    lowercase = ?a..?z |> Enum.map(&<<&1::utf8>>)
    uppercase = ?A..?Z |> Enum.map(&<<&1::utf8>>)
    Enum.member?(lowercase ++ uppercase, char)
  end

  # Helper function to check if a character is a sign
  def is_sign(char) do
    Enum.member?(["+", "-"], char)
  end

  # Helper function to check if a character is an operator
  def is_operator(char) do
    Enum.member?(["+", "-", "*", "/", "%", "^", "="], char)
  end

end
