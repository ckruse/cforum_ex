defmodule CforumWeb.TagController do
  use CforumWeb, :controller

  alias Cforum.Abilities

  alias Cforum.Threads.Thread

  alias Cforum.Messages.Message
  alias Cforum.MessagesTags

  alias Cforum.Tags.Tag
  alias Cforum.Tags

  alias CforumWeb.Paginator

  def index(conn, _params) do
    tags = Tags.list_tags()

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
    tag = Tags.get_tag_by_slug!(id)

    count = MessagesTags.count_messages_for_tag(conn.assigns[:visible_forums], tag)
    paging = Paginator.paginate(count, page: params["p"])
    entries = MessagesTags.list_messages_for_tag(conn.assigns[:visible_forums], tag, limit: paging.params)

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
    case Tags.create_tag(conn.assigns.current_user, tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, gettext("Tag created successfully."))
        |> redirect(to: Path.tag_path(conn, :show, tag))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    tag = Tags.get_tag_by_slug!(id)
    changeset = Tags.change_tag(tag)
    render(conn, "edit.html", tag: tag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tag" => tag_params}) do
    tag = Tags.get_tag_by_slug!(id)

    case Tags.update_tag(conn.assigns.current_user, tag, tag_params) do
      {:ok, tag} ->
        conn
        |> put_flash(:info, gettext("Tag updated successfully."))
        |> redirect(to: Path.tag_path(conn, :show, tag))

      {:error, changeset} ->
        render(conn, "edit.html", tag: tag, changeset: changeset)
    end
  end

  def edit_merge(conn, %{"tag_id" => id}) do
    tag = Tags.get_tag_by_slug!(id)
    tags = Tags.list_tags()

    render(conn, "edit_merge.html", tag: tag, tags: tags)
  end

  def merge(conn, %{"tag_id" => id, "existing_tag_id" => existing_tag_id}) do
    old_tag = Tags.get_tag_by_slug!(id)
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
        |> redirect(to: Path.tag_path(conn, :show, new_tag))

      {:error, :same_tag} ->
        tags = Tags.list_tags()

        conn
        |> put_flash(:error, gettext("You can't merge a tag with itself!"))
        |> render("edit_merge.html", tag: old_tag, tags: tags)

      {:error, _} ->
        tags = Tags.list_tags()
        render(conn, "edit_merge.html", tag: old_tag, tags: tags)
    end
  end

  def delete(conn, %{"id" => id}) do
    tag = Tags.get_tag_by_slug!(id)
    Tags.delete_tag(conn.assigns.current_user, tag)

    conn
    |> put_flash(:info, gettext("Tag deleted successfully."))
    |> redirect(to: Path.tag_path(conn, :index))
  end

  @spec allowed?(Plug.Conn.t(), atom(), any()) :: boolean()
  def allowed?(_conn, action, _) when action in [:index, :show],
    do: true

  def allowed?(conn, action, _) when action in [:new, :create] do
    Abilities.access_forum?(conn) &&
      (Abilities.admin?(conn) || Abilities.badge?(conn, "create_tag") || Abilities.badge?(conn, "moderator_tools"))
  end

  def allowed?(conn, action, _) when action in [:edit, :update, :edit_merge, :merge],
    do: Abilities.access_forum?(conn) && (Abilities.admin?(conn) || Abilities.badge?(conn, "moderator_tools"))

  def allowed?(conn, :delete, _),
    do: Abilities.access_forum?(conn) && (Abilities.admin?(conn) || Abilities.badge?(conn, "moderator_tools"))

  def allowed?(_, _, _),
    do: false
end
