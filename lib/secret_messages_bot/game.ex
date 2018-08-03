defmodule SecretMessagesBot.Game do
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient

  alias SecretMessagesBot.{State, Player}

  @timeout 60*60*1000

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def via_tuple(name) do
    {:via, Registry, {Registry.Game, name}}
  end

  def add_player(game, player_id, channel_id) do
    GenServer.call(game, {:add_player, player_id})
  end

  def ready_up(game, player_id) do
    GenServer.call(game, {:ready_up, player_id})
  end

  def round_end(game) do
    GenServer.call(game, {:round_end})
  end

  ###

  def init(name) do
    send(self(), {:set_state, name})
    {:ok, fresh_state(name)}
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
        [] -> fresh_state(name)
        [{_key, state}] -> state
      end
    :ets.insert(:game_state, {name, state_data})
    {:noreply, state_data, @timeout}
  end

  def handle_call({:add_player, player_id, channel_id}, _from, state_data) do
    case Enum.any?(state_data.players, fn {id, _struct} -> id == player_id  end) do
      false -> state_data
               |> add_player_to_list(player_id, channel_id)
               |> reply_success(:ok)
      _ -> {:reply, {:error, :player_in_game}, state_data}
    end
  end

  def handle_call({:ready_up, player_id}, _from, state_data) do
    case Enum.any?(state_data.players, fn x -> x.id == player_id end) do
      true -> state_data
              |> ready_player_up(player_id)
              |> reply_success(:ok)
      _    -> {:reply, :error, state_data}
    end
  end

  def handle_call({:round_end}, _from, state_data) do
    case Enum.any?(state_data.players, fn x -> x.status == :not_ready end) do
      false -> state_data
               |> unready_players()
               |> reply_success(:ok)
      _     -> {:reply, {:error, :not_all_ready}, state_data}
    end
  end

  ##

  defp add_player_to_list(%{players: players} = state_data,
                           player_id, channel_id) do
    %{state_data | players: Map.put(players, player_id, Player.new(channel_id))}
  end

  defp ready_player_up(%{players: players} = state_data, player_id) do
    players[player_id]
  end

  defp unready_players(%{players: players} = state_data) do
    players = Enum.map(players, fn x -> %{x | status: :not_ready} end)
    %{state_data | players: players}
  end

  defp ready_one(players, player_id) do
    players = %{players | player_id => %{players[player_id] | status: :ready}}
  end

  defp fresh_state(name) do
    guild = name
    players = %{}
    %{guild: guild, players: players}
  end

  defp reply_success(state_data, reply) do
    :ets.insert(:game_state, {state_data.guild, state_data})
    {:reply, reply, state_data, @timeout}
  end
end
