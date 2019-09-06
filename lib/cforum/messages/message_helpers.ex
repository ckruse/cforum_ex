defmodule Cforum.Messages.MessageHelpers do
  import Ecto.Query, warn: false

  alias Cforum.Messages.Message
  alias Cforum.Accounts.Users
  alias Cforum.Helpers

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
  def find_message(%Cforum.Threads.Thread{tree: %Message{}} = thread, fun), do: find_message([thread.tree], fun)
  def find_message(%Cforum.Threads.Thread{messages: messages}, fun), do: find_message(messages, fun)
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

  def changed?(changeset, message) do
    message.content != Ecto.Changeset.get_field(changeset, :content) ||
      message.subject != Ecto.Changeset.get_field(changeset, :subject) || tags_changed?(changeset, message)
  end

  def tags_changed?(changeset, message) do
    message_tag_ids = Enum.map(message.tags, & &1.tag_id) |> Enum.sort()
    changeset_tag_ids = Enum.map(Ecto.Changeset.get_field(changeset, :tags, []), & &1.tag_id) |> Enum.sort()

    message_tag_ids != changeset_tag_ids
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
  def no_answer?(message),
    do: message.flags["no-answer-admin"] == "yes" || (!admin_decision?(message) && message.flags["no-answer"] == "yes")

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
  def score_str(msg), do: Helpers.score_str(no_votes(msg), score(msg))

  @spec answer?(%Cforum.Threads.Thread{}, %Message{}) :: boolean()
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

  def may_user_post_with_name?(_, nil), do: true
  def may_user_post_with_name?(nil, name), do: not Users.username_taken?(name)

  def may_user_post_with_name?(user, name) do
    clean_name = name |> String.trim() |> String.downcase()

    if String.downcase(user.username) == clean_name,
      do: true,
      else: may_user_post_with_name?(nil, name)
  end

  def maybe_set_cookies(conn, %{user_id: id}) when id != nil, do: conn

  def maybe_set_cookies(conn, message, uuid) do
    conn
    |> set_cookie_if_value("cforum_user", uuid)
    |> set_cookie_if_value("cforum_author", message.author)
    |> set_cookie_if_value("cforum_email", message.email)
    |> set_cookie_if_value("cforum_homepage", message.homepage)
  end

  defp set_cookie_if_value(conn, _, nil), do: conn

  defp set_cookie_if_value(conn, cookie, value),
    do: Plug.Conn.put_resp_cookie(conn, cookie, value, http_only: false, max_age: 30 * 24 * 60 * 60)

  def uuid(conn) do
    cond do
      Helpers.blank?(conn.assigns[:current_user]) && Helpers.present?(conn.cookies["cforum_user"]) ->
        conn.cookies["cforum_user"]

      Helpers.blank?(conn.assigns[:current_user]) ->
        UUID.uuid1()

      true ->
        nil
    end
  end
end
