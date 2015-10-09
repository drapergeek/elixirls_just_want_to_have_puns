defmodule RhymebrainResult do
  @derive [Poison.Encoder]
  defstruct [:word, :score]
end

defmodule Pun do
  defstruct [:original, :pun]
end

defimpl String.Chars, for: RhymebrainResult do
  def to_string(rhymebrain_result) do
    "word: #{rhymebrain_result.word} / score: #{rhymebrain_result.score}"
  end
end

defmodule ElixirlsJustWantToHavePuns do
end

defmodule RhymebrainResults do
  def for(word) do
    HTTPoison.start
    rhymebrain_url(word)
    |> HTTPoison.get
    |> handle_response
  end

  def rhymebrain_url(word) do
    "http://rhymebrain.com/talk?function=getRhymes&word=#{word}&maxResults=0&lang=en"
  end

  def handle_response({:ok, %{status_code: 200, body: body}}) do
    Poison.decode(body, as: [RhymebrainResult])
    |> find_highest_scored_words
  end

  def find_highest_scored_words({:ok, results}) do
    max = max_score(results)
    length Enum.filter(results, fn (result) -> result.score == max end)
  end

  def max_score(results) do
    Enum.max_by(results, &(&1.score)).score
  end
end

defmodule Phrases do
  def beatles do
    [
      "Put the cart before the horse"
    ]
  end
end

IO.puts "\n\n"
IO.puts RhymebrainResults.for("heart")
IO.puts "\n\n"
