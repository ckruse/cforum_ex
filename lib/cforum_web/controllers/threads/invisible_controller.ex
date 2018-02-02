defmodule CforumWeb.Threads.InvisibleController do
  use CforumWeb, :controller

  alias Cforum.Forums.Threads
  alias CforumWeb.Views.Helpers.ReturnUrl

  plug(CforumWeb.Plug.AuthorizeAccess)

  def hide(conn, params) do
    thread =
      Threads.get_thread_by_slug!(
        conn.assigns[:current_user],
        Threads.slug_from_params(params)
      )

    Threads.hide_thread(conn.assigns[:current_user], thread)

    conn
    |> put_flash(:info, gettext("Thread has successfully been hidden."))
    |> redirect(to: ReturnUrl.return_path(conn, params, thread))
  end
end
