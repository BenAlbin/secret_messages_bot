defmodule SecretMessagesBot.Embed do
  use Alchemy.Cogs

  alias Alchemy.Embed

  def create_embed(message_map) do
    embed = %Embed{}
    |> Embed.title("Round complete!")
    |> Embed.description("Messages sent in the last round:")

    Enum.reduce(message_map, embed, fn {player_name, messages}, acc ->
                                acc |> add_messages(player_name, messages) end)
  end

  def add_messages(%Embed{} = embed, player_name, message_list) do
    embed
    |> Embed.field(player_name, Enum.join(message_list, "\n"))
  end
end
