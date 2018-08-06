defmodule SecretMessagesBot.Game.Server do
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient
  alias SecretMessagesBot.{Game.Impl, Game}

  @timeout 60*60*1000

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: Game.via_tuple(name))
  end

  def init(name) do
    send(self(), {:set_state, name})
    {:ok, Impl.new(name)}
  end

  def terminate({:shutdown, :timeout}, state_data) do
    :ets.delete(:game_state, state_data.guild)
  end

  def terminate(_reason, _state) do
    :ok
  end

  def handle_info(:timeout, state_data) do
    {:stop, {:shutdown, :timeout}, state_data}
  end

  def handle_info({:set_state, name}, _state_data) do
    state_data =
      case :ets.lookup(:game_state, name) do
        [] -> Impl.new(name)
        [{_key, state}] -> state
      end
    :ets.insert(:game_state, {name, state_data})
    {:noreply, state_data, @timeout}
  end

  def handle_call({:set_main_channel, channel_id}, _from, state_data) do
    state_data
    |> Impl.put_main_channel(channel_id)
    |> handle_result(state_data)
  end

  def handle_call({:get_main_channel}, _from, state_data) do
    {:reply, {:ok, state_data.main_channel}, state_data}
  end

  def handle_call({:add_player, player_id}, _from, state_data) do
    state_data
    |> Impl.put_player(player_id)
    |> handle_result(state_data)
  end

  def handle_call({:get_player, player_id}, _from,
    %{players: players} = state_data) do
    case players[player_id] do
      nil -> {:reply, {:error, :player_not_exist}, state_data}
      player -> {:reply, {:ok, player}, state_data}
    end
  end

  def handle_call({:ready_up, player_id}, _from, state_data) do
    state_data
    |> Impl.update_status(player_id, :ready)
    |> Impl.end_round_if_all_ready()
    |> handle_result(state_data)
  end

  def handle_call({:add_marker, player_id, message_id}, _from, state_data) do
    state_data
    |> Impl.update_marker(player_id, message_id)
    |> handle_result(state_data)
  end

  def handle_call({:remove_player, player_id}, _from, state_data) do
    state_data
    |> Impl.delete_player(player_id)
    |> handle_result(state_data)
  end

  defp handle_result({:ok, result}, _state_data) do
    :ets.insert(:game_state, {result.guild, result})
    {:reply, :ok, result, @timeout}
  end

  defp handle_result({:error, reason}, state_data) do
    {:reply, {:error, reason}, state_data}
  end
end
