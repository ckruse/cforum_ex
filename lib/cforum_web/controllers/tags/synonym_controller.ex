defmodule CforumWeb.Tags.SynonymController do
  use CforumWeb, :controller

  alias Cforum.Forums.{Tags, TagSynonym}
  alias Cforum.Accounts.Badge

  def new(conn, %{"tag_id" => tag_id}) do
    tag = Tags.get_tag_by_slug!(conn.assigns[:current_forum], tag_id)
    changeset = Tags.change_tag_synonym(tag, %TagSynonym{})
    render(conn, "new.html", tag: tag, changeset: changeset)
  end

  def create(conn, %{"tag_id" => tag_id, "tag_synonym" => synonym_params}) do
    tag = Tags.get_tag_by_slug!(conn.assigns[:current_forum], tag_id)

    case Tags.create_tag_synonym(conn.assigns.current_user, tag, synonym_params) do
      {:ok, _synonym} ->
        conn
        |> put_flash(:info, gettext("Tag synonym created successfully."))
        |> redirect(to: tag_path(conn, :show, conn.assigns[:current_forum], tag))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, tag: tag)
    end
  end

  def edit(conn, %{"tag_id" => tag_id, "id" => id}) do
    tag = Tags.get_tag_by_slug!(conn.assigns[:current_forum], tag_id)
    synonym = Tags.get_tag_synonym!(tag, id)
    changeset = Tags.change_tag_synonym(tag, synonym)

    render(conn, "edit.html", tag: tag, synonym: synonym, changeset: changeset)
  end

  def update(conn, %{"tag_id" => tag_id, "id" => id, "tag_synonym" => synonym_params}) do
    tag = Tags.get_tag_by_slug!(conn.assigns[:current_forum], tag_id)
    synonym = Tags.get_tag_synonym!(tag, id)

    case Tags.update_tag_synonym(conn.assigns.current_user, tag, synonym, synonym_params) do
      {:ok, _synonym} ->
        conn
        |> put_flash(:info, gettext("Tag synonym updated successfully."))
        |> redirect(to: tag_path(conn, :show, conn.assigns[:current_forum], tag))

      {:error, changeset} ->
        render(conn, "edit.html", tag: tag, synonym: synonym, changeset: changeset)
    end
  end

  def delete(conn, %{"tag_id" => tag_id, "id" => id}) do
    tag = Tags.get_tag_by_slug!(conn.assigns[:current_forum], tag_id)
    synonym = Tags.get_tag_synonym!(tag, id)

    Tags.delete_tag_synonym(conn.assigns.current_user, synonym)

    conn
    |> put_flash(:info, gettext("Tag synonym deleted successfully."))
    |> redirect(to: tag_path(conn, :show, conn.assigns[:current_forum], tag))
  end

  def allowed?(conn, _, _) do
    access_forum?(conn) &&
      (badge?(conn, Badge.create_tag_synonym()) || badge?(conn, Badge.moderator_tools()) || admin?(conn))
  end
end
