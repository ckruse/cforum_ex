defmodule Cforum.MessagesUsers do
  import Ecto.Query, warn: false

  alias Cforum.Repo
  alias Cforum.Messages.Message
  alias Cforum.MessagesTags.MessageTag
  alias Cforum.Tags.Tag
  alias Cforum.Votes.Vote
  alias Cforum.Scores.Score
  alias Cforum.Users.User

  @doc """
  Returns a list of messages for a user, limited to the forums specified in `forum_ids`

  ## Examples

      iex> list_messages_for_user(%User{}, [1, 2], limin: [quantity: 10, offset: 0])
      [%Message{}, ...]
  """
  def list_messages_for_user(user, forum_ids, query_params \\ [order: nil, limit: nil]) do
    from(
      m in Message,
      preload: [:user, thread: :forum],
      where: m.user_id == ^user.user_id and m.deleted == false and m.forum_id in ^forum_ids
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
    |> Repo.preload(tags: from(t in Tag, order_by: [asc: :tag_name]))
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
      preload: [:user, [thread: :forum]],
      where: m.deleted == false and m.upvotes > 0 and m.user_id == ^user.user_id and m.forum_id in ^forum_ids,
      order_by: fragment("upvotes - downvotes DESC"),
      limit: ^limit
    )
    |> Repo.all()
    |> Repo.preload(tags: from(t in Tag, order_by: [asc: :tag_name]))
  end

  defp int_list_scored_msgs_for_user_in_perspective(cuser, user, forum_ids, limit)

  defp int_list_scored_msgs_for_user_in_perspective(%User{user_id: cuid}, user = %User{user_id: uid}, forum_ids, limit)
       when cuid == uid do
    from(
      s in Score,
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
    |> Repo.preload(
      message: [:user, tags: from(t in Tag, order_by: [asc: :tag_name]), thread: :forum],
      vote: [message: [:user, tags: from(t in Tag, order_by: [asc: :tag_name]), thread: :forum]]
    )
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
end
