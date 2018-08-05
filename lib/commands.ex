defmodule SecretMessagesBot.Commands do
  alias SecretMessagesBot.{Game, GameSupervisor}
  alias Alchemy.Client

  use Alchemy.Cogs

  Cogs.def setup do
    with {:ok, guild_id} <- Cogs.guild_id(),
      [] <- :ets.lookup(:game_state, guild_id),
      {:ok, _pid} <- GameSupervisor.start_game(guild_id)
    do
      Cogs.say "Game incoming, type !!join to join"
    else
      [{_key, _state}] -> Cogs.say "Game already in progress"
    end
  end

  Cogs.def join do
    with {:ok, member} <- Cogs.member(),
      {:ok, guild_id} <- Cogs.guild_id(),
      via <- Game.via_tuple(guild_id),
      :ok <- Game.add_player(via, member.id)
    do
      Cogs.say "Player #{member.username} added to the game"
    else
      {:error, :already_exists} ->
        Cogs.say "Player already in the game"
    end
  end

  Cogs.def ready do
    with {:ok, member} <- Cogs.member(),
      {:ok, guild_id} <- Cogs.guild_id(),
      via <- Game.via_tuple(guild_id),
      :ok <- Game.ready_up(via, member.id)
    do
      Cogs.say "You are ready!"
    end
  end

  Cogs.def finish do
    with {:ok, guild_id} <- Cogs.guild_id(),
      [{_key, _state}] <- :ets.lookup(:game_state, guild_id)
    do
      Cogs.say "Game finished. Don't blame me if you did this accidentally\
, please send me a message if this is an issue or something and I'll fix it"
    else
      [] -> Cogs.say "No game is currently running, please start a game if\
 you wish to end one"
    end
  end
end
