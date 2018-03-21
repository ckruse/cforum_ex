defmodule Cforum.Accounts.PrivMessages do
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.Query, warn: false
  import Cforum.Helpers

  alias Cforum.Repo
  alias Cforum.Accounts.PrivMessage

  alias Cforum.Helpers.CompositionHelpers

  @doc """
  Returns the list of priv_messages.

  ## Examples

      iex> list_priv_messages()
      [%PrivMessage{}, ...]

  """
  def list_priv_messages(user, query_params \\ [order: nil, limit: nil, messages_order: nil]) do
    from(
      pm in PrivMessage,
      where:
        pm.owner_id == ^user.user_id and
          pm.priv_message_id in fragment(
            "SELECT MIN(priv_message_id) FROM priv_messages WHERE owner_id = ? GROUP BY thread_id",
            ^user.user_id
          ),
      preload: [:recipient, :sender]
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
    |> Repo.preload(
      messages:
        {from(pm in PrivMessage, where: pm.owner_id == ^user.user_id)
         |> order_messages(query_params[:messages_order]), [:recipient, :sender]}
    )
  end

  def list_newest_priv_messages_of_each_thread(user, query_params \\ [order: nil, limit: nil, messages_order: nil]) do
    from(
      pm in PrivMessage,
      where:
        pm.owner_id == ^user.user_id and
          pm.priv_message_id in fragment(
            "SELECT MAX(priv_message_id) FROM priv_messages WHERE owner_id = ? GROUP BY thread_id",
            ^user.user_id
          ),
      preload: [:recipient, :sender]
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
  end

  def order_messages(q, :asc), do: order_by(q, asc: :created_at)
  def order_messages(q, _), do: order_by(q, desc: :created_at)

  def count_priv_messages(user, only_unread \\ false)

  def count_priv_messages(user, false) do
    from(
      pm in PrivMessage,
      where:
        pm.owner_id == ^user.user_id and
          pm.priv_message_id in fragment(
            "SELECT MIN(priv_message_id) FROM priv_messages WHERE owner_id = ? GROUP BY thread_id",
            ^user.user_id
          ),
      select: count("*")
    )
    |> Repo.one()
  end

  def count_priv_messages(user, true) do
    from(pm in PrivMessage, where: pm.owner_id == ^user.user_id and pm.is_read == false, select: count("*"))
    |> Repo.one()
  end

  @doc """
  Gets a single priv_messages.

  Raises `Ecto.NoResultsError` if the Priv messages does not exist.

  ## Examples

      iex> get_priv_messages!(123)
      %PrivMessage{}

      iex> get_priv_messages!(456)
      ** (Ecto.NoResultsError)

  """
  def get_priv_message!(user, id) do
    PrivMessage
    |> Repo.get_by!(priv_message_id: id, owner_id: user.user_id)
    |> Repo.preload([:sender, :recipient])
  end

  def get_priv_message_thread!(user, tid, query_params \\ [messages_order: nil]) do
    from(
      pm in PrivMessage,
      where: pm.thread_id == ^tid and pm.owner_id == ^user.user_id,
      preload: [:sender, :recipient]
    )
    |> order_messages(query_params[:messages_order])
    |> Repo.all()
  end

  @doc """
  Creates a priv_messages.

  ## Examples

      iex> create_priv_messages(%{field: value})
      {:ok, %PrivMessage{}}

      iex> create_priv_messages(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_priv_message(current_user, attrs \\ %{}) do
    retval =
      Repo.transaction(fn ->
        pm =
          %PrivMessage{sender_id: current_user.user_id}
          |> PrivMessage.changeset(attrs)
          |> Repo.insert()

        case pm do
          {:ok, foreign_pm} ->
            priv_message = Repo.get!(PrivMessage, foreign_pm.priv_message_id)

            %PrivMessage{
              owner_id: current_user.user_id,
              sender_id: current_user.user_id,
              is_read: true,
              thread_id: priv_message.thread_id
            }
            |> PrivMessage.changeset(attrs)
            |> Repo.insert()

          _ ->
            pm
        end
      end)

    case retval do
      {:ok, term} ->
        term

      _ ->
        retval
    end
  end

  @doc """
  Updates a priv_messages.

  ## Examples

      iex> update_priv_messages(priv_messages, %{field: new_value})
      {:ok, %PrivMessage{}}

      iex> update_priv_messages(priv_messages, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_priv_message(%PrivMessage{} = priv_messages, attrs) do
    priv_messages
    |> PrivMessage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PrivMessage.

  ## Examples

      iex> delete_priv_messages(priv_messages)
      {:ok, %PrivMessage{}}

      iex> delete_priv_messages(priv_messages)
      {:error, %Ecto.Changeset{}}

  """
  def delete_priv_message(%PrivMessage{} = priv_messages) do
    Repo.delete(priv_messages)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking priv_messages changes.

  ## Examples

      iex> change_priv_messages(priv_messages)
      %Ecto.Changeset{source: %PrivMessage{}}

  """
  def change_priv_message(%PrivMessage{} = priv_messages, attrs \\ %{}) do
    PrivMessage.changeset(priv_messages, attrs)
  end

  def preview_priv_message(attrs \\ %{}) do
    changeset = change_priv_message(%PrivMessage{created_at: Timex.now()}, attrs)
    {Ecto.Changeset.apply_changes(changeset), changeset}
  end

  def new_changeset(%PrivMessage{} = priv_message, opts \\ []) do
    opts =
      Keyword.merge(
        [
          greeting: nil,
          farewell: nil,
          signature: nil,
          quote: true,
          std_replacement: "all"
        ],
        opts
      )

    content =
      ""
      |> CompositionHelpers.maybe_add_greeting(opts[:greeting], nil, opts[:std_replacement])
      |> CompositionHelpers.maybe_add_farewell(opts[:farewell])
      |> CompositionHelpers.maybe_add_signature(opts[:signature])

    change_priv_message(priv_message, %{body: content})
  end

  def answer_changeset(%PrivMessage{} = priv_message, parent, opts \\ []) do
    opts =
      Keyword.merge(
        [
          strip_signature: true,
          greeting: nil,
          farewell: nil,
          signature: nil,
          quote: true,
          std_replacement: parent.sender.username,
          subject_prefix: "RE: "
        ],
        opts
      )

    cnt =
      if opts[:quote],
        do: attribute_value(parent, :body, ""),
        else: ""

    content =
      cnt
      |> CompositionHelpers.quote_from_content(opts[:strip_signature])
      |> CompositionHelpers.maybe_add_greeting(opts[:greeting], parent.sender.username, opts[:std_replacement])
      |> CompositionHelpers.maybe_add_farewell(opts[:farewell])
      |> CompositionHelpers.maybe_add_signature(opts[:signature])

    subject = CompositionHelpers.subject_from_parent(parent.subject, opts[:subject_prefix])

    change_priv_message(priv_message, %{subject: subject, body: content, recipient_id: parent.sender_id})
  end

  def mark_priv_message(%PrivMessage{} = priv_message, type) do
    mark = if type == :unread, do: false, else: true

    priv_message
    |> PrivMessage.mark_changeset(%{is_read: mark})
    |> Repo.update()
  end

  def partner_name(%PrivMessage{owner_id: oid, recipient_id: rid} = msg) when oid == rid, do: msg.sender_name
  def partner_name(%PrivMessage{} = msg), do: msg.recipient_name

  def partner_id(%PrivMessage{owner_id: oid, recipient_id: rid} = msg) when oid == rid, do: msg.sender_id
  def partner_id(%PrivMessage{} = msg), do: msg.recipient_id

  def partner(%PrivMessage{owner_id: oid, recipient_id: rid} = msg) when oid == rid, do: msg.sender
  def partner(%PrivMessage{} = msg), do: msg.recipient
end
