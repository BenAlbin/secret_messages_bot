defmodule SecretMessagesBot.Commands.Ready do
  use SecretMessagesBot.Commands

  def do_ready(%{channel_id: channel_id, author: author} = message) do
    user_id = author.id
    with {:ok, guild_id} = Cache.guild_id(channel_id),
      ^channel_id <- Game.get_player(via, user_id)
    do
      Game.ready_up(via, user_id)
    else
      # Typespec for Alchemy.Cache.guild_id incorrect. Does not return :none
      {:error, _} -> {:error, :channel_not_cached}
      _ -> {:error, :wrong_channel_ready}
    end
  end
end
