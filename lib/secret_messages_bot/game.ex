defmodule SecretMessagesBot.Game do
  def via_tuple(name) do
    {:via, Registry, {Registry.Game, name}}
  end

  def set_main_channel(guild_id, channel_id) do
    GenServer.call(via_tuple(guild_id), {:set_main_channel, channel_id})
  end

  def get_main_channel(guild_id) do
    GenServer.call(via_tuple(guild_id), {:get_main_channel})
  end

  def add_player(guild_id, player_id) do
    GenServer.call(via_tuple(guild_id), {:add_player, player_id})
  end

  def get_player(guild_id, player_id) do
    GenServer.call(via_tuple(guild_id), {:get_player, player_id})
  end

  def ready_up(guild_id, player_id) do
    GenServer.call(via_tuple(guild_id), {:ready_up, player_id})
  end

  def add_marker(guild_id, player_id, message_id) do
    GenServer.call(via_tuple(guild_id), {:add_marker, player_id, message_id})
  end

  def remove_player(guild_id, player_id) do
    GenServer.call(via_tuple(guild_id), {:remove_player, player_id})
  end
end
