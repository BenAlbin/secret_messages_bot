defmodule SecretMessagesBot.Game.Impl do
  @moduledoc false

  alias SecretMessagesBot.{Player, Chat}

  def new(name) do
    %{guild: name, main_channel: nil, players: %{}}
  end

  def put_main_channel(state_data, channel_id) do
    {:ok, %{state_data | main_channel: channel_id}}
  end

  def put_player(%{guild: guild_id, players: players} = state_data,
    player_id) do
    with false <- Map.has_key?(players, player_id),
      {:ok, channel} <- Chat.new_player_channel(guild_id, player_id),
      {:ok, marker} <- Chat.send_marker(channel.id)
    do
      force_channel_cache(channel.id, guild_id)
      players = Map.put_new(players, player_id, Player.new(%{
        channel: channel.id,
        last_marker: marker.id}))
      {:ok, %{state_data | players: players}}
    else
      true -> {:error, :already_exists}
      {:error, reason} -> {:error, reason}
    end
  end

  ## HACK
  defp force_channel_cache(channel_id, guild_id) do
    Alchemy.Cache.Channels.add_channels([%{"id" => channel_id}], guild_id)
  end

  def update_marker(%{players: players} = state_data, player_id, message_id) do
    case Map.has_key?(players, player_id) do
      true -> players = %{players |
        player_id => %{players[player_id] |
          last_marker: message_id}}
        {:ok, %{state_data | players: players}}
      false -> {:error, :player_not_exist}
    end
  end

  @spec update_status(map, integer, atom) ::
    {:ok, map} |
    {:error, term}
  def update_status(%{players: players} = state_data, player_id, new_status) do
    case Map.has_key?(players, player_id) do
      true -> players = %{players |
        player_id => %{players[player_id] |
          status: new_status}}
        {:ok, %{state_data | players: players}}
      false -> {:error, :player_not_exist}
    end
  end

  def update_status_all(%{players: players} = state_data, new_status) do
    players = Enum.into(players, %{}, fn {id, player} ->
      {id, %{player | status: new_status}} end)
    {:ok, %{state_data | players: players}}
  end

  def delete_player(%{players: players} = state_data, player_id) do
    case Map.has_key?(players, player_id) do
      true -> players = Map.delete(players, player_id)
              {:ok, %{state_data | players: players}}
      false -> {:error, :player_not_exist}
    end
  end

  def end_round_if_all_ready({:ok, %{players: players} = state_data}) do
    case Enum.all?(players, fn {_id, player} -> player.status == :ready end) do
      true -> do_end_round(state_data)
      false -> {:ok, state_data}
    end
  end

  def end_round_if_all_ready({:error, :player_not_exist}) do
    {:error, :player_not_exist}
  end

  defp do_end_round(%{players: players} = state_data) do
    with {:ok, _} <- Chat.round_end_message(state_data),
         players <-
           Enum.into(players, %{}, fn {id, player} ->
             {id, Chat.new_marker(player)} end)
    do
      update_status_all(%{state_data | players: players}, :not_ready)
    end
  end
end
