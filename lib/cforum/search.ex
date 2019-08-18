defmodule Cforum.Search do
  @moduledoc """
  The Search context.
  """

  import Ecto.Query, warn: false
  alias Cforum.Repo

  alias Cforum.Search.Section

  @doc """
  Returns the list of search_sections.

  ## Examples

      iex> list_search_sections()
      [%Section{}, ...]

  """
  def list_search_sections do
    from(Section, order_by: [asc: :position], preload: [:forum])
    |> Repo.all()
  end

  def list_visible_search_sections(visible_forums, type \\ nil) do
    visible_forum_ids = Enum.map(visible_forums, & &1.forum_id)

    from(s in Section,
      order_by: [asc: :position],
      preload: [:forum],
      where: is_nil(s.forum_id) or s.forum_id in ^visible_forum_ids
    )
    |> maybe_set_type(type)
    |> Repo.all()
  end

  defp maybe_set_type(q, nil), do: q
  defp maybe_set_type(q, type), do: from(s in q, where: s.section_type == ^type)

  @doc """
  Gets a single section.

  Raises `Ecto.NoResultsError` if the Section does not exist.

  ## Examples

      iex> get_section!(123)
      %Section{}

      iex> get_section!(456)
      ** (Ecto.NoResultsError)

  """
  def get_section!(id), do: Repo.get!(Section, id)

  @doc """
  Gets a single section by the `forum_id`.

  Returns `nil` if the Section does not exist.

  ## Examples

      iex> get_section_by_forum_id(123)
      %Section{}

      iex> get_section_by_forum_id(456)
      nil

  """
  def get_section_by_forum_id(id), do: Repo.get_by(Section, forum_id: id)

  def get_section_by_section_type(type), do: Repo.get_by(Section, section_type: type)

  @doc """
  Creates a section.

  ## Examples

      iex> create_section(%{field: value})
      {:ok, %Section{}}

      iex> create_section(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_section(attrs \\ %{}) do
    %Section{}
    |> Section.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a section.

  ## Examples

      iex> update_section(section, %{field: new_value})
      {:ok, %Section{}}

      iex> update_section(section, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_section(%Section{} = section, attrs) do
    section
    |> Section.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Section.

  ## Examples

      iex> delete_section(section)
      {:ok, %Section{}}

      iex> delete_section(section)
      {:error, %Ecto.Changeset{}}

  """
  def delete_section(%Section{} = section) do
    Repo.delete(section)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking section changes.

  ## Examples

      iex> change_section(section)
      %Ecto.Changeset{source: %Section{}}

  """
  def change_section(%Section{} = section) do
    Section.changeset(section, %{})
  end

  alias Cforum.Search.Document

  @doc """
  Gets a single document.

  Raises `Ecto.NoResultsError` if the Document does not exist.

  ## Examples

      iex> get_document!(123)
      %Document{}

      iex> get_document!(456)
      ** (Ecto.NoResultsError)

  """
  def get_document!(id), do: Repo.get!(Document, id)

  @spec get_document_by_reference_id(non_neg_integer(), :forum | :cites) :: %Document{} | nil
  def get_document_by_reference_id(id, type \\ :forum) do
    from(doc in Document,
      inner_join: section in assoc(doc, :search_section),
      where: doc.reference_id == ^id and section.section_type == ^Atom.to_string(type)
    )
    |> Repo.one()
  end

  @doc """
  Creates a document.

  ## Examples

      iex> create_document(%{field: value})
      {:ok, %Document{}}

      iex> create_document(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_document(attrs \\ %{}) do
    %Document{}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a document.

  ## Examples

      iex> update_document(document, %{field: new_value})
      {:ok, %Document{}}

      iex> update_document(document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Document.

  ## Examples

      iex> delete_document(document)
      {:ok, %Document{}}

      iex> delete_document(document)
      {:error, %Ecto.Changeset{}}

  """
  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document changes.

  ## Examples

      iex> change_document(document)
      %Ecto.Changeset{source: %Document{}}

  """
  def change_document(%Document{} = document) do
    Document.changeset(document, %{})
  end

  def search_changeset(visible_sections, attrs \\ %{}) do
    default_sections =
      visible_sections
      |> Enum.filter(&(&1.active_by_default == true))
      |> Enum.map(& &1.search_section_id)

    types = %{
      term: :string,
      sections: {:array, :integer},
      start_date: :date,
      end_date: :date,
      order: :string
    }

    default_data = %{
      start_date: Timex.shift(Timex.today(), years: -2),
      end_date: Timex.today(),
      order: "relevance",
      sections: default_sections
    }

    {default_data, types}
    |> Ecto.Changeset.cast(attrs, Map.keys(types))
    |> Ecto.Changeset.validate_required([:term])
    |> Ecto.Changeset.validate_inclusion(:order, ["relevance", "date"])
    |> Ecto.Changeset.validate_inclusion(:sections, Enum.map(visible_sections, & &1.search_section_id))
  end
end
