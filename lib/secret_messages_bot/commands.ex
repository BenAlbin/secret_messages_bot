defmodule SecretMessagesBot.Commands do
  alias SecretMessagesBot.{Game, GameSupervisor, Permissions}
  alias Alchemy.Client

  use Alchemy.Cogs

  Cogs.def setup do
    with {:ok, guild_id} <- Cogs.guild_id(),
         {:ok, _pid} <- GameSupervisor.start_game(guild_id)
    do
      Cogs.say "Game incoming, type !!join to join"
    else
      _ -> Cogs.say "Something went wrong, idk fuck it dawg"
    end
  end

  Cogs.def join do
    with {:ok, member} <- Cogs.member(),
         {:ok, guild_id} <- Cogs.guild_id(),
         via <- Game.via_tuple(guild_id)
    do
      member_string = "#{member.username}##{member.discriminator}"
      Game.add_player(via, member_string)
      set_up_channel(guild_id, member)
    end
  end

  # Cogs.def ready do
  #   with {:ok, member} <- Cogs.member(),
  #
  # end


  defp set_up_channel(guild_id, member) do
    alias Alchemy.OverWrite
    member_string = "#{member.username}##{member.discriminator}"
    {:ok, roles} = Client.get_roles(guild_id)
    everyone_role_id = Enum.find(roles, fn x -> x.name == "everyone" end).id
    permissions_user = %OverWrite{id: member.id,
                                  type: "member",
                                  allow: Permissions.channel_owner_perms(),
                                  deny: 0}
    permissions_all = %OverWrite{id: everyone_role_id,
                                 type: "role",
                                 allow: 0,
                                 deny: Permissions.all_permissions()}
    {:ok, role} = Client.create_role(guild_id,
                                     member_string,
                                     hoist: true,
                                     mentionable: true)
    Client.create_channel(guild_id,
                               member_string,
                               permission_overwrites: [permissions_user,
                                                       permissions_all])
    end
end
