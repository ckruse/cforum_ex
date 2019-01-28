defmodule Cforum.Forums.Message do
  use CforumWeb, :model

  import CforumWeb.Gettext
  import Cforum.Helpers

  alias Cforum.Accounts.User

  @primary_key {:message_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :message_id}

  @default_preloads [:user, :tags, :cites, votes: :user, close_votes: :voters, versions: :user]
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
    has_many(:versions, Cforum.Forums.MessageVersion, foreign_key: :message_id, on_delete: :delete_all)

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

  defp base_changeset(struct, params, user, forum_id, visible_forums, opts) do
    struct
    |> cast(params, [:author, :email, :homepage, :subject, :content, :problematic_site, :forum_id])
    |> maybe_put_change(:forum_id, forum_id)
    |> validate_forum_id(visible_forums)
    |> maybe_set_author(user)
    |> Cforum.Helpers.strip_changeset_changes()
    |> Cforum.Helpers.changeset_changes_to_normalized_newline()
    |> parse_tags(params, user, opts[:create_tags])
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
  def changeset(struct, params, user, visible_forums, thread, message \\ nil, opts \\ [create_tags: false])

  def changeset(struct, params, user, visible_forums, thread, nil, opts) do
    struct
    |> base_changeset(params, user, thread.forum_id, visible_forums, opts)
    |> put_change(:thread_id, thread.thread_id)
    |> validate_required([:author, :subject, :content, :forum_id, :thread_id])
  end

  def changeset(struct, params, user, visible_forums, thread, message, opts) do
    struct
    |> base_changeset(params, user, thread.forum_id, visible_forums, opts)
    |> put_change(:thread_id, thread.thread_id)
    |> put_change(:parent_id, message.message_id)
    |> validate_required([:author, :subject, :content, :forum_id, :thread_id])
  end

  def new_or_update_changeset(struct, params, user, visible_forums, opts \\ [create_tags: false]) do
    struct
    |> base_changeset(params, user, nil, visible_forums, opts)
    |> validate_required([:author, :subject, :content])
  end

  def update_changeset(struct, params, user, visible_forums, opts \\ [create_tags: false]) do
    struct
    |> new_or_update_changeset(params, user, visible_forums, opts)
    |> maybe_set_editor_id(user)
    |> set_editor_author(struct, user)
  end

  defp parse_tags(changeset, %{"tags" => tags}, user, create_tags) do
    tags =
      tags
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&blank?/1)
      |> Enum.map(&String.downcase/1)

    parse_tags(changeset, tags, user, create_tags)
  end

  defp parse_tags(changeset, %{}, _, _), do: changeset

  defp parse_tags(changeset, tags, user, create_tags) do
    {known_tags, unknown_tags} = maybe_create_tags(tags, user, create_tags)

    if blank?(unknown_tags) do
      put_assoc(changeset, :tags, known_tags)
    else
      changeset
      |> put_assoc(:tags, Enum.map(tags, &%Cforum.Forums.Tag{tag_name: &1}))
      |> add_error(:tags, gettext("unknown tags given: %{tags}", tags: Enum.join(unknown_tags, ", ")))
      |> add_tag_errors(unknown_tags)
    end
  end

  defp maybe_create_tags(tags, _user, false) do
    known_tags = Cforum.Forums.Tags.get_tags(tags)

    unknown_tags =
      Enum.filter(tags, fn tag ->
        Enum.find(known_tags, &(&1.tag_name == tag)) == nil
      end)

    {known_tags, unknown_tags}
  end

  defp maybe_create_tags(tags, user, true) do
    known_tags = Cforum.Forums.Tags.get_tags(tags)

    unknown_tags =
      tags
      |> Enum.filter(fn tag -> Enum.find(known_tags, &(&1.tag_name == tag)) == nil end)
      |> Enum.map(fn tag ->
        {:ok, tag} = Cforum.Forums.Tags.create_tag(user, %{tag_name: tag})
        tag
      end)

    {known_tags ++ unknown_tags, []}
  end

  defp add_tag_errors(changeset, unknown_tags) do
    tags =
      Enum.map(get_change(changeset, :tags, []), fn tag ->
        if Enum.find(unknown_tags, &(&1 == get_field(tag, :tag_name))) != nil,
          do: add_error(tag, :tag_name, gettext("is unknown")),
          else: tag
      end)

    put_change(changeset, :tags, tags)
  end

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

  defp maybe_set_editor_id(changeset, nil), do: changeset
  defp maybe_set_editor_id(changeset, user), do: put_change(changeset, :editor_id, user.user_id)
  defp set_editor_author(changeset, message, nil), do: put_change(changeset, :edit_author, message.author)
  defp set_editor_author(changeset, _, user), do: put_change(changeset, :edit_author, user.username)
end
