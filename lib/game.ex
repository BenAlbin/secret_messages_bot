defmodule SecretMessagesBot.Game do
  def via_tuple(name) do
    {:via, Registry, {Registry.Game, name}}
  end

  def add_player(game, player_id) do
    GenServer.call(game, {:add_player, player_id})
  end

  def ready_up(game, player_id) do
    GenServer.call(game, {:ready_up, player_id})
  end

  def add_marker(game, player_id, message_id) do
    GenServer.call(game, {:add_marker, player_id, message_id})
  end

  def remove_player(game, player_id) do
    GenServer.call(game, {:remove_player, player_id})
  end
end
