defmodule Cforum.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Events.{Event, Attendee}
  alias Cforum.System

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events(query_params \\ [order: nil, limit: nil, only_visible: false]) do
    Event
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> set_only_visible(query_params[:only_visible])
    |> Repo.all()
    |> Repo.preload(
      attendees:
        from(
          a in Attendee,
          left_join: user in assoc(a, :user),
          order_by: user.username,
          preload: [user: user]
        )
    )
  end

  def count_events(only_visible \\ false) do
    Event
    |> select(count("*"))
    |> set_only_visible(only_visible)
    |> Repo.one()
  end

  def set_only_visible(q, true), do: from(ev in q, where: ev.visible == true)
  def set_only_visible(q, _), do: q

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id, only_visible \\ false) do
    from(event in Event, where: event.event_id == ^id)
    |> set_only_visible(only_visible)
    |> Repo.one!()
    |> Repo.preload(
      attendees:
        from(
          a in Attendee,
          left_join: user in assoc(a, :user),
          order_by: user.username,
          preload: [user: user]
        )
    )
  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(current_user, attrs \\ %{}) do
    System.audited("create", current_user, fn ->
      %Event{}
      |> Event.changeset(attrs)
      |> Repo.insert()
    end)
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(current_user, %Event{} = event, attrs) do
    System.audited("update", current_user, fn ->
      event
      |> Event.changeset(attrs)
      |> Repo.update()
    end)
  end

  @doc """
  Deletes a Event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(current_user, %Event{} = event) do
    System.audited("destroy", current_user, fn ->
      Repo.delete(event)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{source: %Event{}}

  """
  def change_event(%Event{} = event) do
    Event.changeset(event, %{})
  end

  def open?(event), do: event.visible && Timex.before?(Timex.now(), event.end_date)
end
