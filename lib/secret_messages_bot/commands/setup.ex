defmodule SecretMessagesBot.Commands.Setup do
  use SecretMessagesBot.Commands

  def do_setup(%{channel_id: channel_id} = message) do
    with {:ok, guild_id} <- Cache.guild_id(channel_id),
      [] <- :ets.lookup(:game_state, guild_id)
    do
      {:ok, _pid} = GameSup.start_child(guild_id)
      :ok = Game.set_main_channel(guild_id, channel_id)
      {:ok, :game_started}
    else
      [{_key, _state}] -> {:error, :game_already_exists}
    end
  end
end
