defmodule Cforum.Forums.Messages do
  @moduledoc """
  The boundary for the Forums system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  import Cforum.Helpers

  alias Cforum.Forums.Forum
  alias Cforum.Forums.Message
  alias Cforum.Forums.Tag
  alias Cforum.Forums.MessageTag
  alias Cforum.Forums.Vote

  alias Cforum.Accounts.User
  alias Cforum.Accounts.Score

  alias Cforum.Forums.Threads

  alias Cforum.Forums.ReadMessage

  @doc """
  Returns a list of messages for a user, limited to the forums specified in `forum_ids`

  ## Examples

      iex> list_messages_for_user(%User{}, [1, 2], quantity: 10, offset: 0)
      [%Message{}, ...]
  """
  def list_messages_for_user(user, forum_ids, query_params \\ [order: nil, limit: nil]) do
    from(
      m in Message,
      preload: [:user, :tags, [votes: :voters, thread: :forum]],
      where: m.user_id == ^user.user_id and m.deleted == false and m.forum_id in ^forum_ids
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
  end

  @doc """
  Counts the messages for a user, limited to the forums specified in `forum_ids`

  ## Examples

      iex> count_messages_for_user(%User{}, [1, 2])
      10
  """
  def count_messages_for_user(user, forum_ids) do
    from(
      m in Message,
      where: m.user_id == ^user.user_id and m.deleted == false and m.forum_id in ^forum_ids,
      select: count("*")
    )
    |> Repo.one()
  end

  @doc """
  Lists the `limit` best scored messages for a user (limited to forums listed in `forum_ids`).

  Although this function is very similiar to `list_messages_for_user`, we can't
  really use that API due to limitations in the `order_by`.

  ## Examples

      iex> list_best_scored_messages_for_user(%User{}, [1, 2])
      [%Message{}, ...]
  """
  def list_best_scored_messages_for_user(user, forum_ids, limit \\ 10) do
    from(
      m in Message,
      preload: [:user, :tags, [votes: :voters, thread: :forum]],
      where: m.deleted == false and m.upvotes > 0 and m.user_id == ^user.user_id and m.forum_id in ^forum_ids,
      order_by: fragment("upvotes - downvotes DESC"),
      limit: ^limit
    )
    |> Repo.all()
  end

  defp int_list_scored_msgs_for_user_in_perspective(cuser, user, forum_ids, limit)

  defp int_list_scored_msgs_for_user_in_perspective(%User{user_id: cuid}, user = %User{user_id: uid}, forum_ids, limit)
       when cuid == uid do
    from(
      s in Score,
      preload: [
        message: [:user, :tags, [thread: :forum, votes: :voters]],
        vote: [message: [:user, :tags, [thread: :forum, votes: :voters]]]
      ],
      left_join: m1 in Message,
      on: m1.message_id == s.message_id,
      left_join: v in Vote,
      on: s.vote_id == v.vote_id,
      left_join: m2 in Message,
      on: v.message_id == m2.message_id,
      where: s.user_id == ^user.user_id,
      where: is_nil(m1.message_id) or m1.forum_id in ^forum_ids,
      where: is_nil(m2.message_id) or m2.forum_id in ^forum_ids,
      where: is_nil(m1.message_id) or m1.deleted == false,
      where: is_nil(m2.message_id) or m2.deleted == false,
      order_by: [desc: :created_at]
    )
    |> Cforum.PagingApi.set_limit(limit)
  end

  defp int_list_scored_msgs_for_user_in_perspective(_, user, forum_ids, limit) do
    from(
      s in Score,
      preload: [
        message: [:user, :tags, [thread: :forum, votes: :voters]],
        vote: [message: [:user, :tags, [thread: :forum, votes: :voters]]]
      ],
      left_join: m1 in Message,
      on: m1.message_id == s.message_id,
      left_join: v in Vote,
      on: s.vote_id == v.vote_id,
      left_join: m2 in Message,
      on: v.message_id == m2.message_id,
      where: s.user_id == ^user.user_id,
      where: is_nil(m1.message_id) or m1.forum_id in ^forum_ids,
      where: is_nil(m2.message_id) or m2.forum_id in ^forum_ids,
      where: is_nil(m1.message_id) or m1.deleted == false,
      where: is_nil(m2.message_id) or m2.deleted == false,
      where: m2.user_id == ^user.user_id,
      where: s.value > 0,
      order_by: [desc: :created_at]
    )
    |> Cforum.PagingApi.set_limit(limit)
  end

  @doc """
  List scored messages for a user in the perspective of another user, i.e. leave out
  negative votings (a user gets a negative score for voting negative) if user
  doesn't look at his own scores; is limited to the forums defined in `forum_ids`

  ## Arguments

  current_user: the user which perspective we are look on this
  user: the user we are watching at
  forum_ids: the list of forums we are interested in
  limit: the number of messages we want to get

  ## Examples

      iex> list_scored_msgs_for_user_in_perspective(nil, %User{}, [1, 2])
      [%Message{}, ...]

      iex> list_scored_msgs_for_user_in_perspective(%User{}, %User{}, [1, 2])
      [%Message{}]
  """
  def list_scored_msgs_for_user_in_perspective(user, current_user, forum_ids, limit \\ [quantity: 10, offset: 0]) do
    current_user
    |> int_list_scored_msgs_for_user_in_perspective(user, forum_ids, limit)
    |> Repo.all()
  end

  @doc """
  Count the scored messages of the user in perspective; for a better explanation
  look at `list_scored_msgs_for_user_in_perspective`

  ## Examples

      iex> count_scored_msgs_for_user_in_perspective(nil, %User{}, [1, 2])
      1
  """
  def count_scored_msgs_for_user_in_perspective(user, current_user, forum_ids) do
    current_user
    |> int_list_scored_msgs_for_user_in_perspective(user, forum_ids, nil)
    |> exclude(:preload)
    |> exclude(:order_by)
    |> select(count("*"))
    |> Repo.one()
  end

  @doc """
  Counts the messages for a user, grouped by month; for statistical purposes

  ## Examples

      iex> count_messages_for_user_by_month(user)
      [{"2017-01-01", 10}, ...]
  """
  def count_messages_for_user_by_month(user, forum_ids) do
    from(
      m in Message,
      select: {fragment("DATE_TRUNC('month', created_at) created_at"), count("*")},
      where: m.user_id == ^user.user_id and m.deleted == false and m.forum_id in ^forum_ids,
      group_by: fragment("DATE_TRUNC('month', created_at)"),
      order_by: fragment("DATE_TRUNC('month', created_at)")
    )
    |> Repo.all()
  end

  @doc """
  Count the number of messages for a user, grouped by tag and limited to the
  forums defined in `forum_id`; returns a list of tuples consisting of
  {tag slug, tag name, forum slug, forum short name, count}

  ## Examples

      iex> count_messages_per_tag_for_user(%User{}, [1, 2])
      [{"foo-bar", "Foo Bar", "self", "Selfforum", 10}, ...]
  """
  def count_messages_per_tag_for_user(user, forum_ids, limit \\ 10) do
    from(
      mt in MessageTag,
      inner_join: m in Message,
      on: m.message_id == mt.message_id,
      inner_join: t in Tag,
      on: mt.tag_id == t.tag_id,
      inner_join: f in Forum,
      on: f.forum_id == t.forum_id,
      select: {t.slug, t.tag_name, f.slug, f.short_name, count("*")},
      where: m.deleted == false and m.user_id == ^user.user_id and m.forum_id in ^forum_ids,
      group_by: [t.slug, t.tag_name, f.forum_id, f.short_name],
      order_by: fragment("COUNT(*) DESC"),
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc """
  Gets a single message.

  Leaves out deleted messages by default; if you want to retrieve
  deleted messages, set `view_all: true` as second parameter

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id, opts \\ []) do
    if opts[:view_all],
      do: Repo.get!(Message, id),
      else: Repo.get_by!(Message, message_id: id, deleted: false)
  end

  @doc """
  Loads a thread by its slug and searches for the message specified my `mid` in the thread tree. Sets things like
  visited marks, etc, pp. Raises `Ecto.NoResultsError` when no thread or no message could be found.

  ## Examples

      iex> get_message_from_slug_and_mid!(%Forum{}, %User{}, "2009/08/25/foo-bar", 222)
      {%Thread{}, %Message{}}

      iex> get_message_from_slug_and_mid!(%Forum{}, %User{}, "2009/08/32/foo-bar", 222)
      ** (Ecto.NoResultsError)
  """
  def get_message_from_slug_and_mid!(forum, user, slug, mid, opts \\ [])

  def get_message_from_slug_and_mid!(forum, user, slug, mid, opts) when is_bitstring(mid) do
    get_message_from_slug_and_mid!(forum, user, slug, String.to_integer(mid, 10), opts)
  end

  def get_message_from_slug_and_mid!(forum, user, slug, mid, opts) do
    thread = Threads.get_thread_by_slug!(user, slug, opts)

    if forum == nil || thread.forum_id != forum.forum_id do
      raise Ecto.NoResultsError, queryable: Message
    end

    case Enum.find(thread.sorted_messages, &(&1.message_id == mid)) do
      nil ->
        raise Ecto.NoResultsError, queryable: Message

      msg ->
        {thread, msg}
    end
  end

  @doc """
  Creates a message.

  ## Parameters

  attrs: the message attributes, e.g. `:subject`
  user: the current user
  visible_forums: the forums visible to the current user
  thread: the thread the message belongs to
  parent: the parent message of the new message

  ## Examples

      iex> create_message(%{field: value}, %User{}, [%Forum{}], %Thread{})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value}, %User{}, [%Forum{}], %Thread{})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs, user, visible_forums, thread, parent \\ nil) do
    changeset =
      %Message{}
      |> Message.changeset(attrs, user, visible_forums, thread, parent)

    author = Ecto.Changeset.get_field(changeset, :author)

    case may_user_post_with_name?(user, author) do
      true ->
        Repo.insert(changeset)

      _ ->
        {:error, Ecto.Changeset.add_error(changeset, :author, "already taken")}
    end
  end

  defp may_user_post_with_name?(_, nil), do: true

  defp may_user_post_with_name?(nil, name) do
    clean_name = String.trim(name)

    found =
      from(u in User, where: fragment("lower(?)", u.username) == fragment("lower(?)", ^clean_name))
      |> Repo.one()

    found == nil
  end

  defp may_user_post_with_name?(user, name) do
    if String.downcase(user.username) == String.downcase(name),
      do: true,
      else: may_user_post_with_name?(nil, name)
  end

  @doc """
  Generates a %Message{} and a changeset for preview purposes

  ## Parameters

  attrs: The message attributes
  user: The current user
  thread: The thread the message belongs to
  parent: the parent message

  ## Examples

      iex> preview_message(%{}, %User{}, %Thread{})
      {%Message{}, %Ecto.Changeset{}}
  """
  def preview_message(attrs, user, thread, parent \\ nil) do
    changeset =
      %Message{created_at: Timex.now()}
      |> Message.changeset(attrs, user, [], thread, parent)

    msg = %Message{
      Ecto.Changeset.apply_changes(changeset)
      | tags: Ecto.Changeset.get_field(changeset, :tags),
        user: user
    }

    {msg, changeset}
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs, user, visible_forums) do
    message
    |> Message.changeset(attrs, user, visible_forums)
    |> Repo.update()
  end

  @doc """
  Deletes a Message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.update(Ecto.Changeset.change(message, deleted: true))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{source: %Message{}}

  """
  def change_message(%Message{} = message, user, visible_forums) do
    Message.changeset(message, %{}, user, visible_forums)
  end

  @doc """
  Returns a changeset for a new message.

  ## Parameters

  message: the parent message (`nil` if none present)
  user: the current user
  visible_forums: the forums visible to the current user
  opts: options for generating the changeset, valid keys are
        `strip_signature`, `greeting`, `farewell`, `signature`, `email`,
        `homepage`, `author`, `quote`, `std_replacement`

  ## Examples

      iex> new_message_changeset(%Message{}, %User{}, [%Forum{}], [])
      %Ecto.Changeset{}
  """
  def new_message_changeset(message, user, visible_forums, opts \\ []) do
    opts =
      Keyword.merge(
        [
          strip_signature: true,
          greeting: nil,
          farewell: nil,
          signature: nil,
          email: nil,
          homepage: nil,
          author: nil,
          quote: true,
          std_replacement: "all"
        ],
        opts
      )

    cnt =
      if opts[:quote],
        do: attribute_value(message, :content, ""),
        else: ""

    tags_str =
      message
      |> attribute_value(:tags, [])
      |> Enum.map(& &1.tag_name)
      |> Enum.join(", ")

    content =
      cnt
      |> quote_from_content(opts[:strip_signature])
      |> maybe_add_greeting(opts[:greeting], attribute_value(message, :author), opts[:std_replacement])
      |> maybe_add_farewell(opts[:farewell])
      |> maybe_add_signature(opts[:signature])

    change_message(
      %Message{
        author: opts[:author],
        email: opts[:email],
        homepage: opts[:homepage],
        subject: attribute_value(message, :subject),
        problematic_site: attribute_value(message, :problematic_site),
        content: content,
        tags_str: tags_str,
        tags: attribute_value(message, :tags, [])
      },
      user,
      visible_forums
    )
  end

  defp quote_from_content(content, strip_signature) do
    content
    |> remove_signature(strip_signature)
    |> quote_from_content()
  end

  defp quote_from_content(""), do: ""
  defp quote_from_content(content), do: String.replace(content, ~r/^/m, "> ")

  defp maybe_add_greeting(content, greeting, _, _) when greeting == nil or greeting == "", do: content
  defp maybe_add_greeting(content, greeting, nil, std), do: [name_replacements(greeting, std) | ["\n" | content]]
  defp maybe_add_greeting(content, greeting, name, _), do: [name_replacements(greeting, name) | ["\n" | content]]

  defp name_replacements(greeting, name) do
    greeting
    |> String.replace(~r/\{\$name\}/, name)
    |> String.replace(~r/\{\$vname\}/, String.replace(name, ~r/\s.*/, ""))
  end

  defp maybe_add_farewell(content, farewell) when farewell == nil or farewell == "", do: content
  defp maybe_add_farewell(content, farewell), do: [content | ["\n\n" | farewell]]

  defp maybe_add_signature(content, signature) when signature == nil or signature == "", do: content
  defp maybe_add_signature(content, signature), do: [content | ["\n-- \n" | signature]]

  defp remove_signature(content, false), do: content

  defp remove_signature(content, true) do
    parts =
      content
      |> String.reverse()
      |> String.split("\n --\n", parts: 2)

    case parts do
      [_, part] ->
        String.reverse(part)

      _ ->
        content
    end
  end

  @doc """
  Marks a single message or list of messages as read

  ## Parameters

  user: the current user
  message: the message to mark read, **or**
  messages: the list of messages to mark read

  ## Examples

      iex> mark_messages_read(%User{}, %Message{})
  """
  def mark_messages_read(nil, _), do: nil
  def mark_messages_read(user, message) when not is_list(message), do: mark_messages_read(user, [message])

  def mark_messages_read(user, messages) do
    for msg <- messages do
      %ReadMessage{}
      |> ReadMessage.changeset(%{message_id: msg.message_id, user_id: user.user_id})
      |> Repo.insert()
    end
  end

  alias Cforum.Forums.Subscription

  def subscribe_message(user, message) do
    %Subscription{}
    |> Subscription.changeset(%{user_id: user.user_id, message_id: message.message_id})
    |> Repo.insert()
  end

  def unsubscribe_message(user, message) do
    subscription =
      Subscription
      |> Repo.get_by(user_id: user.user_id, message_id: message.message_id)

    if subscription, do: Repo.delete(subscription), else: nil
  end

  def list_subscriptions(user, query_params \\ [order: nil, limit: nil]) do
    from(
      msg in Message,
      join: s in Subscription,
      where: s.message_id == msg.message_id and s.user_id == ^user.user_id,
      preload: [:user, :tags, [votes: :voters, thread: :forum]]
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
  end

  def count_subscriptions(user) do
    from(
      msg in Message,
      join: s in Subscription,
      where: s.message_id == msg.message_id and s.user_id == ^user.user_id,
      select: count("*")
    )
    |> Repo.one()
  end

  alias Cforum.Forums.InterestingMessage

  def mark_message_interesting(user, message) do
    %InterestingMessage{}
    |> InterestingMessage.changeset(%{user_id: user.user_id, message_id: message.message_id})
    |> Repo.insert()
  end

  def mark_message_boring(user, message) do
    interesting_message =
      InterestingMessage
      |> Repo.get_by(user_id: user.user_id, message_id: message.message_id)

    if interesting_message, do: Repo.delete(interesting_message), else: nil
  end
end
