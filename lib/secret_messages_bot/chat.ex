defmodule SecretMessagesBot.Chat do
  alias Alchemy.{Client}
  alias SecretMessagesBot.{Player, Embed, Permissions}

  @marker_message "======="

  def round_end_message(%{guild: guild_id, players: players, main_channel: main_channel}) do
    ## get messages and post in embed
    embed = players
    |> Enum.map(fn {id, player} ->
      %{get_username(guild_id, id) => get_messages(player)} end)
    |> Embed.create_embed()

    Client.send_message(main_channel, "", embed: embed)
  end

  defp get_username(guild_id, id) do
    {:ok, %{user: user}} = Client.get_member(guild_id, id)
    user.username
  end

  def get_messages(%Player{channel: channel_id,
    last_marker: last_marker}) do
    case Client.get_messages(channel_id, after: last_marker, limit: 5) do
      {:ok, message_list} -> message_list
      {:error, _} -> ["An error ocurred here"]
    end
  end

  def new_player_channel(guild_id, player_id) do
    alias Alchemy.OverWrite
    {:ok, %{user: user, nick: nick}} =
      Client.get_member(guild_id, player_id)
    {:ok, roles} = Client.get_roles(guild_id)
    everyone_role_id = Enum.find(roles, &(&1.position == 0)).id
    permissions_user = %OverWrite{
      id: user.id,
      type: "member",
      allow: Permissions.channel_owner_perms(),
      deny: 0
    }
    permissions_all = %OverWrite{
      id: everyone_role_id,
      type: "role",
      allow: 0,
      deny: Permissions.all_permissions()
    }
    Client.create_channel(
      guild_id,
      nick || user.username,
      permission_overwrites: [permissions_user, permissions_all]
    )
  end

  def new_marker(%Player{channel: channel_id} = player) do
    with {:ok, message} =
      Client.send_message(channel_id, @marker_message)
    do
      %{player | last_marker: message.id}
    end
  end

  def send_marker(channel_id) do
    Client.send_message(channel_id, @marker_message)
  end

  def delete_channels(%{players: players}) do
    Enum.each(players, fn {_id, %{channel: channel_id}} ->
      Client.delete_channel(channel_id) end)
    :ok
  end
end
