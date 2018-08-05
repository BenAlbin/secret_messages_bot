defmodule SecretMessagesBot do
  use Application
  alias Alchemy.Client
  alias SecretMessagesBot.Commands
  use Alchemy.Cogs

  def start(_type, _args) do
    run = Client.start(System.get_env("DISCORD_KEY"))
    use Commands
    Cogs.set_prefix("!!")
    run
  end
end
