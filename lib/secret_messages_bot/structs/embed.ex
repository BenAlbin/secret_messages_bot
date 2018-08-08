defmodule SecretMessagesBot.Embed do
  use Alchemy.Cogs

  alias Alchemy.Embed

  def create_embed(message_map) do
    embed = %Embed{}
    |> Embed.title("Round complete!")
    |> Embed.description("Messages sent in the last round:")

    Enum.reduce(message_map, embed, fn player_messages, acc ->
      add_messages(acc, player_messages) end)
  end

  def add_messages(%Embed{} = embed, player_messages) do
    player_name = hd(Map.keys(player_messages))
    message = parse_message_list(player_messages[player_name])
    Embed.field(embed, player_name, message)
  end

  defp parse_message_list(message_list) do
    message_list
    |> Enum.map(fn %{content: content} -> content end)
    |> Enum.filter(fn x -> x != "!!ready" end)
    |> Enum.reverse()
    |> Enum.join(" | ")
  end
end
