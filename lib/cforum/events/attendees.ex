defmodule Cforum.Events.Attendees do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Events.Event
  alias Cforum.Events.Attendee
  alias Cforum.System

  @doc """
  Returns the list of attendees.

  ## Examples

      iex> list_attendees(%Event{})
      [%Attendee{}, ...]

  """
  def list_attendees(%Event{} = event, query_params \\ [order: nil, limit: nil]) do
    from(attendee in Attendee, where: attendee.event_id == ^event.event_id)
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :created_at)
    |> Repo.all()
    |> Repo.preload([:user])
  end

  @doc """
  Gets a single attendee.

  Raises `Ecto.NoResultsError` if the Attendee does not exist.

  ## Examples

      iex> get_attendee!(%Event{}, 123)
      %Attendee{}

      iex> get_attendee!(%Event{}, 456)
      ** (Ecto.NoResultsError)

  """
  def get_attendee!(%Event{} = event, id) do
    from(attendee in Attendee, where: attendee.event_id == ^event.event_id and attendee.attendee_id == ^id)
    |> Repo.one!()
    |> Repo.preload([:user])
  end

  @doc """
  Creates an attendee.

  ## Examples

      iex> create_attendee(%Event{}, %{field: value})
      {:ok, %Attendee{}}

      iex> create_attendee(%Event{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_attendee(%Event{} = event, user, attrs \\ %{}) do
    System.audited("create", user, fn ->
      %Attendee{event_id: event.event_id}
      |> Attendee.changeset(attrs, user)
      |> Repo.insert()
    end)
  end

  @doc """
  Updates an attendee.

  ## Examples

      iex> update_attendee(attendee, %{field: new_value})
      {:ok, %Attendee{}}

      iex> update_attendee(attendee, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_attendee(current_user, %Attendee{} = attendee, attrs) do
    System.audited("update", current_user, fn ->
      attendee
      |> Attendee.changeset(attrs)
      |> Repo.update()
    end)
  end

  @doc """
  Deletes an Attendee.

  ## Examples

      iex> delete_attendee(attendee)
      {:ok, %Attendee{}}

      iex> delete_attendee(attendee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_attendee(current_user, %Attendee{} = attendee) do
    System.audited("destroy", current_user, fn ->
      Repo.delete(attendee)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking attendee changes.

  ## Examples

      iex> change_attendee(attendee)
      %Ecto.Changeset{source: %Attendee{}}

  """
  def change_attendee(%Attendee{} = attendee, user \\ nil) do
    Attendee.changeset(attendee, %{}, user)
  end
end
