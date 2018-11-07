defmodule SecretMessagesBot.Commands.Imports do
  defmacro __using__(_opts) do
    quote do
      alias SecretMessagesBot.Game
      alias SecretMessagesBot.GameSup
      alias SecretMessagesBot.Chat
      alias Alchemy.Client
      alias Alchemy.Cache

      def check_channel(channel_one, channel_two) do
        if channel_one == channel_two do
          :ok
        else
          {:error, :not_correct_channel}
        end
      end
    end
  end
end
