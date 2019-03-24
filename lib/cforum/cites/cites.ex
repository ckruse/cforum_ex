defmodule Cforum.Cites do
  @moduledoc """
  The Cites context.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Cites.Cite
  alias Cforum.Cites.Vote
  alias Cforum.System

  @doc """
  Returns the list of cites.

  ## Examples

      iex> list_cites()
      [%Cite{}, ...]

  """
  def list_cites(archived, query_params \\ [order: nil, limit: nil, search: nil]) do
    from(
      cite in Cite,
      where: cite.archived == ^archived,
      preload: [:votes, :user, :creator_user, message: [:forum, :thread]]
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :cite_id)
    |> Repo.all()
  end

  @doc """
  Counts all archived (with `archived=true`) or unarchived (with
  `archived=false`) cites.

  ## Examples

      iex> count_cites()
      0
  """
  @spec count_cites(boolean()) :: integer()
  def count_cites(archived \\ true) do
    from(
      cite in Cite,
      select: count("*"),
      where: cite.archived == ^archived
    )
    |> Repo.one!()
  end

  @doc """
  Counts votable cites the user has not voted for, yet.

  ## Examples

      iex> count_undecided_cites(%User{})
      0
  """
  @spec count_undecided_cites(%Cforum.Accounts.User{}) :: integer()
  def count_undecided_cites(user) do
    from(
      cite in Cite,
      where:
        cite.archived == false and
          fragment(
            "NOT EXISTS (SELECT cite_id FROM cites_votes WHERE cite_id = ? AND user_id = ?)",
            cite.cite_id,
            ^user.user_id
          ),
      select: count("*")
    )
    |> Repo.one!()
  end

  @doc """
  Lists the cites which are ready to be archived.

  ## Example

      iex> list_cites_to_archive(2)
      [%Cite{}]
  """
  @spec list_cites_to_archive(integer()) :: [%Cite{}]
  def list_cites_to_archive(min_age) do
    from(
      cite in Cite,
      where: cite.archived == false and datetime_add(cite.created_at, ^min_age, "week") < ^NaiveDateTime.utc_now(),
      preload: [:votes]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single cite.

  Raises `Ecto.NoResultsError` if the Cite does not exist.

  ## Examples

      iex> get_cite!(123)
      %Cite{}

      iex> get_cite!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cite!(id) do
    Cite
    |> Repo.get!(id)
    |> Repo.preload([:votes, :user, :creator_user, message: [:forum, :thread]])
  end

  @doc """
  Creates a cite.

  ## Examples

      iex> create_cite(%{field: value})
      {:ok, %Cite{}}

      iex> create_cite(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cite(current_user, attrs) do
    System.audited("create", current_user, fn ->
      %Cite{}
      |> Cite.changeset(attrs, current_user)
      |> Repo.insert()
    end)
    |> maybe_index_cite()
  end

  @doc """
  Updates a cite.

  ## Examples

      iex> update_cite(cite, %{field: new_value})
      {:ok, %Cite{}}

      iex> update_cite(cite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cite(current_user, %Cite{} = cite, attrs) do
    System.audited("update", current_user, fn ->
      cite
      |> Cite.changeset(attrs)
      |> Repo.update()
    end)
    |> maybe_index_cite()
  end

  @doc """
  Archives a cite (sets `archived` to `true`)

  ## Examples

      iex> archive_cite(%Cite{})
      {:ok, %Cite{}}
  """
  @spec archive_cite(%Cite{}) :: {:ok, %Cite{}} | {:error, any()}
  def archive_cite(%Cite{} = cite) do
    System.audited("archive", nil, fn ->
      cite
      |> Ecto.Changeset.change(%{archived: true})
      |> Repo.update()
    end)
    |> maybe_index_cite()
  end

  defp maybe_index_cite({:ok, cite}) do
    Cforum.Cites.CiteIndexerJob.index_cite(cite)
    {:ok, cite}
  end

  defp maybe_index_cite(val), do: val

  @doc """
  Deletes a Cite.

  ## Examples

      iex> delete_cite(cite)
      {:ok, %Cite{}}

      iex> delete_cite(cite)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_cite(%Cforum.Accounts.User{} | nil, %Cite{}) :: {:ok, %Cite{}} | {:error, any()}
  def delete_cite(current_user, %Cite{} = cite) do
    System.audited("destroy", current_user, fn ->
      Repo.delete(cite)
    end)
    |> maybe_unindex_cite()
  end

  def archive_delete_cite(%Cite{} = cite) do
    System.audited("archive-del", nil, fn -> Repo.delete(cite) end)
    |> maybe_unindex_cite()
  end

  defp maybe_unindex_cite({:ok, cite}) do
    Cforum.Cites.CiteIndexerJob.unindex_cite(cite)
    {:ok, cite}
  end

  defp maybe_unindex_cite(val), do: val

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cite changes.

  ## Examples

      iex> change_cite(cite)
      %Ecto.Changeset{source: %Cite{}}

  """
  def change_cite(%Cite{} = cite, attrs \\ %{}) do
    Cite.changeset(cite, attrs)
  end

  @doc """
  Calculates the score of a cite (as in upvotes - downvotes)

  ## Examples

      iex> score(%Cite{})
      1
  """
  @spec score(%Cite{}) :: integer()
  def score(cite) do
    Enum.reduce(cite.votes, 0, fn
      %Vote{vote_type: 0}, acc -> acc - 1
      %Vote{vote_type: 1}, acc -> acc + 1
    end)
  end

  @doc """
  Counts the number of votes for a cite

  ## Examples

      iex> no_votes(%Cite{})
      0
  """
  @spec no_votes(%Cite{}) :: non_neg_integer()
  def no_votes(cite), do: length(cite.votes)

  @doc """
  Generates a score string for a cite

  ## Examples

      iex> score_str(%Cite{})
      "+1"
  """
  @spec score_str(%Cite{}) :: String.t()
  def score_str(cite), do: Cforum.Helpers.score_str(no_votes(cite), score(cite))

  @doc """
  Return true if the `user` has voted for `cite`

  ## Examples

    iex> voted?(%Cite{}, %User{})
    true
  """
  @spec voted?(%Cite{}, %Cforum.Accounts.User{}) :: boolean()
  def voted?(cite, user) when not is_nil(user),
    do: Enum.find(cite.votes, fn vote -> vote.user_id == user.user_id end) != nil

  @doc """
  Return true if the `user` has voted for `cite` with vote `type` `:up` or `:down`

  ## Examples

    iex> voted?(%Cite{}, %User{}, :up)
    true
  """
  @spec voted?(%Cite{}, %Cforum.Accounts.User{}, :up | :down | String.t()) :: boolean()
  def voted?(cite, user, type) when not is_nil(user) and type in [:up, :down],
    do: Enum.find(cite.votes, fn vote -> vote.user_id == user.user_id && vote.vote_type == Vote.vtype(type) end) != nil

  def voted?(cite, user, "up"), do: voted?(cite, user, :up)
  def voted?(cite, user, "down"), do: voted?(cite, user, :down)
  def voted?(_, _, _), do: false

  @doc """
  Return true if the `user` has downvoted `cite`

  ## Examples

    iex> downvoted?(%Cite{}, %User{})
    false
  """
  @spec downvoted?(%Cite{}, %Cforum.Accounts.User{} | nil) :: boolean()
  def downvoted?(cite, user) when not is_nil(user), do: voted?(cite, user, :down)
  def downvoted?(_, _), do: false

  @doc """
  Return true if the `user` has upvoted `cite`

  ## Examples

    iex> upvoted?(%Cite{}, %User{})
    true
  """
  @spec upvoted?(%Cite{}, %Cforum.Accounts.User{} | nil) :: boolean()
  def upvoted?(cite, user) when not is_nil(user), do: voted?(cite, user, :up)
  def upvoted?(_, _), do: false

  @doc """
  Take back a vote of a `user` for a `cite`

  ## Examples

    iex> take_back_vote(%Cite{}, %User{})
    %Vote{}
  """
  @spec take_back_vote(%Cite{}, %Cforum.Accounts.User{}) :: nil | %Cite{}
  def take_back_vote(cite, user) do
    v = Enum.find(cite.votes, fn vote -> vote.user_id == user.user_id end)
    if v, do: Repo.delete(v)

    v
  end

  @doc """
  Vote as `user` for a `cite` with the type `type`

  ## Examples

    iex> vote(%Cite{}, %User{}, "up")
    {:ok, %Vote{}}
  """
  @spec vote(%Cite{}, %Cforum.Accounts.User{}, :up | :down | String.t()) :: {:ok, %Cite{}} | {:error, %Ecto.Changeset{}}
  def vote(cite, user, type) when type in [:up, :down, "up", "down"] do
    %Vote{}
    |> Vote.changeset(%{cite_id: cite.cite_id, user_id: user.user_id, vote_type: Vote.vtype(type)})
    |> Repo.insert()
  end

  @doc """
  Creates a `%Cite{}` struct from the map `object`
  """
  @spec cite_from_json(map()) :: %Cite{}
  def cite_from_json(object) do
    Cforum.Cites.change_cite(%Cforum.Cites.Cite{}, object)
    |> Ecto.Changeset.apply_changes()
    |> Repo.preload([:user, :creator_user])
  end

  def cites_stats(months, :months) do
    from(cite in Cforum.Cites.Cite,
      select: {fragment("date_trunc('month', ?) AS created_at", cite.created_at), count("*")},
      where: cite.created_at >= ago(^months, "month"),
      group_by: fragment("1"),
      order_by: fragment("1")
    )
    |> Repo.all()
    |> Enum.map(fn {date, cnt} ->
      %{cnt: cnt, date: date}
    end)
  end
end
