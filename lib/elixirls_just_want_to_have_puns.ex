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

  def handle_response(_) do
    IO.puts "SUCCESS"
    # { :ok, :jsx.decode(body) }
  end
end

IO.puts "\n\n"
IO.puts ElixirlsJustWantToHavePuns.fetch("heart")
IO.puts "\n\n"
