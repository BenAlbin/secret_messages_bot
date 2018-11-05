defmodule SecretMessagesBot.Permissions do
  use Bitwise

  @perms [
    :create_instant_invite,
    :kick_members,
    :ban_members,
    :administrator,
    :manage_channels,
    :manage_guild,
    :add_reactions,
    :view_audit_log,
    :read_messages,
    :send_messages,
    :send_tts_messages,
    :manage_messages,
    :embed_links,
    :attach_files,
    :read_message_history,
    :mention_everyone,
    :use_external_emojis,
    :connect,
    :speak,
    :mute_members,
    :deafen_members,
    :move_members,
    :use_vad,
    :change_nickname,
    :manage_nicknames,
    :manage_roles,
    :manage_webhooks,
    :manage_emojis
  ]

  @perm_map Stream.zip(@perms, Enum.map(0..28, &(1 <<< &1)))
  |> Enum.into(%{})

  @spec add_permission(integer(), atom()) :: integer()
  def add_permission(bitset, permission) do
    bitset ||| @perm_map[permission]
  end

  @spec remove_permission(integer(), atom()) :: integer()
  def remove_permission(bitset, permission) do
    bitset &&& bnot(@perm_map[permission])
  end

  def all_permissions() do
    Enum.reduce(@perms, 0, fn perm, acc -> add_permission(acc, perm) end)
    |> remove_permission(:administrator)
  end

  def no_permissions() do
    0
  end

  def channel_owner_perms() do
    0
    |> add_permission(:read_messages)
    |> add_permission(:send_messages)
    |> add_permission(:read_message_history)
  end
end
