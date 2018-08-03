defmodule Cforum.SearchTest do
  use Cforum.DataCase

  alias Cforum.Search

  describe "search_sections" do
    alias Cforum.Search.Section

    @valid_attrs %{active_by_default: true, name: "some name", position: 42}
    @update_attrs %{active_by_default: false, name: "some updated name", position: 43}
    @invalid_attrs %{active_by_default: nil, name: nil, position: nil}

    def section_fixture(attrs \\ %{}) do
      {:ok, section} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Search.create_section()

      section
    end

    test "list_search_sections/0 returns all search_sections" do
      section = section_fixture()
      assert Search.list_search_sections() == [%Section{section | forum: nil}]
    end

    test "get_section!/1 returns the section with given id" do
      section = section_fixture()
      assert Search.get_section!(section.search_section_id) == section
    end

    test "create_section/1 with valid data creates a section" do
      assert {:ok, %Section{} = section} = Search.create_section(@valid_attrs)
      assert section.active_by_default == true
      assert section.name == "some name"
      assert section.position == 42
    end

    test "create_section/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Search.create_section(@invalid_attrs)
    end

    test "update_section/2 with valid data updates the section" do
      section = section_fixture()
      assert {:ok, section} = Search.update_section(section, @update_attrs)
      assert %Section{} = section
      assert section.active_by_default == false
      assert section.name == "some updated name"
      assert section.position == 43
    end

    test "update_section/2 with invalid data returns error changeset" do
      section = section_fixture()
      assert {:error, %Ecto.Changeset{}} = Search.update_section(section, @invalid_attrs)
      assert section == Search.get_section!(section.search_section_id)
    end

    test "delete_section/1 deletes the section" do
      section = section_fixture()
      assert {:ok, %Section{}} = Search.delete_section(section)
      assert_raise Ecto.NoResultsError, fn -> Search.get_section!(section.search_section_id) end
    end

    test "change_section/1 returns a section changeset" do
      section = section_fixture()
      assert %Ecto.Changeset{} = Search.change_section(section)
    end
  end
end
