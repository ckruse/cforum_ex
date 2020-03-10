defmodule Cforum.Messages.Message do
  use CforumWeb, :model

  import Ecto.Query, warn: false

  alias Cforum.Helpers
  alias Cforum.Users.User
  alias Cforum.Tags.Tag
  alias Cforum.Tags
  alias Cforum.MessagesTags.MessageTag

  @primary_key {:message_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :message_id}

  @default_preloads [
    :user,
    :cites,
    votes: :user,
    versions: :user
  ]
  def default_preloads, do: @default_preloads ++ [tags: from(t in Tag, order_by: [asc: :tag_name])]

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
    field(:save_identity, :boolean, virtual: true, default: false)

    belongs_to(:thread, Cforum.Threads.Thread, references: :thread_id)
    belongs_to(:forum, Cforum.Forums.Forum, references: :forum_id)
    belongs_to(:user, Cforum.Users.User, references: :user_id)
    belongs_to(:parent, Cforum.Messages.Message, references: :message_id)
    belongs_to(:editor, Cforum.Users.User, references: :user_id)

    has_many(:cites, Cforum.Cites.Cite, foreign_key: :message_id, on_delete: :nilify_all)
    has_many(:versions, Cforum.Messages.MessageVersion, foreign_key: :message_id, on_delete: :delete_all)

    many_to_many(:tags, Tag,
      join_through: MessageTag,
      join_keys: [message_id: :message_id, tag_id: :tag_id],
      on_replace: :delete
    )

    has_many(:votes, Cforum.Votes.Vote, foreign_key: :message_id)

    timestamps(inserted_at: :created_at)
  end

  defp base_changeset(struct, params, user, forum_id, visible_forums, opts) do
    struct
    |> cast(params, [:author, :email, :homepage, :subject, :content, :problematic_site, :forum_id, :save_identity])
    |> maybe_put_change(:forum_id, forum_id)
    |> validate_forum_id(visible_forums)
    |> maybe_set_author(user, opts[:uuid])
    |> set_author_from_opts_when_unset(:author, opts[:author])
    |> Cforum.Helpers.strip_changeset_changes()
    |> Cforum.Helpers.changeset_changes_to_normalized_newline()
    |> parse_tags(params, user, opts[:create_tags])
    |> validate_tags_count()
    |> validate_length(:author, min: 2, max: 60)
    |> validate_length(:subject, min: 4, max: 250)
    |> validate_length(:email, min: 6, max: 60)
    |> validate_length(:homepage, min: 2, max: 250)
    |> validate_length(:problematic_site, min: 2, max: 250)
    |> validate_length(:content, min: 10, max: 12_288)
    |> Cforum.Helpers.validate_url(:problematic_site)
    |> Cforum.Helpers.validate_url(:homepage)
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

  defp validate_tags_count(changeset) do
    with id when not is_nil(id) <- get_field(changeset, :forum_id),
         forum <- Cforum.Forums.get_forum!(id) do
      settings = Cforum.ConfigManager.settings_map(forum, nil)

      min_tags = Cforum.ConfigManager.conf(settings, "min_tags_per_message", :int)
      max_tags = Cforum.ConfigManager.conf(settings, "max_tags_per_message", :int)

      no_tags = length(get_field(changeset, :tags, []))

      cond do
        no_tags < min_tags ->
          add_error(changeset, :tags, "Please specify at least %{count} tags", count: min_tags)

        no_tags > max_tags ->
          add_error(changeset, :tags, "Please specify a maximum of %{count} tags", count: max_tags)

        true ->
          changeset
      end
    else
      _ -> changeset
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
    |> validate_blacklist(:author, "nick_black_list")
    |> validate_blacklist(:subject, "subject_black_list")
    |> validate_blacklist(:content, "content_black_list")
    |> validate_blacklist(:homepage, "url_black_list")
    |> validate_blacklist(:problematic_site, "url_black_list")
  end

  def changeset(struct, params, user, visible_forums, thread, message, opts) do
    struct
    |> base_changeset(params, user, thread.forum_id, visible_forums, opts)
    |> put_change(:thread_id, thread.thread_id)
    |> put_change(:parent_id, message.message_id)
    |> validate_required([:author, :subject, :content, :forum_id, :thread_id])
    |> validate_blacklist(:author, "nick_black_list")
    |> validate_blacklist(:subject, "subject_black_list")
    |> validate_blacklist(:content, "content_black_list")
    |> validate_blacklist(:homepage, "url_black_list")
    |> validate_blacklist(:problematic_site, "url_black_list")
  end

  def new_or_update_changeset(struct, params, user, visible_forums, opts \\ [create_tags: false]) do
    struct
    |> base_changeset(params, user, nil, visible_forums, opts)
    |> validate_required([:author, :subject, :content])
  end

  def update_changeset(struct, params, user, visible_forums, opts \\ [create_tags: false]) do
    struct
    |> new_or_update_changeset(params, nil, visible_forums, opts)
    |> maybe_set_editor_id(user)
    |> set_editor_author(struct, user)
  end

  def retag_changeset(struct, params, user, opts \\ [create_tags: false]) do
    struct
    |> cast(%{}, [])
    |> parse_tags(params, user, opts[:create_tags])
    |> validate_tags_count()
    |> maybe_set_editor_id(user)
    |> set_editor_author(struct, user)
  end

  defp parse_tags(changeset, %{"tags" => tags}, user, create_tags) do
    tags =
      tags
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&Helpers.blank?/1)
      |> Enum.map(&String.downcase/1)

    parse_tags(changeset, tags, user, create_tags)
  end

  defp parse_tags(changeset, %{}, _, _), do: changeset

  defp parse_tags(changeset, tags, user, create_tags) do
    {known_tags, unknown_tags} = maybe_create_tags(tags, user, create_tags)

    if Helpers.blank?(unknown_tags) do
      put_assoc(changeset, :tags, known_tags)
    else
      changeset
      |> put_assoc(:tags, Enum.map(tags, &%Tag{tag_name: &1}))
      |> add_error(:tags, "unknown tags given: %{tags}", tags: Enum.join(unknown_tags, ", "))
      |> add_tag_errors(unknown_tags)
    end
  end

  defp maybe_create_tags(tags, _user, false) do
    known_tags = Tags.get_tags(tags)
    unknown_tags = Enum.filter(tags, &(not tag_matches?(known_tags, &1)))
    {known_tags, unknown_tags}
  end

  defp maybe_create_tags(tags, user, true) do
    known_tags = Tags.get_tags(tags)

    unknown_tags =
      tags
      |> Enum.filter(&(not tag_matches?(known_tags, &1)))
      |> Enum.map(fn tag ->
        {:ok, tag} = Tags.create_tag(user, %{tag_name: tag})
        tag
      end)

    {known_tags ++ unknown_tags, []}
  end

  defp tag_matches?(known_tags, wanted_tag) do
    Enum.find(known_tags, fn tag ->
      tag.tag_name == wanted_tag || Enum.find(tag.synonyms, &(&1.synonym == wanted_tag)) != nil
    end) != nil
  end

  defp add_tag_errors(changeset, unknown_tags) do
    tags =
      Enum.map(get_change(changeset, :tags, []), fn tag ->
        if Enum.find(unknown_tags, &(&1 == get_field(tag, :tag_name))) != nil,
          do: add_error(tag, :tag_name, "is unknown"),
          else: tag
      end)

    put_change(changeset, :tags, tags)
  end

  defp maybe_set_author(changeset, %User{} = author, _) do
    case get_field(changeset, :author) do
      nil ->
        changeset
        |> put_change(:author, author.username)

      _ ->
        changeset
    end
    |> put_change(:user_id, author.user_id)
  end

  defp maybe_set_author(changeset, nil, uuid),
    do: put_change(changeset, :uuid, uuid)

  defp maybe_set_editor_id(changeset, nil), do: changeset
  defp maybe_set_editor_id(changeset, user), do: put_change(changeset, :editor_id, user.user_id)
  defp set_editor_author(changeset, message, nil), do: put_change(changeset, :edit_author, message.author)
  defp set_editor_author(changeset, _, user), do: put_change(changeset, :edit_author, user.username)

  defp set_author_from_opts_when_unset(changeset, field, value)
  defp set_author_from_opts_when_unset(changeset, _, nil), do: changeset

  defp set_author_from_opts_when_unset(changeset, field, value) do
    case get_field(changeset, field) do
      nil -> put_change(changeset, field, value)
      _ -> changeset
    end
  end

  defp validate_blacklist(changeset, field, conf_key) do
    forum_id = get_field(changeset, :forum_id)
    forum = if Helpers.present?(forum_id), do: Cforum.Forums.get_forum!(forum_id), else: nil
    blacklist = Cforum.ConfigManager.conf(forum, conf_key)
    value = get_field(changeset, field)

    if matches?(value, blacklist),
      do: add_error(changeset, field, "seems like spam!"),
      else: changeset
  end

  defp matches?(str, list) when is_nil(str) or str == "" or is_nil(list) or list == "", do: false

  defp matches?(str, list) do
    list
    |> String.split(~r/\015\012|\015|\012/)
    |> Enum.reject(&Helpers.blank?/1)
    |> Enum.any?(fn rx ->
      regex = Regex.compile!(rx, "i")
      Regex.match?(regex, str)
    end)
  end
end
