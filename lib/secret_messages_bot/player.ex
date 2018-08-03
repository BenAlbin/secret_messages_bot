defmodule SecretMessagesBot.Player do
  alias __MODULE__
  defstruct channel: nil,
            status: :not_ready,
            last_marker: nil

  def new() do
    %Player{}
  end

  def new(channel) do
    %Player{channel: channel}
  end
end
