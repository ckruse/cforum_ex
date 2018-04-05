defmodule Cforum.Cites do
  @moduledoc """
  The Cites context.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Cites.Cite
  alias Cforum.Cites.Vote

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
      preload: [:votes, :user, :creator_user, [message: :forum]]
    )
    |> Cforum.PagingApi.set_limit(query_params[:limit])
    |> Cforum.OrderApi.set_ordering(query_params[:order], desc: :cite_id)
    |> Repo.all()
  end

  def count_cites(archived \\ true) do
    from(
      cite in Cite,
      select: count("*"),
      where: cite.archived == ^archived
    )
    |> Repo.one()
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
    |> Repo.preload([:votes, :user, :creator_user, message: :forum])
  end

  @doc """
  Creates a cite.

  ## Examples

      iex> create_cite(%{field: value})
      {:ok, %Cite{}}

      iex> create_cite(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cite(attrs, current_user \\ nil) do
    %Cite{}
    |> Cite.changeset(attrs, current_user)
    |> Repo.insert()
  end

  @doc """
  Updates a cite.

  ## Examples

      iex> update_cite(cite, %{field: new_value})
      {:ok, %Cite{}}

      iex> update_cite(cite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cite(%Cite{} = cite, attrs) do
    cite
    |> Cite.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Cite.

  ## Examples

      iex> delete_cite(cite)
      {:ok, %Cite{}}

      iex> delete_cite(cite)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cite(%Cite{} = cite) do
    Repo.delete(cite)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cite changes.

  ## Examples

      iex> change_cite(cite)
      %Ecto.Changeset{source: %Cite{}}

  """
  def change_cite(%Cite{} = cite) do
    Cite.changeset(cite, %{})
  end

  def score(cite) do
    Enum.reduce(cite.votes, 0, fn
      %Vote{vote_type: 0}, acc -> acc - 1
      %Vote{vote_type: 1}, acc -> acc + 1
    end)
  end

  def no_votes(cite), do: length(cite.votes)
  def score_str(cite), do: Cforum.Helpers.score_str(no_votes(cite), score(cite))

  def voted?(cite, user) when not is_nil(user),
    do: Enum.find(cite.votes, fn vote -> vote.user_id == user.user_id end) != nil

  def voted?(cite, user, type) when not is_nil(user) and type in ["up", "down"],
    do: Enum.find(cite.votes, fn vote -> vote.user_id == user.user_id && vote.vote_type == Vote.vtype(type) end) != nil

  def voted?(_, _, _), do: false

  def downvoted?(cite, user) when not is_nil(user), do: voted?(cite, user, "down")
  def downvoted?(_, _), do: false
  def upvoted?(cite, user) when not is_nil(user), do: voted?(cite, user, "up")
  def upvoted?(_, _), do: false

  def take_back_vote(cite, user) do
    v = Enum.find(cite.votes, fn vote -> vote.user_id == user.user_id end)
    if v, do: Repo.delete(v)

    v
  end

  def vote(cite, user, type) when type in ["up", "down"] do
    %Vote{}
    |> Vote.changeset(%{cite_id: cite.cite_id, user_id: user.user_id, vote_type: Vote.vtype(type)})
    |> Repo.insert()
  end
end
