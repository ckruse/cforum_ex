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

  def list_last_messages_for_user(user, forum_ids, limit \\ 5) do
    from(m in Message,
      preload: [:user, :tags, [votes: :voters, thread: :forum]],
      where: m.user_id == ^user.user_id and m.deleted == false and m.forum_id in (^forum_ids),
      order_by: [desc: :created_at],
      limit: ^limit)
    |> Repo.all
  end

  def list_best_scored_messages_for_user(user, forum_ids, limit \\ 10) do
    from(m in Message,
      preload: [:user, :tags, [votes: :voters, thread: :forum]],
      where: m.deleted == false and m.upvotes > 0 and m.user_id == ^user.user_id and m.forum_id in (^forum_ids),
      order_by: [desc: m.upvotes],
      limit: ^limit)
    |> Repo.all
  end

  def list_scored_msgs_for_user_in_perspective(cuser, user, forum_ids, limit \\ nil)
  def list_scored_msgs_for_user_in_perspective(%User{user_id: cuid}, user = %User{user_id: uid}, forum_ids, limit) when cuid == uid do
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
    |> set_limit(limit)
  end

  def list_scored_msgs_for_user_in_perspective(_, user, forum_ids, limit) do
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
    |> set_limit(limit)
  end

  defp set_limit(q, nil), do: q
  defp set_limit(q, limit), do: from(s in q, limit: ^limit)

  def count_messages_for_user(user) do
    from(m in Message,
      select: count("*"),
      where: m.user_id == ^user.user_id and m.deleted == false)
    |> Repo.one
  end

  def count_messages_for_user_by_month(user) do
    from(m in Message,
         select: {fragment("DATE_TRUNC('month', created_at) created_at"), count("*")},
         where: m.user_id == ^user.user_id and m.deleted == false,
         group_by: fragment("DATE_TRUNC('month', created_at)"),
         order_by: fragment("DATE_TRUNC('month', created_at)"))
    |> Repo.all
  end

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
