defmodule CforumWeb.Threads.AdminController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.Threads.ThreadHelpers
  alias Cforum.Messages

  alias Cforum.Abilities
  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.Views.ViewHelpers.ReturnUrl

  def sticky(conn, params) do
    Threads.mark_thread_sticky(conn.assigns.current_user, conn.assigns.thread)

    conn
    |> put_flash(:info, gettext("Thread has successfully been marked as sticky."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def unsticky(conn, params) do
    Threads.mark_thread_unsticky(conn.assigns.current_user, conn.assigns.thread)

    conn
    |> put_flash(:info, gettext("Sticky mark has successfully been removed."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def no_archive(conn, params) do
    Threads.flag_thread_no_archive(conn.assigns.current_user, conn.assigns.thread)

    conn
    |> put_flash(:info, gettext("Thread will get deleted on archiving."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def archive(conn, params) do
    Threads.flag_thread_archive(conn.assigns.current_user, conn.assigns.thread)

    conn
    |> put_flash(:info, gettext("Thread will be archived."))
    |> redirect(to: ReturnUrl.return_path(conn, params, conn.assigns.thread))
  end

  def move(conn, _params) do
    changeset = Threads.change_thread(conn.assigns.thread)
    render(conn, "move.html", changeset: changeset, message: List.first(conn.assigns.thread.messages))
  end

  def do_move(conn, %{"thread" => %{"forum_id" => forum_id}}) do
    user = conn.assigns.current_user
    thread = conn.assigns.thread
    visible_forums = conn.assigns.visible_forums

    url_generator = fn new_forum, thread, msg ->
      [Path.int_message_path(conn, thread, msg), Path.int_message_path(conn, %{thread | forum: new_forum}, msg)]
    end

    case Threads.move_thread(user, thread, forum_id, visible_forums, url_generator) do
      {:ok, thread} ->
        conn
        |> put_flash(:info, gettext("Thread has successfully been moved."))
        |> redirect(to: Path.forum_path(conn, :index, thread.forum))

      {:error, changeset} ->
        render(conn, "move.html", changeset: changeset, message: List.first(conn.assigns.thread.messages))
    end
  end

  def split(conn, _params) do
    changeset = Messages.change_message(conn.assigns.message, conn.assigns.current_user, conn.assigns.visible_forums)
    render(conn, "split.html", changeset: changeset)
  end

  def do_split(conn, %{"message" => message_params}) do
    current_user = conn.assigns[:current_user]
    vis_forums = conn.assigns.visible_forums
    thread = conn.assigns.thread
    message = conn.assigns.message
    opts = [create_tags: Abilities.may?(conn, "tag", :new)]

    url_generator = fn thread, new_thread, msg ->
      [Path.int_message_path(conn, thread, msg), Path.int_message_path(conn, new_thread, msg)]
    end

    case Threads.split_thread(current_user, thread, message, message_params, vis_forums, url_generator, opts) do
      {:ok, thread, message} ->
        conn
        |> put_flash(:info, gettext("Thread was successfully split."))
        |> redirect(to: Path.message_path(conn, :show, thread, message))

      {:error, changeset} ->
        render(conn, "split.html", changeset: changeset, message: message)

      nil ->
        raise "hu?"
    end
  end

  def load_resource(conn) do
    thread =
      conn.assigns.current_forum
      |> Threads.get_thread_by_slug!(conn.assigns.visible_forums, ThreadHelpers.slug_from_params(conn.params))
      |> Threads.build_message_tree("ascending")

    message =
      if Helpers.present?(conn.params["mid"]),
        do: Messages.get_message_from_mid!(thread, conn.params["mid"]),
        else: nil

    conn
    |> Plug.Conn.assign(:thread, thread)
    |> Plug.Conn.assign(:message, message)
    |> Plug.Conn.assign(:view_all, true)
  end

  def allowed?(conn, action, resource) when action in [:split, :do_split] do
    resource = resource || conn.assigns.message
    Abilities.access_forum?(conn, :moderate) && Helpers.present?(resource.parent_id)
  end

  def allowed?(conn, _, _), do: Abilities.access_forum?(conn, :moderate)
end
