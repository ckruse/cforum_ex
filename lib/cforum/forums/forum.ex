defmodule Cforum.Forums.Forum do
  use CforumWeb, :model

  @primary_key {:forum_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :slug}

  @read "read"
  @write "write"
  @known_read "known-read"
  @known_write "known-write"

  def read(), do: @read
  def write(), do: @write
  def known_read(), do: @known_read
  def known_write(), do: @known_write

  schema "forums" do
    field :slug, :string
    field :short_name, :string
    field :name, :string
    field :description, :string
    field :standard_permission, :string
    field :keywords, :string
    field :position, :integer

    has_many :threads, Cforum.Forums.Thread
    has_many :messages, Cforum.Forums.Message

    timestamps(inserted_at: :created_at)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:slug, :short_name, :name, :description, :standard_permission, :keywords, :position])
    |> validate_required([:slug, :short_name, :name, :description, :standard_permission, :position])
    |> unique_constraint(:slug)
  end

  def ordered(query) do
    query |> order_by([n], asc: n.position)
  end

  def visible_forums(query, user \\ nil)
  def visible_forums(query, user) when user == nil do
    from f in query,
      where: f.standard_permission in [^@read, ^@write]
  end
  def visible_forums(query, %Cforum.Accounts.User{admin: true}) do # admins may view all forums
    query
  end
  def visible_forums(query, user) do
    from f in query,
      where: f.standard_permission in [^@read, ^@write, ^@known_read, ^@known_write] or
             fragment("? IN (SELECT forum_id FROM forums_groups_permissions INNER JOIN groups_users USING(group_id) WHERE user_id = ?)", f.forum_id, ^user.user_id)
  end
end
