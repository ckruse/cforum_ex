defmodule Cforum.SystemTest do
  use Cforum.DataCase

  alias Cforum.System

  describe "redirections" do
    alias Cforum.System.Redirection

    test "list_redirections/0 returns all redirections" do
      redirection = insert(:redirection)
      assert System.list_redirections() == [redirection]
    end

    test "get_redirection!/1 returns the redirection with given id" do
      redirection = insert(:redirection)
      assert System.get_redirection!(redirection.redirection_id) == redirection
    end

    test "create_redirection/1 with valid data creates a redirection" do
      params = params_for(:redirection, comment: "For the rebellion")
      assert {:ok, %Redirection{} = redirection} = System.create_redirection(params)
      assert redirection.destination == params[:destination]
      assert redirection.http_status == params[:http_status]
      assert redirection.path == params[:path]
      assert redirection.comment == "For the rebellion"
    end

    test "create_redirection/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = System.create_redirection(%{})
    end

    test "update_redirection/2 with valid data updates the redirection" do
      redirection = insert(:redirection)

      assert {:ok, redirection} =
               System.update_redirection(redirection, %{
                 path: "/foo/bar",
                 destination: "/bar/foo",
                 http_status: 302,
                 comment: "May the force be with you"
               })

      assert %Redirection{} = redirection
      assert redirection.comment == "May the force be with you"
      assert redirection.destination == "/bar/foo"
      assert redirection.http_status == 302
      assert redirection.path == "/foo/bar"
    end

    test "update_redirection/2 with invalid data returns error changeset" do
      redirection = insert(:redirection)
      assert {:error, %Ecto.Changeset{}} = System.update_redirection(redirection, %{path: nil})
      assert redirection == System.get_redirection!(redirection.redirection_id)
    end

    test "delete_redirection/1 deletes the redirection" do
      redirection = insert(:redirection)
      assert {:ok, %Redirection{}} = System.delete_redirection(redirection)
      assert_raise Ecto.NoResultsError, fn -> System.get_redirection!(redirection.redirection_id) end
    end

    test "change_redirection/1 returns a redirection changeset" do
      redirection = insert(:redirection)
      assert %Ecto.Changeset{} = System.change_redirection(redirection)
    end
  end

  describe "auditing" do
    alias Cforum.System.Auditing

    @valid_attrs %{act: "some act", contents: %{}, relation: "some relation", relid: 42}
    @invalid_attrs %{act: nil, contents: nil, relation: nil, relid: nil}

    def auditing_fixture(attrs \\ %{}) do
      {:ok, auditing} =
        attrs
        |> Enum.into(@valid_attrs)
        |> System.create_auditing()

      auditing
    end

    test "list_auditing/0 returns all auditing" do
      auditing = auditing_fixture()
      assert System.list_auditing() == [auditing]
    end

    test "get_auditing!/1 returns the auditing with given id" do
      auditing = auditing_fixture()
      assert System.get_auditing!(auditing.auditing_id) == auditing
    end

    test "create_auditing/1 with valid data creates a auditing" do
      assert {:ok, %Auditing{} = auditing} = System.create_auditing(@valid_attrs)
      assert auditing.act == "some act"
      assert auditing.contents == %{}
      assert auditing.relation == "some relation"
      assert auditing.relid == 42
    end

    test "create_auditing/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = System.create_auditing(@invalid_attrs)
    end

    test "change_auditing/1 returns a auditing changeset" do
      auditing = auditing_fixture()
      assert %Ecto.Changeset{} = System.change_auditing(auditing)
    end
  end
end
