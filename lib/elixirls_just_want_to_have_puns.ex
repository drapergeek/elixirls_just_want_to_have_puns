defmodule RhymebrainResult do
  @derive [Poison.Encoder]
  defstruct [:word, :score]
end

defimpl String.Chars, for: RhymebrainResult do
  def to_string(rhymebrain_result) do
    "word: #{rhymebrain_result.word} / score: #{rhymebrain_result.score}"
  end
end

defmodule ElixirlsJustWantToHavePuns do
  def fetch(word) do
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
    |> max_score
  end

  def max_score({:ok, results}) do
    Enum.max_by(results, &(&1.score))
  end
end

IO.puts "\n\n"
IO.puts ElixirlsJustWantToHavePuns.fetch("heart")
IO.puts "\n\n"
