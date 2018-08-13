defmodule Cforum.SearchTest do
  use Cforum.DataCase

  alias Cforum.Search

  describe "search_sections" do
    alias Cforum.Search.Section

    test "list_search_sections/0 returns all search_sections" do
      section = insert(:search_section)
      assert Search.list_search_sections() == [%Section{section | forum: nil}]
    end

    test "get_section!/1 returns the section with given id" do
      section = insert(:search_section)
      assert Search.get_section!(section.search_section_id) == section
    end

    test "create_section/1 with valid data creates a section" do
      params = params_for(:search_section)
      assert {:ok, %Section{} = section} = Search.create_section(params)
      assert section.active_by_default == params[:active_by_default]
      assert section.name == params[:name]
      assert section.position == params[:position]
    end

    test "create_section/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Search.create_section(%{})
    end

    test "update_section/2 with valid data updates the section" do
      section = insert(:search_section)
      assert {:ok, new_section} = Search.update_section(section, %{name: "foo bar"})
      assert %Section{} = new_section
      assert new_section.active_by_default == section.active_by_default
      assert new_section.name == "foo bar"
      assert new_section.position == section.position
    end

    test "update_section/2 with invalid data returns error changeset" do
      section = insert(:search_section)
      assert {:error, %Ecto.Changeset{}} = Search.update_section(section, %{name: nil})
      assert section == Search.get_section!(section.search_section_id)
    end

    test "delete_section/1 deletes the section" do
      section = insert(:search_section)
      assert {:ok, %Section{}} = Search.delete_section(section)
      assert_raise Ecto.NoResultsError, fn -> Search.get_section!(section.search_section_id) end
    end

    test "change_section/1 returns a section changeset" do
      section = insert(:search_section)
      assert %Ecto.Changeset{} = Search.change_section(section)
    end
  end

  describe "search_document" do
    alias Cforum.Search.Document

    test "get_document!/1 returns the document with given id" do
      document = insert(:search_document)
      assert Search.get_document!(document.search_document_id) == unload_relations(document, [:search_section])
    end

    test "create_document/1 with valid data creates a document" do
      section = insert(:search_section)
      params = params_for(:search_document, search_section: section)
      assert {:ok, %Document{} = document} = Search.create_document(params)
      assert document.author == params[:author]
      assert document.content == params[:content]
      assert document.document_created == params[:document_created]
      assert document.lang == params[:lang]
      assert document.reference_id == params[:reference_id]
      assert document.relevance == params[:relevance]
      assert document.tags == params[:tags]
      assert document.title == params[:title]
      assert document.url == params[:url]
      assert document.search_section_id == params[:search_section_id]
    end

    test "create_document/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Search.create_document(%{})
    end

    test "update_document/2 with valid data updates the document" do
      document = insert(:search_document)
      assert {:ok, new_document} = Search.update_document(document, %{author: "foo"})
      assert %Document{} = new_document
      assert new_document.author == "foo"
      assert new_document.content == document.content
      assert new_document.document_created == document.document_created
      assert new_document.lang == document.lang
      assert new_document.reference_id == document.reference_id
      assert new_document.relevance == document.relevance
      assert new_document.tags == document.tags
      assert new_document.title == document.title
      assert new_document.url == document.url
    end

    test "update_document/2 with invalid data returns error changeset" do
      document = insert(:search_document)
      assert {:error, %Ecto.Changeset{}} = Search.update_document(document, %{author: nil, search_section_id: nil})
      assert unload_relations(document, [:search_section]) == Search.get_document!(document.search_document_id)
    end

    test "delete_document/1 deletes the document" do
      document = insert(:search_document)
      assert {:ok, %Document{}} = Search.delete_document(document)
      assert_raise Ecto.NoResultsError, fn -> Search.get_document!(document.search_document_id) end
    end

    test "change_document/1 returns a document changeset" do
      document = insert(:search_document)
      assert %Ecto.Changeset{} = Search.change_document(document)
    end
  end
end
