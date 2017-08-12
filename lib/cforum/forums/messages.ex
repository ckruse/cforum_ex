defmodule Cforum.Forums.Messages do
  @moduledoc """
  The boundary for the Forums system.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Forums.Forum
  alias Cforum.Forums.Message
  alias Cforum.Forums.Tag
  alias Cforum.Forums.MessageTag
  alias Cforum.Forums.Vote

  alias Cforum.Accounts.User
  alias Cforum.Accounts.Score

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Returns a list of messages for a user, limited to the forums specified in `forum_ids`

  ## Examples

      iex> list_messages_for_user(%User{}, [1, 2], quantity: 10, offset: 0)
      [%Message{}, ...]
  """
  def list_messages_for_user(user, forum_ids, query_params \\ [order: nil, limit: nil]) do
    from(m in Message,
      preload: [:user, :tags, [votes: :voters, thread: :forum]],
      where: m.user_id == ^user.user_id and m.deleted == false and m.forum_id in (^forum_ids))
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], [desc: :created_at])
    |> Repo.all
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
      where: m.user_id == ^user.user_id and m.deleted == false and m.forum_id in (^forum_ids),
      select: count("*")
    )
    |> Repo.one
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
    from(m in Message,
      preload: [:user, :tags, [votes: :voters, thread: :forum]],
      where: m.deleted == false and m.upvotes > 0 and m.user_id == ^user.user_id and m.forum_id in (^forum_ids),
      order_by: fragment("upvotes - downvotes DESC"),
      limit: ^limit)
    |> Repo.all
  end

  defp int_list_scored_msgs_for_user_in_perspective(cuser, user, forum_ids, limit)
  defp int_list_scored_msgs_for_user_in_perspective(%User{user_id: cuid}, user = %User{user_id: uid}, forum_ids, limit) when cuid == uid do
    from(s in Score,
      preload: [message: [:user, :tags, [thread: :forum, votes: :voters]],
                vote: [message: [:user, :tags, [thread: :forum, votes: :voters]]]],
      left_join: m1 in Message, on: m1.message_id == s.message_id,
      left_join: v in Vote, on: s.vote_id == v.vote_id,
      left_join: m2 in Message, on: v.message_id == m2.message_id,
      where: s.user_id == ^user.user_id,
      where: is_nil(m1.message_id) or m1.forum_id in (^forum_ids),
      where: is_nil(m2.message_id) or m2.forum_id in (^forum_ids),
      where: is_nil(m1.message_id) or m1.deleted == false,
      where: is_nil(m2.message_id) or m2.deleted == false,
      order_by: [desc: :created_at])
    |> Cforum.PagingApi.set_limit(limit)
  end
  defp int_list_scored_msgs_for_user_in_perspective(_, user, forum_ids, limit) do
    from(s in Score,
      preload: [message: [:user, :tags, [thread: :forum, votes: :voters]],
                vote: [message: [:user, :tags, [thread: :forum, votes: :voters]]]],
      left_join: m1 in Message, on: m1.message_id == s.message_id,
      left_join: v in Vote, on: s.vote_id == v.vote_id,
      left_join: m2 in Message, on: v.message_id == m2.message_id,
      where: s.user_id == ^user.user_id,
      where: is_nil(m1.message_id) or m1.forum_id in (^forum_ids),
      where: is_nil(m2.message_id) or m2.forum_id in (^forum_ids),
      where: is_nil(m1.message_id) or m1.deleted == false,
      where: is_nil(m2.message_id) or m2.deleted == false,
      where: m2.user_id == ^user.user_id,
      order_by: [desc: :created_at])
    |> Cforum.PagingApi.set_limit(limit)
  end

  @doc """
  List scored messages for a user in the perspective of another user, i.e. leave out
  negative votings (a user gets a negative score for voting negative) if user
  doesn't look at his own scores; is limited to the forums defined in `forum_ids`

  ## Arguments

  cuser: the user which perspective we are look on this, i.e. the `current_user`
  user: the user we are watching at
  forum_ids: the list of forums we are interested in
  limit: the number of messages we want to get

  ## Examples

      iex> list_scored_msgs_for_user_in_perspective(nil, %User{}, [1, 2])
      [%Message{}, ...]

      iex> list_scored_msgs_for_user_in_perspective(%User{}, %User{}, [1, 2])
      [%Message{}]
  """
  def list_scored_msgs_for_user_in_perspective(cuser, user, forum_ids, limit \\ nil) do
    int_list_scored_msgs_for_user_in_perspective(cuser, user, forum_ids, limit)
    |> Repo.all
  end

  @doc """
  Count the scored messages of the user in perspective; for a better explanation
  look at `list_scored_msgs_for_user_in_perspective`

  ## Examples

      iex> count_scored_msgs_for_user_in_perspective(nil, %User{}, [1, 2])
      1
  """
  def count_scored_msgs_for_user_in_perspective(cuser, user, forum_ids) do
    int_list_scored_msgs_for_user_in_perspective(cuser, user, forum_ids, nil)
    |> exclude(:preload)
    |> exclude(:order_by)
    |> select(count("*"))
    |> Repo.one
  end

  @doc """
  Counts the messages for a user, grouped by month; for statistical purposes

  ## Examples

      iex> count_messages_for_user_by_month(user)
      [{"2017-01-01", 10}, ...]
  """
  def count_messages_for_user_by_month(user, forum_ids) do
    from(m in Message,
         select: {fragment("DATE_TRUNC('month', created_at) created_at"), count("*")},
         where: m.user_id == ^user.user_id and m.deleted == false and m.forum_id in (^forum_ids),
         group_by: fragment("DATE_TRUNC('month', created_at)"),
         order_by: fragment("DATE_TRUNC('month', created_at)"))
    |> Repo.all
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
    from(mt in MessageTag,
      inner_join: m in Message, on: m.message_id == mt.message_id,
      inner_join: t in Tag, on: mt.tag_id == t.tag_id,
      inner_join: f in Forum, on: f.forum_id == t.forum_id,
      select: {t.slug, t.tag_name, f.slug, f.short_name, count("*")},
      where: m.deleted == false and m.user_id == ^user.user_id and m.forum_id in (^forum_ids),
      group_by: [t.slug, t.tag_name, f.forum_id, f.short_name],
      order_by: fragment("COUNT(*) DESC"),
      limit: ^limit)
    |> Repo.all
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
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
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{source: %Message{}}

  """
  def change_message(%Message{} = message) do
    Message.changeset(message, %{})
  end
end
