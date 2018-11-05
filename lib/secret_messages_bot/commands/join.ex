defmodule SecretMessagesBot.Commands.Join do
  use SecretMessagesBot.Commands

  def do_join(%{channel_id: channel_id, author: author} = message) do
    with {:ok, guild_id} <- Cache.guild_id(channel_id),
      Game.add_player(guild_id, author.id)
    do
      {:ok, "foo"}
    end
  end
end
