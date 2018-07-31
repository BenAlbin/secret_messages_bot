defmodule SecretMessagesBot do
  use Application
  alias Alchemy.Client
  alias SecretMessagesBot.Commands

  def start(_type, _args) do
    run = Client.start(System.get_env("DISCORD_KEY"))
    use Commands
    run
    Cogs.set_prefix("!!")
  end
end
