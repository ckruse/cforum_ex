defmodule Cforum.Subscriptions do
  import Ecto.Query, warn: false

  alias Cforum.Repo
  alias Cforum.Messages.Message
  alias Cforum.Messages.MessageHelpers
  alias Cforum.Subscriptions.Subscription
  alias Cforum.Tags.Tag

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
      on: s.message_id == msg.message_id,
      where: s.user_id == ^user.user_id,
      preload: [:user, thread: :forum]
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
    |> Repo.preload(tags: from(t in Tag, order_by: [asc: :tag_name]))
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
      on: s.message_id == msg.message_id,
      where: s.user_id == ^user.user_id,
      select: count()
    )
    |> Repo.one()
  end

  def maybe_autosubscribe({:error, changeset}, _, _, _, _), do: {:error, changeset}
  def maybe_autosubscribe(val, false, _, _, _), do: val

  def maybe_autosubscribe({:ok, message}, subtype, user, thread, parent) do
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

  @doc """
  Returns true if the parent message is marked interesting.

  ## Examples

      iex> parent_subscribed?(%Thread{}, %Message{})
      true
  """
  def parent_subscribed?(thread, message)
  def parent_subscribed?(_, %Message{parent_id: nil}), do: false

  def parent_subscribed?(thread, message) do
    parent = MessageHelpers.parent_message(thread, message)
    parent.attribs[:is_subscribed] == true || parent_subscribed?(thread, parent)
  end

  def autosubscribe?(user, config_value)
  def autosubscribe?(user, val) when is_nil(user) or val == "no", do: false
  def autosubscribe?(_, val), do: val
end
