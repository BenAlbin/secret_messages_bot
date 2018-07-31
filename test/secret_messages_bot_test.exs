defmodule SecretMessagesBotTest do
  use ExUnit.Case
  doctest SecretMessagesBot

  test "greets the world" do
    assert SecretMessagesBot.hello() == :world
  end
end
