defmodule Cforum.Accounts.ForumGroupPermission do
  use CforumWeb, :model
  alias Cforum.Accounts.ForumGroupPermission

  @primary_key {:forum_group_permission_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :forum_group_permission_id}

  @moderate "moderate"
  def moderate, do: @moderate

  @write "write"
  def write, do: @write

  @read "read"
  def read, do: @read

  @known_write "known-write"
  def known_write, do: @known_write

  @known_read "known-read"
  def known_read, do: @known_read

  @permissions [@moderate, @write, @read]

  schema "forums_groups_permissions" do
    field(:permission, :string)

    belongs_to(:group, Cforum.Accounts.Group, references: :group_id)
    belongs_to(:forum, Cforum.Forums.Forum, references: :forum_id)
  end

  @doc false
  def changeset(%ForumGroupPermission{} = forum_group_permission, attrs) do
    forum_group_permission
    |> cast(attrs, [:permission, :forum_id])
    |> validate_required([:permission, :forum_id])
    |> validate_inclusion(:permission, @permissions)
  end
end
