defmodule Cforum.Search.Document do
  use CforumWeb, :model

  @primary_key {:search_document_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :search_document_id}

  schema "search_documents" do
    field(:author, :string)
    field(:content, :string)
    field(:document_created, :utc_datetime)
    field(:lang, :string)
    field(:reference_id, :integer)
    field(:relevance, :float)
    field(:tags, {:array, :string})
    field(:title, :string)
    field(:url, :string)

    field(:rank, :float, virtual: true)
    field(:headline_all, :string, virtual: true)
    field(:headline_title, :string, virtual: true)
    field(:headline_author, :string, virtual: true)
    field(:headline_content, :string, virtual: true)

    belongs_to(:search_section, Cforum.Search.Section, references: :search_section_id)
    belongs_to(:forum, Cforum.Forums.Forum, references: :forum_id)
    belongs_to(:user, Cforum.Accounts.User, references: :user_id)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [
      :search_section_id,
      :forum_id,
      :user_id,
      :reference_id,
      :url,
      :relevance,
      :author,
      :title,
      :content,
      :document_created,
      :lang,
      :tags
    ])
    |> validate_required([:search_section_id, :url, :relevance, :author, :title, :content, :lang, :tags])
    |> unique_constraint(:reference_id, name: :search_documents_reference_id_key)
    |> unique_constraint(:url, name: :search_documents_url_key)
  end
end
