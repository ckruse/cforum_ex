defmodule Cforum.Forums.Messages do
  @moduledoc """
  The boundary for the Forums system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  import Cforum.Helpers

  alias Cforum.Forums.InvisibleThread
  alias Cforum.Forums.Message
  alias Cforum.Forums.Tag
  alias Cforum.Forums.MessageTag
  alias Cforum.Forums.Vote

  alias Cforum.Accounts.{Scores, Score}
  alias Cforum.Accounts.User
  alias Cforum.Accounts.Notifications

  alias Cforum.System
  alias Cforum.Caching

  alias Cforum.Forums.{Thread, Threads}
  alias Cforum.Forums.MessageIndexerJob
  alias Cforum.Forums.ReadMessage

  alias Cforum.Helpers.CompositionHelpers

  def list_messages(message_ids) do
    threads = Threads.get_threads_by_message_ids(message_ids)

    threads
    |> Enum.map(fn thread ->
      Enum.map(thread.messages, &%Message{&1 | thread: thread})
    end)
    |> List.flatten()
    |> Enum.filter(&(&1.message_id in message_ids))
  end

  @doc """
  Returns a list of messages for a user, limited to the forums specified in `forum_ids`

  ## Examples

      iex> list_messages_for_user(%User{}, [1, 2], limin: [quantity: 10, offset: 0])
      [%Message{}, ...]
  """
  def list_messages_for_user(user, forum_ids, query_params \\ [order: nil, limit: nil]) do
    from(
      m in Message,
      preload: [:user, :tags, [thread: :forum]],
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
  Returns a list of messages for a tag, limited to the forums specified in `visible_forums`

  ## Examples

      iex> list_messages_for_tag([%Forum{}], %Tag{}, limit: [quantity: 10, offset: 0])
      [%Message{}, ...]
  """
  def list_messages_for_tag(visible_forums, tag, query_params \\ [order: nil, limit: nil]) do
    forum_ids = Enum.map(visible_forums, & &1.forum_id)

    from(
      m in Message,
      inner_join: t in "messages_tags",
      on: t.message_id == m.message_id,
      preload: [:user, :tags, [thread: :forum]],
      where: t.tag_id == ^tag.tag_id and m.deleted == false and m.forum_id in ^forum_ids
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
  end

  @doc """
  Counts the messages for a tag, limited to the forums specified in `visible_forums`

  ## Examples

      iex> count_messages_for_tag([%Forum{}], %Tag{})
      10
  """
  def count_messages_for_tag(visible_forums, tag) do
    forum_ids = Enum.map(visible_forums, & &1.forum_id)

    from(
      m in Message,
      inner_join: t in "messages_tags",
      on: t.message_id == m.message_id,
      where: t.tag_id == ^tag.tag_id and m.deleted == false and m.forum_id in ^forum_ids,
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
      preload: [:user, :tags, [thread: :forum]],
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
        message: [:user, :tags, [thread: :forum]],
        vote: [message: [:user, :tags, [thread: :forum]]]
      ],
      left_join: m1 in Message,
      on: m1.message_id == s.message_id,
      left_join: v in Vote,
      on: s.vote_id == v.vote_id,
      left_join: m2 in Message,
      on: v.message_id == m2.message_id,
      where: s.user_id == ^user.user_id,
      where: is_nil(m1.message_id) or (m1.forum_id in ^forum_ids and m1.deleted == false),
      where: is_nil(m2.message_id) or (m2.forum_id in ^forum_ids and m2.deleted == false),
      order_by: [desc: :created_at]
    )
    |> Cforum.PagingApi.set_limit(limit)
  end

  defp int_list_scored_msgs_for_user_in_perspective(_, user, forum_ids, limit) do
    from(
      s in Score,
      preload: [
        message: [:user, :tags, [thread: :forum]],
        vote: [message: [:user, :tags, [thread: :forum]]]
      ],
      left_join: m1 in Message,
      on: m1.message_id == s.message_id,
      left_join: v in Vote,
      on: s.vote_id == v.vote_id,
      left_join: m2 in Message,
      on: v.message_id == m2.message_id,
      where: s.user_id == ^user.user_id,
      where: is_nil(m1.message_id) or (m1.forum_id in ^forum_ids and m1.deleted == false),
      where:
        is_nil(m2.message_id) or (m2.forum_id in ^forum_ids and m2.deleted == false and m2.user_id == ^user.user_id),
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
      select: {t.slug, t.tag_name, count("*")},
      where: m.deleted == false and m.user_id == ^user.user_id and m.forum_id in ^forum_ids,
      group_by: [t.slug, t.tag_name],
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
  Gets a single message.

  Leaves out deleted messages by default; if you want to retrieve
  deleted messages, set `view_all: true` as second parameter

  Returns nil if the Message does not exist.

  ## Examples

      iex> get_message(123)
      %Message{}

      iex> get_message(456)
      nil

  """
  def get_message(id, opts \\ []) do
    if opts[:view_all],
      do: Repo.get(Message, id),
      else: Repo.get_by(Message, message_id: id, deleted: false)
  end

  @doc """
  Gets a thread with all messages and a single message. Returns a
  tuple `{%Thread{}, %Message{}}`.

  Leaves out deleted messages by default; if you want to retrieve
  deleted messages, set `view_all: true` as second parameter

  Raises `Ecto.NoResultsError` if the Message does not exist.

  - `forum` is the current forum
  - `visible_forums` is a list of forums the user may look at
  - `user` is the current user
  - `thread_id` is the thread id
  - `message_id` is the message id
  - `opts` is an option list as defined by `Cforum.Forums.Threads.list_threads/4`

  ## Examples

      iex> get_message_and_thread!(nil, nil, nil, 1, 2)
      {%Thread{}, %Message{}}

      iex> get_message_and_thread(nil, nil, nil, -1, 1)
      ** (Ecto.NoResultsError)

  """
  def get_message_and_thread!(forum, visible_forums, thread_id, message_id, opts \\ []) do
    thread =
      forum
      |> Threads.get_thread!(visible_forums, thread_id)
      |> Threads.reject_deleted_threads(opts[:view_all])

    case find_message(thread, &(&1.message_id == message_id)) do
      nil ->
        raise Ecto.NoResultsError, queryable: Message

      msg ->
        {thread, msg}
    end
  end

  @doc """
  sort messages either ascending or descending
  """
  def sort_messages(messages, direction) do
    Enum.sort(messages, fn a, b ->
      cond do
        a.parent_id == b.parent_id && direction == "ascending" -> Timex.compare(a.created_at, b.created_at) <= 0
        a.parent_id == b.parent_id && direction == "descending" -> Timex.compare(a.created_at, b.created_at) >= 0
        true -> Cforum.Helpers.to_int(a.parent_id) <= Cforum.Helpers.to_int(b.parent_id)
      end
    end)
  end

  @doc """
  Finds a message in a thread or in a list of messages. Returns nil if
  the Message does not exist.

  ## Examples

      iex> find_message(%Thread{tree: %Message{}}, & &1.message_id == 1)
      %Message{}

      iex> find_message([%Message{}], & &1.message_id == 1)
      %Message{}

      iex> find_message([], & &1.message_id == 1)
      nil
  """
  def find_message(list_of_messages_or_thread, fun)
  def find_message(%Cforum.Forums.Thread{tree: %Message{}} = thread, fun), do: find_message([thread.tree], fun)
  def find_message(%Cforum.Forums.Thread{messages: messages}, fun), do: find_message(messages, fun)
  def find_message([], _), do: nil
  def find_message(nil, _), do: nil

  def find_message([msg | tail], fun) do
    if fun.(msg) do
      msg
    else
      case find_message(msg.messages, fun) do
        nil -> find_message(tail, fun)
        msg -> msg
      end
    end
  end

  @doc """
  Loads a thread by its slug and searches for the message specified my `mid` in the thread tree. Sets things like
  visited marks, etc, pp. Raises `Ecto.NoResultsError` when no thread or no message could be found.

  ## Examples

      iex> get_message_from_mid!(%Forum{}, %User{}, "2009/08/25/foo-bar", 222)
      {%Thread{}, %Message{}}

      iex> get_message_from_mid!(%Forum{}, %User{}, "2009/08/32/foo-bar", 222)
      ** (Ecto.NoResultsError)
  """
  def get_message_from_mid!(thread, mid)

  def get_message_from_mid!(thread, mid) when is_bitstring(mid),
    do: get_message_from_mid!(thread, String.to_integer(mid, 10))

  def get_message_from_mid!(%Thread{} = thread, mid) do
    case find_message(thread, &(&1.message_id == mid)) do
      nil -> raise Ecto.NoResultsError, queryable: Message
      msg -> msg
    end
  end

  alias Cforum.Forums.Messages.Mentions

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
  def create_message(attrs, user, visible_forums, thread, parent \\ nil, opts \\ []) do
    opts = Keyword.merge([create_tags: false, autosubscribe: false], opts)

    System.audited("create", user, fn ->
      changeset =
        %Message{}
        |> Message.changeset(attrs, user, visible_forums, thread, parent, opts)
        |> Mentions.parse_mentions()

      author = Ecto.Changeset.get_field(changeset, :author)

      case may_user_post_with_name?(user, author) do
        true ->
          Repo.insert(changeset)

        _ ->
          {:error, Ecto.Changeset.add_error(changeset, :author, "already taken")}
      end
    end)
    |> notify_users(thread)
    |> maybe_autosubscribe(opts[:autosubscribe], user, thread, parent)
    |> index_message(thread)
    |> Threads.refresh_cached_thread()
  end

  defp may_user_post_with_name?(_, nil), do: true

  defp may_user_post_with_name?(nil, name) do
    clean_name = String.trim(name)

    found =
      from(u in User, where: fragment("lower(?)", u.username) == fragment("lower(?)", ^clean_name))
      |> Repo.exists?()

    found == false
  end

  defp may_user_post_with_name?(user, name) do
    clean_name = name |> String.trim() |> String.downcase()

    if String.downcase(user.username) == clean_name,
      do: true,
      else: may_user_post_with_name?(nil, name)
  end

  defp maybe_autosubscribe({:error, changeset}, _, _, _, _), do: {:error, changeset}
  defp maybe_autosubscribe(val, false, _, _, _), do: val

  defp maybe_autosubscribe({:ok, message}, subtype, user, thread, parent) do
    cond do
      parent_subscribed?(thread, message) ->
        :ignore

      subtype == "yes" && parent ->
        subscribe_message(user, parent)

      # subscribe own message on new threads
      subtype == "own" || is_nil(message.parent_id) ->
        subscribe_message(user, message)

      subtype == "root" ->
        subscribe_message(user, thread.message)

      true ->
        :ignore
    end

    {:ok, message}
  end

  defp notify_users({:error, changeset}, _), do: {:error, changeset}

  defp notify_users({:ok, message}, thread) do
    Cforum.Forums.NotifyUsersMessageJob.notify_users_about_new_message(thread, message)
    {:ok, message}
  end

  defp index_message({:ok, message}, thread) do
    MessageIndexerJob.index_message(Repo.preload(thread, [:forum]), message)
    {:ok, message}
  end

  defp index_message(val, _), do: val

  def unnotify_user(user, message) when is_nil(user) or is_nil(message), do: nil

  def unnotify_user(user, message) do
    Notifications.delete_notification_for_object(user, message.message_id, [
      "message:create-answer",
      "message:create-activity"
    ])
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
  def preview_message(attrs, user, visible_forums, thread, parent \\ nil, message \\ %Message{created_at: Timex.now()}) do
    changeset = Message.changeset(message, attrs, user, visible_forums, thread, parent)

    msg = %Message{
      Ecto.Changeset.apply_changes(changeset)
      | tags: Ecto.Changeset.get_field(changeset, :tags),
        user: user
    }

    {msg, %Ecto.Changeset{changeset | action: :insert}}
  end

  alias Cforum.Forums.MessageVersion

  defp build_version(changeset, message, user) do
    version =
      message
      |> Ecto.build_assoc(:versions)
      |> MessageVersion.changeset(message, user)

    changeset
    |> Ecto.Changeset.put_assoc(:versions, [version | message.versions])
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs, user, visible_forums, opts \\ [create_tags: false]) do
    message
    |> Message.update_changeset(attrs, user, visible_forums, opts)
    |> build_version(message, user)
    |> Repo.update()
    |> update_cached_message()
  end

  @doc """
  Deletes a Message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(user, %Message{} = message) do
    System.audited("destroy", user, fn ->
      do_delete_message(user, message)
    end)
    |> Threads.refresh_cached_thread()
  end

  defp do_delete_message(user, message) do
    new_message =
      message
      |> Ecto.Changeset.change(deleted: true)
      |> Repo.update!()

    Enum.each(message.messages, &do_delete_message(user, &1))

    {:ok, new_message}
  end

  @doc """
  Restores a Message.

  ## Examples

      iex> restore_message(message)
      {:ok, %Message{}}

      iex> restore_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def restore_message(user, %Message{} = message) do
    System.audited("restore", user, fn ->
      do_restore_message(user, message)
    end)
    |> Threads.refresh_cached_thread()
  end

  def do_restore_message(user, message) do
    new_message =
      message
      |> Ecto.Changeset.change(deleted: false)
      |> Repo.update!()

    Enum.each(message.messages, &do_restore_message(user, &1))

    {:ok, new_message}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{source: %Message{}}

  """
  def change_message(%Message{} = message, user, visible_forums) do
    Message.new_or_update_changeset(message, %{}, user, visible_forums)
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

    content =
      cnt
      |> CompositionHelpers.quote_from_content(opts[:strip_signature])
      |> CompositionHelpers.maybe_add_greeting(
        opts[:greeting],
        attribute_value(message, :author),
        opts[:std_replacement]
      )
      |> CompositionHelpers.maybe_add_farewell(opts[:farewell])
      |> CompositionHelpers.maybe_add_signature(opts[:signature])

    change_message(
      %Message{
        author: opts[:author],
        email: opts[:email],
        homepage: opts[:homepage],
        subject: attribute_value(message, :subject),
        problematic_site: attribute_value(message, :problematic_site),
        content: content
        # tags_str: tags_str,
      },
      user,
      visible_forums
    )
    |> Ecto.Changeset.put_assoc(:tags, attribute_value(message, :tags, []))
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
      ret =
        %ReadMessage{}
        |> ReadMessage.changeset(%{message_id: msg.message_id, user_id: user.user_id})
        |> Repo.insert()

      case ret do
        {:ok, rm} ->
          rm

        {:error, _} ->
          nil
      end
    end
    |> Enum.filter(&(!is_nil(&1)))
  end

  @doc """
  Counts the number of unread threads and messages for a user. Returns a tuple
  `{number of unread threads, number of unread messages}`. A thread is counted
  as unread if it contains unread messages; so a return value of `{1, 5}` means
  five unread messages in one thread.

  ## Examples

      iex> count_unread_messages(%User{})
      {1, 5}
  """
  def count_unread_messages(user)
  def count_unread_messages(nil), do: {0, 0}

  def count_unread_messages(user) do
    from(
      msg in Message,
      inner_join: thr in assoc(msg, :thread),
      left_join: rm in ReadMessage,
      on: rm.message_id == msg.message_id and rm.user_id == ^user.user_id,
      left_join: inv in InvisibleThread,
      on: inv.thread_id == thr.thread_id and inv.user_id == ^user.user_id,
      where: msg.deleted == false and thr.archived == false and is_nil(rm.message_id) and is_nil(inv.thread_id),
      select: {fragment("COUNT(DISTINCT ?)", msg.thread_id), count("*")}
    )
    |> Repo.one()
  end

  alias Cforum.Forums.Subscription

  @doc """
  Subscribes a message for a user.

  ## Examples

      iex> subscribe_message(%User{}, %Message{})
      {:ok, %Subscription{}}
  """
  def subscribe_message(user, message) do
    %Subscription{}
    |> Subscription.changeset(%{user_id: user.user_id, message_id: message.message_id})
    |> Repo.insert()
  end

  @doc """
  Deletes the subscription of a user for a message.

  ## Examples

      iex> unsubscribe_message(%User{}, %Message{})
      {:ok, %Subscription{}}
  """
  def unsubscribe_message(user, message) do
    subscription =
      Subscription
      |> Repo.get_by(user_id: user.user_id, message_id: message.message_id)

    if subscription, do: Repo.delete(subscription), else: nil
  end

  @doc """
  Lists the subscribed messages for a user.

  ## Examples

      iex> list_subscriptions(%User{})
      [%Message{}, ...]
  """
  def list_subscriptions(user, query_params \\ [order: nil, limit: nil]) do
    from(
      msg in Message,
      join: s in Subscription,
      where: s.message_id == msg.message_id and s.user_id == ^user.user_id,
      preload: [:user, :tags, [thread: :forum]]
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
  end

  @spec list_subscriptions_for_messages([%Message{}]) :: [%Subscription{}]
  def list_subscriptions_for_messages(messages) do
    mids = Enum.map(messages, & &1.message_id)

    from(s in Subscription, where: s.message_id in ^mids)
    |> Repo.all()
    |> Repo.preload([:user])
  end

  @doc """
  Counts the subscribed messages for a user.

  ## Examples

      iex> count_subscriptions(%User{})
      0
  """
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

  @doc """
  Marks a message as interesting for a user.

  ## Examples

      iex> mark_message_interesting(%User{}, %Message{})
      {:ok, %InterestingMessage{}}
  """
  def mark_message_interesting(user, message) do
    %InterestingMessage{}
    |> InterestingMessage.changeset(%{user_id: user.user_id, message_id: message.message_id})
    |> Repo.insert()
  end

  @doc """
  Removes the interesting mark of a message for a user.

  ## Examples

      iex> mark_message_boring(%User{}, %Message{})
      {:ok, %InterestingMessage{}}
  """
  def mark_message_boring(user, message) do
    interesting_message =
      InterestingMessage
      |> Repo.get_by(user_id: user.user_id, message_id: message.message_id)

    if interesting_message, do: Repo.delete(interesting_message), else: nil
  end

  @doc """
  Lists the messages marked as interesting for a user.

  ## Examples

      iex> list_interesting_messages(%User{})
      [%Message{}, ...]
  """
  def list_interesting_messages(user, query_params \\ [order: nil, limit: nil]) do
    from(
      msg in Message,
      join: s in InterestingMessage,
      where: s.message_id == msg.message_id and s.user_id == ^user.user_id,
      preload: [:user, :tags, [thread: :forum]]
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
  end

  @doc """
  Counts the messages marked as interesting for a user.

  ## Examples

      iex> count_interesting_messages(%User{})
      1
  """
  def count_interesting_messages(user) do
    from(
      msg in Message,
      join: s in InterestingMessage,
      where: s.message_id == msg.message_id and s.user_id == ^user.user_id,
      select: count("*")
    )
    |> Repo.one()
  end

  @doc """
  Returns the parent message of a message. Returns nil if there is no parent
  message or the parent message could not be found.

  ## Examples

      iex> parent_message(%Thread{}, %Message{})
      %Message{}
  """
  def parent_message(thread, message)
  def parent_message(_, %Message{parent_id: nil}), do: nil
  def parent_message(thread, %Message{parent_id: mid}), do: find_message(thread, &(&1.message_id == mid))

  @doc """
  Returns true if the parent message is marked interesting.

  ## Examples

      iex> parent_subscribed?(%Thread{}, %Message{})
      true
  """
  def parent_subscribed?(thread, message)
  def parent_subscribed?(_, %Message{parent_id: nil}), do: false

  def parent_subscribed?(thread, message) do
    parent = parent_message(thread, message)
    parent.attribs[:is_subscribed] == true || parent_subscribed?(thread, parent)
  end

  @doc """
  Increases the `downvotes` field of a message by `by`. `by` can also be
  negative.

  ## Examples

      iex> score_down_message(%Message{})
      {1, nil}
  """
  @spec score_down_message(%Message{}, integer()) :: any()
  def score_down_message(message, by \\ 1) do
    ret =
      from(
        msg in Message,
        where: msg.message_id == ^message.message_id,
        update: [inc: [downvotes: ^by]]
      )
      |> Repo.update_all([])

    MessageIndexerJob.rescore_message(message)
    update_cached_message(message, fn msg -> %Message{msg | downvotes: msg.downvotes + by} end)

    ret
  end

  @doc """
  Increases the `upvotes` field of a message by `by`. `by` can also be
  negative.

  ## Examples

      iex> score_up_message(%Message{})
      {1, nil}
  """
  @spec score_up_message(%Message{}, integer()) :: any()
  def score_up_message(message, by \\ 1) do
    ret =
      from(
        msg in Message,
        where: msg.message_id == ^message.message_id,
        update: [inc: [upvotes: ^by]]
      )
      |> Repo.update_all([])

    MessageIndexerJob.rescore_message(message)
    update_cached_message(message, fn msg -> %Message{msg | upvotes: msg.upvotes + by} end)

    ret
  end

  @doc """
  Accepts a message (sets the `"accept"` flag value to `"yes"`) if not yet
  accepted. Credits `points` points to the author of the message.

  - `message` is the message to accept
  - `user` is the current user (relevant for the audit log)
  - `points` are the points to credit to the user

  ## Examples

      iex> accept_message(%Message{}, %User{}, 15)
      {:ok, _}
  """
  def accept_message(message, user, points)
  def accept_message(%Message{flags: %{"accepted" => "yes"}}, _, _), do: nil

  def accept_message(message, user, points) do
    Repo.transaction(fn ->
      Message
      |> where(message_id: ^message.message_id)
      |> Repo.update_all(set: [flags: Map.put(message.flags, "accepted", "yes")])

      update_cached_message(message, &%Message{&1 | flags: Map.put(&1.flags, "accepted", "yes")})

      case maybe_give_accept_score(message, user, points) do
        nil ->
          MessageIndexerJob.rescore_message(message)
          :ok

        {:ok, _} ->
          MessageIndexerJob.rescore_message(message)
          :ok

        _ ->
          Repo.rollback(nil)
      end
    end)
  end

  defp maybe_give_accept_score(%Message{user_id: nil}, _, _), do: nil

  defp maybe_give_accept_score(message, user, points) do
    System.audited("accepted-score", user, fn ->
      Scores.create_score(%{message_id: message.message_id, user_id: message.user_id, value: points})
    end)
  end

  @doc """
  Removes the accepted flag from a message

  - `message` is the message to accept
  - `user` is the current user (relevant for the audit log)

  ## Examples

      iex> unaccept_message(%Message{}, %User{})
      {:ok, _}
  """
  def unaccept_message(message, user) do
    Repo.transaction(fn ->
      message = %Message{message | flags: Map.delete(message.flags, "accepted")}

      Message
      |> where(message_id: ^message.message_id)
      |> Repo.update_all(set: [flags: message.flags])

      update_cached_message(message, &%Message{&1 | flags: Map.delete(&1.flags, "accepted")})

      case maybe_take_accept_score(message, user) do
        nil ->
          MessageIndexerJob.rescore_message(message)
          {:ok, message}

        {:ok, msg} ->
          MessageIndexerJob.rescore_message(message)
          {:ok, msg}

        _ ->
          Repo.rollback(nil)
      end
    end)
  end

  defp maybe_take_accept_score(%Message{user_id: nil}, _), do: nil

  defp maybe_take_accept_score(message, user) do
    System.audited("accepted-no-unscore", user, fn ->
      Scores.delete_score_by_message_id_and_user_id(message.message_id, message.user_id)
      {:ok, message}
    end)
  end

  @doc """
  Sets a flag to the message and its subtree

  - `message` is the message to flag
  - `flag` is the flag to set
  - `value` is the value to set the flag to

  ## Examples

      iex> flag_message_subtree(%Message{}, "no-answer", "yes")
      {:ok, %Message{}}
  """
  def flag_message_subtree(message, flag, value) do
    flags = Map.put(message.flags, flag, value)

    messages =
      Enum.map(message.messages, fn msg ->
        {:ok, msg} = flag_message_subtree(msg, flag, value)
        msg
      end)

    msg = %Message{message | messages: messages}

    msg
    |> Ecto.Changeset.change(flags: flags)
    |> Repo.update()
  end

  @doc """
  Removes a flag from the message and its subtree

  - `message` is the message to flag
  - `flag` is the flag to set

  ## Examples

      iex> unflag_message_subtree(%Message{}, "no-answer")
      {:ok, %Message{}}
  """
  def unflag_message_subtree(message, flag) do
    flags = Map.delete(message.flags, flag)

    messages =
      Enum.map(message.messages, fn msg ->
        {:ok, msg} = unflag_message_subtree(msg, flag)
        msg
      end)

    msg = %Message{message | messages: messages}

    msg
    |> Ecto.Changeset.change(flags: flags)
    |> Repo.update()
  end

  @doc """
  Sets a the no answer flag of the message and its subtree to yes

  - `user` the current user
  - `message` is the message to flag
  - `type` is the no answer type, one of `"no-answer"` or `"no-answer-admin"`

  ## Examples

      iex> flag_no_answer(%User{}, %Message{})
      {:ok, %Message{}}
  """
  def flag_no_answer(user, message, type \\ "no-answer-admin") when type in ~w(no-answer-admin no-answer) do
    System.audited("flag-no-answer", user, fn ->
      flag_message_subtree(message, type, "yes")
    end)
    |> Threads.refresh_cached_thread()
  end

  @doc """
  Removes a the no answer flag of the message and its subtree

  - `user` the current user
  - `message` is the message to flag
  - `type` is the no answer type, one of `"no-answer"` or `"no-answer-admin"`

  ## Examples

      iex> unflag_no_answer(%User{}, %Message{})
      {:ok, %Message{}}
  """
  def unflag_no_answer(user, message, type \\ "no-answer-admin") when type in ~w(no-answer-admin no-answer) do
    System.audited("unflag-no-answer", user, fn ->
      unflag_message_subtree(message, type)
    end)
    |> Threads.refresh_cached_thread()
  end

  @doc """
  Returns true if a message has been accepted as a solving answer

  ## Examples

      iex> accepted?(%Message{flags: %{"accepted" => "yes"}})
      true
  """
  def accepted?(message), do: message.flags["accepted"] == "yes"

  @doc """
  Returns true if answering to a message has been forbidden

  ## Examples

      iex> no_answer?(%Message{flags: %{"no-answer" => "yes"}})
      true
  """
  def no_answer?(message), do: message.flags["no-answer"] == "yes" || message.flags["no-answer-admin"] == "yes"

  @doc """
  Returns true if answering to a message has been forbidden or allowed by an admin

  ## Examples

      iex> accepted?(%Message{flags: %{"no-answer-admin" => "yes"}})
      true
  """
  def admin_decision?(message), do: Map.has_key?(message.flags, "no-answer-admin")

  @doc """
  Returns true if a message is „closed“ (as in: answering isn't possible). This
  is the case when a message has been deleted or a message has been set to
  „no answer“

  ## Examples

      iex> closed?(%Message{deleted: true})
      true
  """
  def closed?(message), do: message.deleted || no_answer?(message)

  def open?(message), do: not closed?(message)

  @doc """
  Returns the score of a message

  ## Examples

      iex> score(%Message{upscore: 2, downscore: 1})
      1
  """
  def score(msg), do: msg.upvotes - msg.downvotes

  @doc """
  Returns the number of votes for a message

  ## Examples

      iex> no_votes(%Message{upscore: 2, downscore: 1})
      3
  """
  def no_votes(msg), do: msg.upvotes + msg.downvotes

  @doc """
  Returns a localized, stringified version of the message score

  ## Examples

      iex> score_str(%Message{upvotes: 2, downvotes: 1})
      "+3"
  """
  @spec score_str(%Message{}) :: String.t()
  def score_str(msg), do: Cforum.Helpers.score_str(no_votes(msg), score(msg))

  @spec answer?(%Cforum.Forums.Thread{}, %Message{}) :: boolean()
  def answer?(thread, message),
    do: Enum.find(thread.messages, &(&1.parent_id == message.message_id)) != nil

  @spec editable_age?(%Message{}, Timex.shift_options()) :: boolean() | {:error, any()}
  def editable_age?(msg, max_age \\ [minutes: 10]),
    do: Timex.before?(Timex.now(), Timex.shift(msg.created_at, max_age))

  @spec owner?(Plug.Conn.t(), %Message{}) :: boolean()
  def owner?(conn, message) do
    cond do
      conn.assigns[:current_user] && conn.assigns[:current_user].user_id == message.user_id -> true
      conn.cookies["cforum_user"] == message.uuid -> true
      true -> false
    end
  end

  def autosubscribe?(user, config_value)
  def autosubscribe?(user, val) when is_nil(user) or val == "no", do: false
  def autosubscribe?(_, val), do: val

  def update_cached_message({:ok, %{message_id: mid}} = val) do
    update_cached_message_by_mid(mid)
    val
  end

  def update_cached_message(%{message_id: mid} = val) do
    update_cached_message_by_mid(mid)
    val
  end

  def update_cached_message(val), do: val

  def update_cached_message({:ok, %{thread_id: tid, message_id: mid}} = val, fun) do
    update_cached_message_by_tid_and_mid(tid, mid, fun)
    val
  end

  def update_cached_message(%{thread_id: tid, message_id: mid} = val, fun) do
    update_cached_message_by_tid_and_mid(tid, mid, fun)
    val
  end

  def update_cached_message_by_mid(mid) do
    msg =
      mid
      |> get_message!(view_all: true)
      |> Repo.preload(Message.default_preloads())

    tid = msg.thread_id

    Caching.update(:cforum, :threads, fn threads ->
      threads
      |> Enum.map(fn
        %Thread{thread_id: ^tid} = thread -> replace_message(thread, msg)
        thread -> thread
      end)
    end)
  end

  defp replace_message(%Thread{messages: messages} = thread, %Message{message_id: mid} = msg) do
    messages =
      messages
      |> Enum.map(fn
        %Message{message_id: ^mid} -> msg
        message -> message
      end)

    %Thread{thread | messages: messages}
  end

  def update_cached_message_by_tid_and_mid(tid, mid, fun) do
    Caching.update(:cforum, :threads, fn threads ->
      threads
      |> Enum.map(fn
        %Thread{thread_id: ^tid} = thread -> replace_message(thread, mid, fun)
        thread -> thread
      end)
    end)
  end

  defp replace_message(%Thread{messages: messages} = thread, mid, fun) do
    messages =
      messages
      |> Enum.map(fn
        %Message{message_id: ^mid} = msg -> fun.(msg)
        msg -> msg
      end)

    %Thread{thread | messages: messages}
  end

  def content_with_presentational_filters(assigns, message) do
    message = Mentions.mentions_markup(message, assigns[:current_user])
    message.content
  end
end
