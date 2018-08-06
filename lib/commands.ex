defmodule SecretMessagesBot.Commands do
  alias SecretMessagesBot.{Game, GameSupervisor, Chat}
  alias Alchemy.Client

  use Alchemy.Cogs

  Cogs.def setup do
    with {:ok, guild_id} <- Cogs.guild_id(),
      [] <- :ets.lookup(:game_state, guild_id),
      {:ok, _pid} <- GameSupervisor.start_game(guild_id),
      via <- Game.via_tuple(guild_id),
      :ok <- Game.set_main_channel(via, Cogs.channel_id!())
    do
      Cogs.say "Game incoming, type !!join to join"
    else
      [{_key, _state}] -> Cogs.say "Game already in progress"
    end
  end

  Cogs.def join do
    with user <- Cogs.user!(),
      {:ok, guild_id} <- Cogs.guild_id(),
      via <- Game.via_tuple(guild_id),
      :ok <- Game.add_player(via, user.id)
    do
      Cogs.say "Player #{user.username} added to the game"
    else
      {:error, :already_exists} ->
        Cogs.say "Player already in the game"
      {:error, reason} ->
        Cogs.say "Error with reason: #{reason}"
      _ ->
        Cogs.say "Something else went wrong"
    end
  end

  Cogs.def ready do
    with user_id <- Cogs.user_id!(),
      {:ok, guild_id} <- Cogs.guild_id(),
      via <- Game.via_tuple(guild_id),
      {:ok, %{channel: channel}} <- Game.get_player(via, user_id),
      ^channel <- Cogs.channel_id!()
    do
      Game.ready_up(via, user_id)
    else
      _ -> Cogs.say "Something went wrong, make sure you type !!ready in your\
 own channel"
    end
  end

  Cogs.def finish do
    with {:ok, guild_id} <- Cogs.guild_id(),
      [{_key, state}] <- :ets.lookup(:game_state, guild_id),
      :ok <- Chat.delete_channels(state),
      :ok <- GameSupervisor.stop_game(guild_id)
    do
      Cogs.say "Game finished. Don't blame me if you did this accidentally\
, please send me a message if this is an issue or something and I'll fix it"
    else
      [] -> Cogs.say "No game is currently running, please start a game if\
 you wish to end one"
    end
  end
end
