defmodule SecretMessagesBot.GameSup do
  use DynamicSupervisor

  alias SecretMessagesBot.Game

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_child(name) do
    spec = {Game.Server, name: name}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(
      strategy: :one_for_one
    )
  end
end
