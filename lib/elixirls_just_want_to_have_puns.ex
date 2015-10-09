defmodule RhymebrainResult do
  @derive [Poison.Encoder]
  defstruct [:word, :score]
end

defmodule Pun do
  defstruct [:original_phrase, :pun_phrase]

  def make(original_phrase, original_word, %{word: result_word}) do
    pun_phrase = PunFinder.replace(original_phrase, result_word, original_word)
    %Pun{original_phrase: original_phrase, pun_phrase: pun_phrase}
  end
end

defimpl String.Chars, for: Pun do
  def to_string(%{pun_phrase: pun_phrase, original_phrase: original_phrase}) do
    "#{pun_phrase} (pun of: #{original_phrase})"
  end
end

defimpl String.Chars, for: RhymebrainResult do
  def to_string(%{word: word, score: score }) do
    "word: #{word} / score: #{score}"
  end
end

defmodule ElixirlsJustWantToHavePuns do
  def main([word]) do
    Enum.each(run(word), &(IO.puts(&1)))
  end

  def run(word) do
    RhymebrainResults.for(word)
    |> Enum.flat_map(&(puns(word, &1)))
  end

  def puns(original_word, rhymebrain_result) do
    Phrases.with_word(rhymebrain_result.word)
    |> Enum.map(&(Pun.make(&1, original_word, rhymebrain_result)))
  end
end

defmodule RhymebrainResults do
  import Enum

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
    max_score(results) |> find_all_with_score(results)
  end

  def find_all_with_score(max, results) do
    filter(results, &(&1.score == max))
  end

  def max_score(results) do
    max_by(results, &(&1.score)).score
  end
end

defmodule Phrases do
  def files do
    [
      "./phrases/beatles-songs.txt",
      "./phrases/best-selling-books.txt",
      "./phrases/movie-quotes.txt",
      "./phrases/oscar-winning-movies.txt",
      "./phrases/wikipedia-idioms.txt",
    ]
  end

  def with_word(word) do
    Enum.flat_map(files, &(file_with_word(&1, word)))
  end

  def file_with_word(file, word) do
    File.stream!(file)
    |> Enum.map(&(String.strip(&1)))
    |> Enum.filter(&(PunFinder.contains?(&1, word)))
  end
end

defmodule PunFinder do
  def contains?(phrase, word) do
    solitary(word)
    |> Regex.match?(phrase)
  end

  def replace(original_phrase, original_word, new_word) do
    solitary(original_word)
    |> Regex.replace(original_phrase, new_word)
  end

  def solitary(word) do
    ~r/\b#{word}\b/i
  end
end
