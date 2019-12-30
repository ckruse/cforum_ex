defmodule Cforum.Groups.ForumGroupPermission do
  use CforumWeb, :model
  use Cforum.Constants
  alias Cforum.Groups.ForumGroupPermission

  @primary_key {:forum_group_permission_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :forum_group_permission_id}

  schema "forums_groups_permissions" do
    field(:permission, :string)

    belongs_to(:group, Cforum.Groups.Group, references: :group_id)
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
