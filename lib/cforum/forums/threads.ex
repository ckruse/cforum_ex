defmodule Cforum.Forums.Threads do
  @moduledoc """
  The boundary for the Threads system.
  """

  import Ecto.{Query, Changeset}, warn: false
  import Cforum.Forums.Threads.Helper

  alias Cforum.Repo

  alias Cforum.Forums.Thread

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
          predicate: nil,
          view_all: false,
          order: "newest-first",
          message_order: "ascending",
          hide_read_threads: false,
          only_wo_answer: false,
          thread_modifier: nil,
          use_paging: true
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
        only_wo_answer: opts[:only_wo_answer]
      )

    sticky_threads = get_sticky_threads(sticky_threads_query, user, order, opts, opts[:sticky])
    {all_threads_count, threads} = get_normal_threads(threads_query, user, order, length(sticky_threads), opts)

    {all_threads_count, sticky_threads ++ threads}
  end

  @doc """
  Gets a single thread.

  Raises `Ecto.NoResultsError` if the Thread does not exist.

  ## Examples

      iex> get_thread!(123)
      %Thread{}

      iex> get_thread!(456)
      ** (Ecto.NoResultsError)

  """
  def get_thread!(id), do: Repo.get!(Thread, id)

  @doc """
  Gets a single thread by its slug.

  Raises `Ecto.NoResultsError` if the Thread does not exist.

  ## Examples

      iex> get_thread!("2017/08/25/foo-bar")
      %Thread{}

      iex> get_thread!("2017/08/32/non-existant")
      ** (Ecto.NoResultsError)

  """
  def get_thread_by_slug!(user, slug, opts) do
    opts =
      Keyword.merge(
        [
          predicate: nil,
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
  Creates a thread.

  ## Examples

      iex> create_thread(%{field: value})
      {:ok, %Thread{}}

      iex> create_thread(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_thread(attrs \\ %{}) do
    %Thread{}
    |> thread_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a thread.

  ## Examples

      iex> update_thread(thread, %{field: new_value})
      {:ok, %Thread{}}

      iex> update_thread(thread, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_thread(%Thread{} = thread, attrs) do
    thread
    |> thread_changeset(attrs)
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
  def change_thread(%Thread{} = thread) do
    thread_changeset(thread, %{})
  end

  defp thread_changeset(%Thread{} = thread, attrs) do
    thread
    |> cast(attrs, [:name])
    |> validate_required([:name])
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
end
