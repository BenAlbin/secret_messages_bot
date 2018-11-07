defmodule SecretMessagesBot.Commands.Finish do
  use SecretMessagesBot.Commands.Imports

  def do_finish(%{channel_id: channel_id} = _message) do
    with {:ok, guild_id} <- Cache.guild_id(channel_id),
      # Check if game actually running, and extract main channel
      [{_key, %{main_channel: main_channel} = state}] <-
        :ets.lookup(:game_state, guild_id),
      # Make sure this command is put in main channel, so all players know
      :ok <- check_channel(main_channel, channel_id)
    do
      __MODULE__.clean_up(guild_id, state)
    else
      [] -> {:error, :no_game_running}
      {:error, :not_correct_channel} -> {:error, :not_correct_channel}
      {:error, :dirty_cleanup} -> {:error, :dirty_cleanup}
    end
  end

  def clean_up(_guild_id, state) do
    Chat.delete_channels(state)
  end
end
