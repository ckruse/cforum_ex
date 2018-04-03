defmodule Cforum.CitesTest do
  use Cforum.DataCase

  alias Cforum.Cites

  describe "cites" do
    alias Cforum.Cites.Cite

    @valid_attrs %{
      archived: true,
      author: "some author",
      cite: "some cite",
      cite_date: ~N[2010-04-17 14:00:00.000000],
      creator: "some creator",
      old_id: 42,
      url: "some url"
    }
    @update_attrs %{
      archived: false,
      author: "some updated author",
      cite: "some updated cite",
      cite_date: ~N[2011-05-18 15:01:01.000000],
      creator: "some updated creator",
      old_id: 43,
      url: "some updated url"
    }
    @invalid_attrs %{archived: nil, author: nil, cite: nil, cite_date: nil, creator: nil, old_id: nil, url: nil}

    def cite_fixture(attrs \\ %{}) do
      {:ok, cite} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Cites.create_cite()

      cite
    end

    test "list_cites/0 returns all cites" do
      cite = cite_fixture()
      assert Cites.list_cites() == [cite]
    end

    test "get_cite!/1 returns the cite with given id" do
      cite = cite_fixture()
      assert Cites.get_cite!(cite.id) == cite
    end

    test "create_cite/1 with valid data creates a cite" do
      assert {:ok, %Cite{} = cite} = Cites.create_cite(@valid_attrs)
      assert cite.archived == true
      assert cite.author == "some author"
      assert cite.cite == "some cite"
      assert cite.cite_date == ~N[2010-04-17 14:00:00.000000]
      assert cite.creator == "some creator"
      assert cite.old_id == 42
      assert cite.url == "some url"
    end

    test "create_cite/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Cites.create_cite(@invalid_attrs)
    end

    test "update_cite/2 with valid data updates the cite" do
      cite = cite_fixture()
      assert {:ok, cite} = Cites.update_cite(cite, @update_attrs)
      assert %Cite{} = cite
      assert cite.archived == false
      assert cite.author == "some updated author"
      assert cite.cite == "some updated cite"
      assert cite.cite_date == ~N[2011-05-18 15:01:01.000000]
      assert cite.creator == "some updated creator"
      assert cite.old_id == 43
      assert cite.url == "some updated url"
    end

    test "update_cite/2 with invalid data returns error changeset" do
      cite = cite_fixture()
      assert {:error, %Ecto.Changeset{}} = Cites.update_cite(cite, @invalid_attrs)
      assert cite == Cites.get_cite!(cite.id)
    end

    test "delete_cite/1 deletes the cite" do
      cite = cite_fixture()
      assert {:ok, %Cite{}} = Cites.delete_cite(cite)
      assert_raise Ecto.NoResultsError, fn -> Cites.get_cite!(cite.id) end
    end

    test "change_cite/1 returns a cite changeset" do
      cite = cite_fixture()
      assert %Ecto.Changeset{} = Cites.change_cite(cite)
    end
  end
end
