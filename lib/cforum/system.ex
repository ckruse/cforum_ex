defmodule Cforum.System do
  @moduledoc """
  The System context.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.System.Redirection

  @doc """
  Returns the list of redirections.

  ## Examples

      iex> list_redirections()
      [%Redirection{}, ...]

  """
  def list_redirections(query_params \\ [order: nil, limit: nil]) do
    Redirection
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :redirection_id)
    |> Repo.all()
  end

  @doc """
  Returns the number of users

  ## Examples

      iex> count_users()
      0
  """
  def count_redirections do
    Redirection
    |> select(count())
    |> Repo.one()
  end

  @doc """
  Gets a single redirection.

  Raises `Ecto.NoResultsError` if the Redirection does not exist.

  ## Examples

      iex> get_redirection!(123)
      %Redirection{}

      iex> get_redirection!(456)
      ** (Ecto.NoResultsError)

  """
  def get_redirection!(id), do: Repo.get!(Redirection, id)

  def get_redirection_by_path(path), do: Repo.get_by(Redirection, path: path)

  @doc """
  Creates a redirection.

  ## Examples

      iex> create_redirection(%{field: value})
      {:ok, %Redirection{}}

      iex> create_redirection(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_redirection(current_user, attrs \\ %{}) do
    audited("create", current_user, fn ->
      %Redirection{}
      |> Redirection.changeset(attrs)
      |> Repo.insert()
    end)
  end

  @doc """
  Updates a redirection.

  ## Examples

      iex> update_redirection(redirection, %{field: new_value})
      {:ok, %Redirection{}}

      iex> update_redirection(redirection, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_redirection(current_user, %Redirection{} = redirection, attrs) do
    audited("update", current_user, fn ->
      redirection
      |> Redirection.changeset(attrs)
      |> Repo.update()
    end)
  end

  @doc """
  Deletes a Redirection.

  ## Examples

      iex> delete_redirection(redirection)
      {:ok, %Redirection{}}

      iex> delete_redirection(redirection)
      {:error, %Ecto.Changeset{}}

  """
  def delete_redirection(current_user, %Redirection{} = redirection) do
    audited("destroy", current_user, fn ->
      Repo.delete(redirection)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking redirection changes.

  ## Examples

      iex> change_redirection(redirection)
      %Ecto.Changeset{source: %Redirection{}}

  """
  def change_redirection(%Redirection{} = redirection) do
    Redirection.changeset(redirection, %{})
  end

  alias Cforum.System.Auditing

  defp maybe_add_object_list(q, changeset) do
    case Ecto.Changeset.get_field(changeset, :objects) do
      nil ->
        q

      [] ->
        q

      objects ->
        from(auditing in q, where: auditing.relation in ^objects)
    end
  end

  @doc """
  Returns the list of auditing.

  ## Examples

      iex> list_auditing()
      [%Auditing{}, ...]

  """
  def list_auditing(changeset, query_params \\ [limit: nil]) do
    start_date = Ecto.Changeset.get_field(changeset, :from) |> Timex.to_datetime(:local) |> Timex.beginning_of_day()
    end_date = Ecto.Changeset.get_field(changeset, :to) |> Timex.to_datetime(:local) |> Timex.end_of_day()

    from(
      auditing in Auditing,
      where: auditing.created_at >= ^start_date and auditing.created_at <= ^end_date,
      preload: [:user],
      order_by: [desc: :created_at]
    )
    |> maybe_add_object_list(changeset)
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Repo.all()
  end

  def count_auditing(changeset) do
    start_date = Ecto.Changeset.get_field(changeset, :from) |> Timex.to_datetime() |> Timex.beginning_of_day()
    end_date = Ecto.Changeset.get_field(changeset, :to) |> Timex.to_datetime() |> Timex.end_of_day()

    from(auditing in Auditing, where: auditing.created_at >= ^start_date and auditing.created_at <= ^end_date)
    |> maybe_add_object_list(changeset)
    |> select(count())
    |> Repo.one()
  end

  @doc """
  Gets a single auditing.

  Raises `Ecto.NoResultsError` if the Auditing does not exist.

  ## Examples

      iex> get_auditing!(123)
      %Auditing{}

      iex> get_auditing!(456)
      ** (Ecto.NoResultsError)

  """
  def get_auditing!(id), do: Repo.get!(Auditing, id)

  @doc """
  Creates a auditing.

  ## Examples

      iex> create_auditing(%{field: value})
      {:ok, %Auditing{}}

      iex> create_auditing(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_auditing(attrs \\ %{}) do
    %Auditing{}
    |> Auditing.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking auditing changes.

  ## Examples

      iex> change_auditing(auditing)
      %Ecto.Changeset{source: %Auditing{}}

  """
  def change_auditing(%Auditing{} = auditing) do
    Auditing.changeset(auditing, %{})
  end

  def audit_object(object, action, user \\ nil) do
    pid_field = object.__struct__.__schema__(:primary_key) |> List.first()
    user_id = if user, do: user.user_id, else: nil

    create_auditing(%{
      relation: object.__struct__.__schema__(:source),
      relid: Map.get(object, pid_field),
      act: action,
      contents: Cforum.System.Auditing.Json.to_json(object),
      user_id: user_id
    })
  end

  def audited(action, user, fun, opts \\ []) when is_binary(action) and is_function(fun) do
    {_, val} =
      Repo.transaction(
        fn ->
          case fun.() do
            {:ok, object} ->
              {:ok, _} = audit_object(object, action, user)
              {:ok, object}

            val ->
              Repo.rollback(val)
          end
        end,
        opts
      )

    val
  end
end
