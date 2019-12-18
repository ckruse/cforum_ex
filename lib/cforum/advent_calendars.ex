defmodule Cforum.AdventCalendars do
  @moduledoc """
  The AdventCalendars context.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Helpers
  alias Cforum.AdventCalendars.Day

  def list_years do
    from(day in Day,
      select: fragment("EXTRACT(YEAR from ?)::character varying", day.date),
      group_by: [fragment("1")],
      order_by: [fragment("1")]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of advent_calendar_days.

  ## Examples

      iex> list_advent_calendar_days()
      [%Day{}, ...]

  """
  def list_advent_calendar_days(year) do
    from(day in Day, where: fragment("EXTRACT(YEAR from ?)", day.date) == ^Helpers.to_int(year), order_by: [asc: :date])
    |> Repo.all()
  end

  @doc """
  Gets a single day.

  Raises `Ecto.NoResultsError` if the Day does not exist.

  ## Examples

      iex> get_day!(123)
      %Day{}

      iex> get_day!(456)
      ** (Ecto.NoResultsError)

  """
  def get_day!(%DateTime{} = day), do: get_day!(Timex.to_date(day))
  def get_day!(%NaiveDateTime{} = day), do: get_day!(Timex.to_date(day))
  def get_day!(%Date{} = day), do: Repo.get_by!(Day, date: day)
  def get_day!(id), do: Repo.get!(Day, id)

  @doc """
  Creates a day.

  ## Examples

      iex> create_day(%{field: value})
      {:ok, %Day{}}

      iex> create_day(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_day(attrs \\ %{}) do
    %Day{}
    |> Day.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a day.

  ## Examples

      iex> update_day(day, %{field: new_value})
      {:ok, %Day{}}

      iex> update_day(day, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_day(%Day{} = day, attrs) do
    day
    |> Day.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Day.

  ## Examples

      iex> delete_day(day)
      {:ok, %Day{}}

      iex> delete_day(day)
      {:error, %Ecto.Changeset{}}

  """
  def delete_day(%Day{} = day) do
    Repo.delete(day)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking day changes.

  ## Examples

      iex> change_day(day)
      %Ecto.Changeset{source: %Day{}}

  """
  def change_day(%Day{} = day, params \\ %{}) do
    Day.changeset(day, params)
  end
end
