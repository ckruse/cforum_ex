defmodule Cforum.Forums.Message do
  use CforumWeb, :model

  import CforumWeb.Gettext
  import Cforum.Helpers

  alias Cforum.Accounts.User

  @primary_key {:message_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :message_id}

  @default_preloads [:user, :tags, :cites, votes: :user, close_votes: :voters]
  def default_preloads, do: @default_preloads

  schema "messages" do
    field(:upvotes, :integer, default: 0)
    field(:downvotes, :integer, default: 0)
    field(:deleted, :boolean, default: false)
    field(:mid, :integer)
    field(:author, :string)
    field(:email, :string)
    field(:homepage, :string)
    field(:subject, :string)
    field(:content, :string)
    field(:flags, :map, default: %{})
    field(:uuid, :string)
    field(:ip, :string)
    field(:format, :string, default: "markdown")
    field(:edit_author, :string)
    field(:problematic_site, :string)

    field(:messages, :any, virtual: true)
    field(:attribs, :map, virtual: true, default: %{classes: []})

    belongs_to(:thread, Cforum.Forums.Thread, references: :thread_id)
    belongs_to(:forum, Cforum.Forums.Forum, references: :forum_id)
    belongs_to(:user, Cforum.Accounts.User, references: :user_id)
    belongs_to(:parent, Cforum.Forums.Message, references: :message_id)
    belongs_to(:editor, Cforum.Accounts.User, references: :user_id)

    has_many(:cites, Cforum.Cites.Cite, foreign_key: :message_id, on_delete: :nilify_all)

    many_to_many(
      :tags,
      Cforum.Forums.Tag,
      join_through: Cforum.Forums.MessageTag,
      join_keys: [message_id: :message_id, tag_id: :tag_id]
    )

    has_many(:votes, Cforum.Forums.Vote, foreign_key: :message_id)
    has_many(:close_votes, Cforum.Forums.CloseVote, foreign_key: :message_id)

    timestamps(inserted_at: :created_at)
  end

  defp base_changeset(struct, params, user, forum_id, visible_forums) do
    struct
    |> cast(params, [:author, :email, :homepage, :subject, :content, :problematic_site, :forum_id])
    |> maybe_put_change(:forum_id, forum_id)
    |> validate_forum_id(visible_forums)
    |> maybe_set_author(user)
    |> Cforum.Helpers.strip_changeset_changes()
    |> parse_tags(params)
  end

  defp maybe_put_change(changeset, _, nil), do: changeset
  defp maybe_put_change(changeset, field, value), do: put_change(changeset, field, value)

  defp validate_forum_id(changeset, visible_forums) do
    case get_field(changeset, :forum_id) do
      nil ->
        changeset

      forum_id ->
        if Enum.find(visible_forums, &(&1.forum_id == forum_id)) == nil,
          do: add_error(changeset, :forum_id, "is invalid"),
          else: changeset
    end
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params, user, visible_forums, thread, message \\ nil)

  def changeset(struct, params, user, visible_forums, thread, nil) do
    struct
    |> base_changeset(params, user, thread.forum_id, visible_forums)
    |> put_change(:thread_id, thread.thread_id)
    |> validate_required([:author, :subject, :content, :forum_id, :thread_id])
  end

  def changeset(struct, params, user, visible_forums, thread, message) do
    struct
    |> base_changeset(params, user, thread.forum_id, visible_forums)
    |> put_change(:thread_id, thread.thread_id)
    |> put_change(:parent_id, message.message_id)
    |> validate_required([:author, :subject, :content, :forum_id, :thread_id])
  end

  def changeset(struct, params, user, visible_forums) do
    struct
    |> base_changeset(params, user, nil, visible_forums)
    |> validate_required([:author, :subject, :content])
  end

  defp parse_tags(changeset, %{"tags" => tags}) when is_list(tags) do
    tags =
      tags
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&blank?/1)
      |> Enum.map(&String.downcase/1)

    known_tags = Cforum.Forums.Tags.get_tags(get_field(changeset, :forum_id), tags)

    unknown_tags =
      Enum.filter(tags, fn tag ->
        Enum.find(known_tags, &(&1.tag_name == tag)) == nil
      end)

    # TODO for now we just error out on unknown tags
    if blank?(unknown_tags) do
      put_assoc(changeset, :tags, known_tags)
    else
      changeset
      |> put_assoc(:tags, known_tags)
      |> add_error(:tags, gettext("unknown tags given: %{tags}", tags: Enum.join(unknown_tags, ", ")))
    end
  end

  defp parse_tags(changeset, _), do: changeset

  defp maybe_set_author(changeset, %User{} = author) do
    case get_field(changeset, :author) do
      nil ->
        changeset
        |> put_change(:author, author.username)

      _ ->
        changeset
    end
    |> put_change(:user_id, author.user_id)
  end

  defp maybe_set_author(changeset, nil), do: changeset
end
