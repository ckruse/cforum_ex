defmodule Cforum.Forums.Threads do
  @moduledoc """
  The boundary for the Threads system.
  """

  import Ecto.{Query, Changeset}, warn: false
  import Cforum.Forums.Threads.Helper

  alias Cforum.Repo

  alias Cforum.Forums.{Thread, InvisibleThread, OpenCloseState}
  alias Cforum.Forums.Messages

  @doc """
  Returns the list of threads.

  ## Examples

      iex> list_threads()
      [%Thread{}, ...]

  """
  def list_threads(forum, visible_forums, user, opts \\ []) do
    opts =
      Keyword.merge(
        [
          sticky: true,
          page: 0,
          limit: 50,
          view_all: false,
          leave_out_invisible: true,
          order: "newest-first",
          message_order: "ascending",
          hide_read_threads: false,
          only_wo_answer: false,
          thread_modifier: nil,
          use_paging: true,
          close_read_threads: false,
          open_close_default_state: "open",
          thread_conditions: %{},
          predicate: nil
        ],
        opts
      )

    order =
      case opts[:order] do
        "descending" ->
          [desc: :created_at]

        "ascending" ->
          [asc: :created_at]

        # falling back to "newest-first" for all other cases
        _ ->
          [desc: :latest_message]
      end

    {sticky_threads_query, threads_query} =
      get_threads(
        forum,
        user,
        visible_forums,
        sticky: opts[:sticky],
        view_all: opts[:view_all],
        hide_read_threads: opts[:hide_read_threads],
        only_wo_answer: opts[:only_wo_answer],
        leave_out_invisible: opts[:leave_out_invisible],
        thread_conditions: opts[:thread_conditions],
        predicate: opts[:predicate]
      )

    sticky_threads = get_sticky_threads(sticky_threads_query, user, order, opts, opts[:sticky])
    {all_threads_count, threads} = get_normal_threads(threads_query, user, order, length(sticky_threads), opts)

    {all_threads_count, sticky_threads ++ threads}
  end

  def list_archived_threads(forum, visible_forums, user, from, to, opts \\ []) do
    opts =
      Keyword.merge(
        [
          page: 0,
          limit: 50,
          view_all: false,
          leave_out_invisible: true,
          order: "newest-first",
          message_order: "ascending",
          thread_modifier: nil,
          use_paging: true,
          close_read_threads: false,
          open_close_default_state: "open",
          thread_conditions: %{},
          predicate: nil
        ],
        opts
      )

    order =
      case opts[:order] do
        "descending" ->
          [desc: :created_at]

        "ascending" ->
          [asc: :created_at]

        # falling back to "newest-first" for all other cases
        _ ->
          [desc: :latest_message]
      end

    threads_query =
      get_archived_threads(
        forum,
        user,
        visible_forums,
        from,
        to,
        view_all: opts[:view_all],
        leave_out_invisible: opts[:leave_out_invisible],
        thread_conditions: opts[:thread_conditions],
        predicate: opts[:predicate]
      )

    get_normal_threads(threads_query, user, order, 0, opts)
  end

  def list_invisible_threads(forum, visible_forums, user, opts \\ []) do
    opts =
      Keyword.merge(
        [
          predicate: fn query ->
            from(
              thread in query,
              where:
                fragment(
                  "EXISTS(SELECT thread_id FROM invisible_threads WHERE user_id = ? AND invisible_threads.thread_id = ?)",
                  ^user.user_id,
                  thread.thread_id
                )
            )
          end
        ],
        opts
      )

    list_threads(forum, visible_forums, user, opts)
  end

  def list_unanswered_threads(visible_forums, user, opts \\ []) do
    fids = Enum.map(visible_forums, & &1.forum_id)

    opts =
      Keyword.merge(
        [
          predicate: fn query ->
            from(
              thread in query,
              where:
                fragment(
                  """
                  ? IN (SELECT threads.thread_id FROM threads
                         INNER JOIN messages USING(thread_id)
                         WHERE archived = false AND threads.deleted = false AND
                           messages.deleted = false AND threads.forum_id = ANY(?) AND
                           (messages.flags->>'no-answer-admin' = 'no' OR (messages.flags->>'no-answer-admin') IS NULL) AND
                           (messages.flags->>'no-answer' = 'no' OR (messages.flags->>'no-answer') IS NULL)
                           GROUP BY threads.thread_id HAVING COUNT(*) <= 1)
                  """,
                  thread.thread_id,
                  type(^fids, {:array, :integer})
                )
            )
          end
        ],
        opts
      )

    list_threads(nil, visible_forums, user, opts)
  end

  def list_archive_years(forum, visible_forums) do
    from(
      thread in Thread,
      select: fragment("DATE_TRUNC('year', created_at) AS year"),
      where: thread.deleted == false,
      group_by: fragment("1"),
      order_by: fragment("1 DESC")
    )
    |> set_forum_id(visible_forums, forum)
    |> Repo.all()
  end

  def list_archive_months(forum, visible_forums, year) do
    from(
      thread in Thread,
      select: fragment("DATE_TRUNC('month', created_at) AS year"),
      where: thread.deleted == false and fragment("EXTRACT('year' from ?)", thread.created_at) == type(^year, :integer),
      group_by: fragment("1"),
      order_by: fragment("1 DESC")
    )
    |> set_forum_id(visible_forums, forum)
    |> Repo.all()
  end

  defp set_forum_id(q, visible_forums, nil) do
    visible_forums = Enum.map(visible_forums, & &1.forum_id)
    from(thread in q, where: thread.forum_id in ^visible_forums)
  end

  defp set_forum_id(q, _, forum), do: from(thread in q, where: thread.forum_id == ^forum.forum_id)

  @doc """
  Gets a single thread.

  Raises `Ecto.NoResultsError` if the Thread does not exist.

  ## Examples

      iex> get_thread!(123)
      %Thread{}

      iex> get_thread!(456)
      ** (Ecto.NoResultsError)

  """
  def get_thread!(user, id, opts \\ []) do
    opts =
      Keyword.merge(
        [
          view_all: false,
          message_order: "ascending",
          hide_read_threads: false,
          only_wo_answer: false,
          thread_modifier: nil,
          use_paging: false
        ],
        opts
      )

    q = from(thread in Thread, where: thread.thread_id == ^id)
    ret = get_normal_threads(q, user, [desc: :created_at], 0, opts)

    case ret do
      {_, []} ->
        raise Ecto.NoResultsError, queryable: q

      {_, [thread]} ->
        thread
    end
  end

  @doc """
  Gets a single thread by its slug.

  Raises `Ecto.NoResultsError` if the Thread does not exist.

  ## Examples

      iex> get_thread!("2017/08/25/foo-bar")
      %Thread{}

      iex> get_thread!("2017/08/32/non-existant")
      ** (Ecto.NoResultsError)

  """
  def get_thread_by_slug!(user, slug, opts \\ []) do
    opts =
      Keyword.merge(
        [
          view_all: false,
          message_order: "ascending",
          hide_read_threads: false,
          only_wo_answer: false,
          thread_modifier: nil,
          use_paging: false
        ],
        opts
      )

    q =
      from(
        thread in Thread,
        where: thread.slug == ^slug
      )

    ret = get_normal_threads(q, user, [desc: :created_at], 0, opts)

    case ret do
      {_, []} ->
        raise Ecto.NoResultsError, queryable: q

      {_, [thread]} ->
        thread
    end
  end

  @doc """
  Gets threads by their tid. Tids are historically not unique, so you might get more than one thread.

  Raises `Ecto.NoResultsError` if no thread could be found.

  ## Examples

      iex> get_threads_by_tid!(1)
      [%Thread{}]

      iex> get_thread!(-1)
      ** (Ecto.NoResultsError)

  """
  def get_threads_by_tid!(user, tid, opts \\ []) do
    opts =
      Keyword.merge(
        [
          view_all: false,
          message_order: "ascending",
          hide_read_threads: false,
          only_wo_answer: false,
          thread_modifier: nil,
          use_paging: false
        ],
        opts
      )

    q =
      from(
        thread in Thread,
        where: thread.tid == ^tid
      )

    ret = get_normal_threads(q, user, [desc: :created_at], 0, opts)

    case ret do
      {_, []} ->
        raise Ecto.NoResultsError, queryable: q

      {_, threads} ->
        threads
    end
  end

  def slug_taken?(slug) do
    from(t in Thread, where: t.slug == ^slug)
    |> Repo.exists?()
  end

  @doc """
  Creates a thread.

  ## Examples

      iex> create_thread(%{field: value})
      {:ok, %Thread{}}

      iex> create_thread(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_thread(attrs, user, forum, visible_forums) do
    retval =
      Repo.transaction(fn ->
        retval =
          %Thread{latest_message: Timex.local()}
          |> Thread.changeset(attrs, forum, visible_forums)
          |> Repo.insert()

        case retval do
          {:ok, thread} ->
            create_message(attrs, user, visible_forums, thread)

          {:error, t_changeset} ->
            thread = Ecto.Changeset.apply_changes(t_changeset)
            # we need a changeset with an action; since thread_id is empty this always fails
            create_message(attrs, user, visible_forums, thread)
        end
      end)

    case retval do
      {:ok, {:ok, thread, message}} ->
        {:ok, Repo.preload(thread, [:forum]), message}

      _ ->
        retval
    end
  end

  defp create_message(attrs, user, visible_forums, thread) do
    case Messages.create_message(attrs, user, visible_forums, thread) do
      {:ok, message} ->
        {:ok, thread, message}

      {:error, changeset} ->
        Repo.rollback(changeset)
    end
  end

  @doc """
  Updates a thread.

  ## Examples

      iex> update_thread(thread, %{field: new_value})
      {:ok, %Thread{}}

      iex> update_thread(thread, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_thread(%Thread{} = thread, attrs, forum, visible_forums) do
    thread
    |> thread_changeset(attrs, forum, visible_forums)
    |> Repo.update()
  end

  @doc """
  Deletes a Thread.

  ## Examples

      iex> delete_thread(thread)
      {:ok, %Thread{}}

      iex> delete_thread(thread)
      {:error, %Ecto.Changeset{}}

  """
  def delete_thread(%Thread{} = thread) do
    Repo.delete(thread)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking thread changes.

  ## Examples

      iex> change_thread(thread)
      %Ecto.Changeset{source: %Thread{}}

  """
  def change_thread(%Thread{} = thread, forum \\ nil, visible_forums \\ []) do
    thread_changeset(thread, %{}, forum, visible_forums)
  end

  alias Cforum.Forums.Messages

  def preview_thread(attrs, user, forum, visible_forums) do
    changeset =
      %Thread{created_at: Timex.now()}
      |> Thread.changeset(attrs, forum, visible_forums)

    thread = Ecto.Changeset.apply_changes(changeset)
    {message, msg_changeset} = Messages.preview_message(attrs, user, thread)

    forum = Enum.find(visible_forums, &(&1.forum_id == message.forum_id))

    thread = %Thread{
      thread
      | forum: forum,
        forum_id: message.forum_id,
        messages: [message],
        message: message
    }

    {thread, message, msg_changeset}
  end

  defp thread_changeset(%Thread{} = thread, attrs, forum, visible_forums) do
    Thread.changeset(thread, attrs, forum, visible_forums)
  end

  @doc """
  Returns the order value itself if it is valid; returns the
  configured value for the current forum (or the global config) when
  invalid

  ## Examples

      iex> validated_ordering("ascending")
      "ascending"

      iex> validated_ordering("foo")
      "newest-first"
  """
  def validated_ordering(order, forum \\ nil) do
    if Enum.member?(~w(ascending descending newest-first), order),
      do: order,
      else: Cforum.ConfigManager.conf("sort_threads", forum)
  end

  @doc """
  Generate a thread slug from a params map.

  ## Example

      iex> slug_from_params(%{"year" => "2017", "month" => "jan", "day" => "31", "slug" => "foo"})
      "/2017/jan/31/foo"
  """
  def slug_from_params(%{"year" => year, "month" => month, "day" => day, "slug" => slug}),
    do: "/#{year}/#{month}/#{day}/#{slug}"

  def hide_thread(user, thread) do
    %InvisibleThread{}
    |> InvisibleThread.changeset(%{thread_id: thread.thread_id, user_id: user.user_id})
    |> Repo.insert()
  end

  def unhide_thread(user, thread) do
    invisible =
      InvisibleThread
      |> Repo.get_by(user_id: user.user_id, thread_id: thread.thread_id)

    if invisible, do: Repo.delete(invisible), else: nil
  end

  def get_open_closed_state(user, thread),
    do: Repo.get_by(OpenCloseState, user_id: user.user_id, thread_id: thread.thread_id)

  def open_thread(user, thread) do
    oc = get_open_closed_state(user, thread)

    if oc != nil && oc.state != "open" do
      Repo.delete(oc)
    else
      %OpenCloseState{}
      |> OpenCloseState.changeset(%{user_id: user.user_id, thread_id: thread.thread_id, state: "open"})
      |> Repo.insert()
    end
  end

  def close_thread(user, thread) do
    oc = get_open_closed_state(user, thread)

    if oc != nil && oc.state != "closed" do
      Repo.delete(oc)
    else
      %OpenCloseState{}
      |> OpenCloseState.changeset(%{user_id: user.user_id, thread_id: thread.thread_id, state: "closed"})
      |> Repo.insert()
    end
  end
end
