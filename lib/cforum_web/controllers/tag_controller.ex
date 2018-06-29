defmodule CforumWeb.TagController do
  use CforumWeb, :controller

  alias Cforum.Forums.{Tags, Messages, Thread, Message, Tag}

  def index(conn, _params) do
    tags = Tags.list_tags(conn.assigns[:current_forum], conn.assigns[:visible_forums])

    {min_cnt, max_cnt} =
      Enum.reduce(tags, {-1, 0}, fn
        tag, {-1, max_cnt} ->
          {tag.num_messages, max(max_cnt, tag.num_messages)}

        tag, {min_cnt, max_cnt} ->
          {min(min_cnt, tag.num_messages), max(max_cnt, tag.num_messages)}
      end)

    render(conn, "index.html", tags: tags, min_cnt: min_cnt, max_cnt: max_cnt)
  end

  def show(conn, %{"id" => id} = params) do
    tag = Tags.get_tag_by_slug!(conn.assigns[:current_forum], id)

    count = Messages.count_messages_for_tag(conn.assigns[:current_forum], tag)
    paging = paginate(count, page: params["p"])
    entries = Messages.list_messages_for_tag(conn.assigns[:current_forum], tag, limit: paging.params)

    messages =
      Enum.map(entries, fn msg ->
        thread = %Thread{msg.thread | message: msg}
        %Message{msg | thread: thread}
      end)

    render(conn, "show.html", tag: tag, messages: messages, page: paging)
  end

  def new(conn, _params) do
    changeset = Tags.change_tag(%Tag{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tag" => tag_params}) do
    case Tags.create_tag(conn.assigns.current_user, conn.assigns[:current_forum], tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, gettext("Tag created successfully."))
        |> redirect(to: tag_path(conn, :show, conn.assigns[:current_forum], tag))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    tag = Tags.get_tag_by_slug!(conn.assigns[:current_forum], id)
    changeset = Tags.change_tag(tag)
    render(conn, "edit.html", tag: tag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag" => tag_params}) do
    tag = Tags.get_tag_by_slug!(conn.assigns[:current_forum], id)

    case Tags.update_tag(conn.assigns.current_user, tag, tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, gettext("Tag updated successfully."))
        |> redirect(to: tag_path(conn, :show, conn.assigns[:current_forum], tag))

      {:error, changeset} ->
        render(conn, "edit.html", tag: tag, changeset: changeset)
    end
  end

  def edit_merge(conn, %{"tag_id" => id}) do
    tag = Tags.get_tag_by_slug!(conn.assigns[:current_forum], id)
    tags = Tags.list_tags(conn.assigns[:current_forum], conn.assigns[:visible_forums])

    render(conn, "edit_merge.html", tag: tag, tags: tags)
  end

  def merge(conn, %{"tag_id" => id, "existing_tag_id" => existing_tag_id}) do
    old_tag = Tags.get_tag_by_slug!(conn.assigns[:current_forum], id)
    new_tag = Tags.get_tag!(existing_tag_id)

    case Tags.merge_tag(conn.assigns.current_user, old_tag, new_tag) do
      {:ok, _tag} ->
        conn
        |> put_flash(
          :info,
          gettext(
            "Tag %{old_tag} got successfully merged to tag %{new_tag}",
            old_tag: old_tag.tag_name,
            new_tag: new_tag.tag_name
          )
        )
        |> redirect(to: tag_path(conn, :show, conn.assigns[:current_forum], new_tag))

      {:error, _} ->
        tags = Tags.list_tags(conn.assigns[:current_forum], conn.assigns[:visible_forums])
        render(conn, "edit_merge.html", tag: old_tag, tags: tags)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag = Tags.get_tag_by_slug!(conn.assigns[:current_forum], id)
    Tags.delete_tag(conn.assigns.current_user, tag)

    conn
    |> put_flash(:info, gettext("Tag deleted successfully."))
    |> redirect(to: tag_path(conn, :index, conn.assigns[:current_forum]))
  end
end
