defmodule CforumWeb.BlogpostController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.ConfigManager
  alias Cforum.Threads.ThreadHelpers

  alias CforumWeb.Views.ViewHelpers.Path

  def show(conn, %{"month" => mon}) do
    if Regex.match?(~r/^\d+$/, mon),
      do: redirect(conn, to: Path.blog_thread_path(conn, :show, conn.assigns.article)),
      else: render(conn, "show.html")
  end

  defp load_thread_and_message(conn, :show) do
    thread =
      conn.assigns[:current_forum]
      |> Threads.get_thread_by_slug!(conn.assigns[:visible_forums], ThreadHelpers.slug_from_params(conn.params, true))
      |> Threads.reject_deleted_threads(conn.assigns[:view_all])
      |> Threads.ensure_found!()
      |> Threads.apply_user_infos(conn.assigns[:current_user])
      |> Threads.apply_highlights(conn)
      |> Threads.build_message_tree(ConfigManager.uconf(conn, "sort_messages"))

    assign(conn, :article, thread)
  end

  defp load_thread_and_message(conn, _), do: conn

  def load_resource(conn) do
    load_thread_and_message(conn, action_name(conn))
  end

  def allowed?(_, _, _), do: true
end
