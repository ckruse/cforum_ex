defmodule Cforum.Messages.InterestingMessages do
  import Ecto.Query, warn: false

  alias Cforum.Repo
  alias Cforum.Messages.Message
  alias Cforum.Messages.InterestingMessage
  alias Cforum.Messages.Tag

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
      preload: [:user, thread: :forum]
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
    |> Repo.preload(tags: from(t in Tag, order_by: [asc: :tag_name]))
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
end
