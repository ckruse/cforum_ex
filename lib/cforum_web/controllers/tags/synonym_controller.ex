defmodule CforumWeb.Tags.SynonymController do
  use CforumWeb, :controller
  use Cforum.Constants

  alias Cforum.Abilities

  alias Cforum.Messages.Tags
  alias Cforum.Messages.TagSynonym

  def new(conn, %{"tag_id" => _tag_id}) do
    changeset = Tags.change_tag_synonym(conn.assigns.tag, %TagSynonym{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag_id" => _tag_id, "tag_synonym" => synonym_params}) do
    case Tags.create_tag_synonym(conn.assigns.current_user, conn.assigns.tag, synonym_params) do
      {:ok, _synonym} ->
        conn
        |> put_flash(:info, gettext("Tag synonym created successfully."))
        |> redirect(to: Path.tag_path(conn, :show, conn.assigns.tag))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"tag_id" => _tag_id, "id" => _id}) do
    changeset = Tags.change_tag_synonym(conn.assigns.tag, conn.assigns.synonym)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"tag_id" => _tag_id, "id" => _id, "tag_synonym" => synonym_params}) do
    case Tags.update_tag_synonym(conn.assigns.current_user, conn.assigns.tag, conn.assigns.synonym, synonym_params) do
      {:ok, _synonym} ->
        conn
        |> put_flash(:info, gettext("Tag synonym updated successfully."))
        |> redirect(to: Path.tag_path(conn, :show, conn.assigns.tag))

      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"tag_id" => _tag_id, "id" => _id}) do
    Tags.delete_tag_synonym(conn.assigns.current_user, conn.assigns.synonym)

    conn
    |> put_flash(:info, gettext("Tag synonym deleted successfully."))
    |> redirect(to: Path.tag_path(conn, :show, conn.assigns.tag))
  end

  def load_resource(conn) do
    tag = Tags.get_tag_by_slug!(conn.params["tag_id"])

    synonym =
      if conn.params["id"],
        do: Tags.get_tag_synonym!(tag, conn.params["id"]),
        else: nil

    conn
    |> Plug.Conn.assign(:tag, tag)
    |> Plug.Conn.assign(:synonym, synonym)
  end

  def allowed?(conn, _, _) do
    Abilities.access_forum?(conn) &&
      (Abilities.badge?(conn, @badge_create_tag_synonym) || Abilities.badge?(conn, @badge_moderator_tools) ||
         Abilities.admin?(conn))
  end
end
