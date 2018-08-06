defmodule SecretMessagesBot do
  use Application
  alias Alchemy.Client
  alias SecretMessagesBot.Commands
  use Alchemy.Cogs

  def start(_type, _args) do
    run = Client.start(Application.fetch_env!(:secret_messages_bot, :token))
    use Commands
    Cogs.set_prefix("!!")
    run
  end
end
