defmodule Cforum.Messages do
  use Appsignal.Instrumentation.Decorators

  @moduledoc """
  The boundary for the Forums system.
  """

  import Ecto.Query, warn: false

  alias Cforum.Repo
  alias Cforum.Helpers

  alias Cforum.Messages.Message

  alias Cforum.Accounts.Scores
  alias Cforum.Accounts.Notifications

  alias Cforum.System

  alias Cforum.Threads
  alias Cforum.Threads.Thread
  alias Cforum.Threads.ThreadCaching

  alias Cforum.Messages.MessageIndexerJob
  alias Cforum.Messages.NewMessageBadgeDistributorJob
  alias Cforum.Messages.Mentions
  alias Cforum.Messages.Subscriptions
  alias Cforum.Messages.MessageHelpers
  alias Cforum.Messages.MessageVersions
  alias Cforum.Messages.MessageCaching

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
  - `opts` is an option list as defined by `Cforum.Threads.list_threads/4`

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

    case MessageHelpers.find_message(thread, &(&1.message_id == message_id)) do
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
    case MessageHelpers.find_message(thread, &(&1.message_id == mid)) do
      nil -> raise Ecto.NoResultsError, queryable: Message
      msg -> msg
    end
  end

  def get_message_from_old_mid!(thread, mid) when is_bitstring(mid),
    do: get_message_from_old_mid!(thread, String.to_integer(mid, 10))

  def get_message_from_old_mid!(thread, mid) do
    case MessageHelpers.find_message(thread, &(&1.mid == mid)) do
      nil -> raise Ecto.NoResultsError, queryable: Message
      msg -> msg
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
  def create_message(attrs, user, visible_forums, thread, parent \\ nil, opts \\ []) do
    opts = Keyword.merge([create_tags: false, autosubscribe: false], opts)

    System.audited("create", user, fn ->
      changeset =
        %Message{}
        |> Message.changeset(attrs, user, visible_forums, thread, parent, opts)
        |> Mentions.parse_mentions()

      author = Ecto.Changeset.get_field(changeset, :author)

      case MessageHelpers.may_user_post_with_name?(user, author) do
        true ->
          Repo.insert(changeset)

        _ ->
          changeset =
            changeset
            |> Map.put(:action, :insert)
            |> Ecto.Changeset.add_error(:author, "has already been taken")

          {:error, changeset}
      end
    end)
    |> notify_users(thread)
    |> Subscriptions.maybe_autosubscribe(opts[:autosubscribe], user, thread, parent)
    |> index_message(thread)
    |> NewMessageBadgeDistributorJob.perform()
    |> ThreadCaching.refresh_cached_thread()
  end

  defp index_message({:ok, message}, thread) do
    MessageIndexerJob.index_message(Repo.preload(thread, [:forum]), message)
    {:ok, message}
  end

  defp index_message(val, _), do: val

  @default_notification_types ["message:create-answer", "message:create-activity"]
  def unnotify_user(user, read_mode, thread, message, notification_types \\ @default_notification_types)
  def unnotify_user(user, _, _, message, _) when is_nil(user) or is_nil(message), do: nil

  def unnotify_user(user, "thread", _, message, types),
    do: Notifications.delete_notification_for_object(user, message.message_id, types)

  def unnotify_user(user, _, thread, _, types) do
    mids = Enum.map(thread.sorted_messages, & &1.message_id)
    Notifications.delete_notification_for_object(user, mids, types)
  end

  def unnotify_user({:ok, msg}, message_ids) do
    Notifications.delete_notifications_for_objects(message_ids, [
      "message:create-answer",
      "message:create-activity",
      "message:mention"
    ])

    {:ok, msg}
  end

  def unnotify_user(val, _), do: val

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
        user: user,
        references: []
    }

    {msg, %Ecto.Changeset{changeset | action: :insert}}
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
    System.audited("update", user, fn ->
      message
      |> Message.update_changeset(attrs, user, visible_forums, opts)
      |> Mentions.parse_mentions()
      |> MessageVersions.build_version(message, user)
      |> Repo.update()
      |> MessageCaching.update_cached_message()
    end)
  end

  def retag_message(%Message{} = message, attrs, user, opts \\ [create_tags: false]) do
    System.audited("retag", user, fn ->
      message
      |> Message.retag_changeset(attrs, user, opts)
      |> Repo.update()
      |> MessageCaching.update_cached_message()
    end)
  end

  defp subtree_message_ids(msg), do: [msg.message_id | Enum.map(msg.messages, &subtree_message_ids/1)]

  @doc """
  Deletes a Message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(user, %Message{} = message) do
    message_ids =
      message
      |> subtree_message_ids()
      |> List.flatten()

    System.audited("destroy", user, fn ->
      from(m in Message,
        where: m.message_id in ^message_ids,
        update: [set: [deleted: true]]
      )
      |> Repo.update_all([])

      {:ok, message}
    end)
    |> ThreadCaching.refresh_cached_thread()
    |> unnotify_user(message_ids)
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
    message_ids =
      message
      |> subtree_message_ids()
      |> List.flatten()

    System.audited("restore", user, fn ->
      from(m in Message,
        where: m.message_id in ^message_ids,
        update: [set: [deleted: false]]
      )
      |> Repo.update_all([])

      {:ok, message}
    end)
    |> ThreadCaching.refresh_cached_thread()
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
        do: Helpers.attribute_value(message, :content, ""),
        else: ""

    content =
      cnt
      |> CompositionHelpers.quote_from_content(opts[:strip_signature])
      |> CompositionHelpers.maybe_add_greeting(
        opts[:greeting],
        Helpers.attribute_value(message, :author),
        opts[:std_replacement]
      )
      |> CompositionHelpers.maybe_add_farewell(opts[:farewell])
      |> CompositionHelpers.maybe_add_signature(opts[:signature])

    %Message{
      author: opts[:author],
      email: opts[:email],
      homepage: opts[:homepage],
      subject: Helpers.attribute_value(message, :subject),
      problematic_site: Helpers.attribute_value(message, :problematic_site),
      content: content
      # tags_str: tags_str,
    }
    |> change_message(user, visible_forums)
    |> Ecto.Changeset.put_assoc(:tags, Helpers.attribute_value(message, :tags, []))
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
    MessageCaching.update_cached_message(message, fn msg -> %Message{msg | downvotes: msg.downvotes + by} end)

    notify_users(%Message{message | downvotes: message.downvotes + by}, :score)

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
    MessageCaching.update_cached_message(message, fn msg -> %Message{msg | upvotes: msg.upvotes + by} end)

    notify_users(%Message{message | upvotes: message.upvotes + by}, :score)

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

      MessageCaching.update_cached_message(message, &%Message{&1 | flags: Map.put(&1.flags, "accepted", "yes")})

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

      MessageCaching.update_cached_message(message, &%Message{&1 | flags: Map.delete(&1.flags, "accepted")})

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
    message_ids =
      message
      |> subtree_message_ids()
      |> List.flatten()

    from(m in Message,
      where: m.message_id in ^message_ids,
      update: [set: [flags: fragment("jsonb_set(?, ?, ?)", m.flags, [^flag], ^value)]]
    )
    |> Repo.update_all([])

    {:ok, message}
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
    message_ids =
      message
      |> subtree_message_ids()
      |> List.flatten()

    from(m in Message,
      where: m.message_id in ^message_ids,
      update: [set: [flags: fragment("? - ?", m.flags, ^flag)]]
    )
    |> Repo.update_all([])

    {:ok, message}
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
    |> ThreadCaching.refresh_cached_thread()
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

  def unflag_no_answer(user, message, types \\ ["no-answer-admin", "no-answer"]) do
    System.audited("unflag-no-answer", user, fn ->
      Enum.each(types, fn type ->
        {:ok, _} = unflag_message_subtree(message, type)
      end)

      {:ok, message}
    end)
    |> ThreadCaching.refresh_cached_thread()
  end

  def content_with_presentational_filters(assigns, message) do
    message = Mentions.mentions_markup(message, assigns[:current_user])
    message.content
  end

  defp notify_users({:error, changeset}, _), do: {:error, changeset}

  defp notify_users({:ok, message}, thread) do
    Cforum.Messages.NotifyUsersMessageJob.notify_users_about_new_message(thread, message)

    CforumWeb.Endpoint.broadcast!("forum:#{message.forum_id}", "new_message", %{
      thread: thread,
      message: message,
      forum: Cforum.Forums.get_forum!(message.forum_id)
    })

    {:ok, message}
  end

  defp notify_users(message, :score) do
    CforumWeb.Endpoint.broadcast!("forum:#{message.forum_id}", "message_rescored", %{
      message_id: message.message_id,
      score: MessageHelpers.score(message),
      score_str: MessageHelpers.score_str(message),
      upvotes: message.upvotes,
      downvotes: message.downvotes
    })
  end
end
