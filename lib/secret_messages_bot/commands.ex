defmodule SecretMessagesBot.Commands do
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

  alias __MODULE__

  use Alchemy.Cogs


  Cogs.def setup do
    # Cogs.def injects message, so I just parse it manually to avoid macro bloat
    with {:ok, :game_started} <- Commands.Setup.do_setup(message)
    do
      Cogs.say "Game started, type !!join to join"
    else
      {:error, :game_already_exists} ->
        Cogs.say "Game already exists"
      _ ->
        Cogs.say "Something else went wrong"
    end
  end

  Cogs.def join do
    with {:ok, _} <- Commands.Join.do_join(message)
    do
      Cogs.say "Player #{user.username} added to the game"
    else
      {:error, :already_exists} ->
        Cogs.say "Player already in the game"
      {:error, reason} ->
        Cogs.say "Error with reason: #{reason}"
      _ ->
        Cogs.say "Something else went wrong"
    end
  end

  Cogs.def ready do
    with {:ok, _} <- Commands.Ready.do_ready(message)
    do
    else
      {:error, :player_not_exist} ->
        Cogs.say "No idea how you managed to get this error, but you don't exist"
      {:error, :wrong_channel_ready} ->
        Cogs.say "Please ready up in your own channel"
    end
  end

  ## TODO: Restrict this command to people with appropriate permissions.
  Cogs.def finish do
    with :ok <- Commands.Finish.do_finish(message)
    do
      Cogs.say "Game ended"
    else
      {:error, :no_game_running} ->
        Cogs.say "No game is currently running, please start a game if you wish \
to end one"
      {:error, _} -> Cogs.say "Something else went wrong"
      _not_main_channel ->
        Cogs.say "You can only use this command in the main\
 channel"
    end
  end
end
