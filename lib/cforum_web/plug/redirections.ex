defmodule CforumWeb.Plug.RedirectionsPlug do
  @moduledoc """
  This plug is plugged in the browser pipeline and checks for redirections configured by the admin (or automatically
  by moving a thread to adifferent forum)
  """

  alias Cforum.System

  def init(opts), do: opts

  def call(conn, _opts) do
    path = conn.assigns[:original_path] || conn.request_path

    with redirection when not is_nil(redirection) <- System.get_redirection_by_path(path) do
      conn
      |> Plug.Conn.put_status(301)
      |> Phoenix.Controller.redirect(to: redirection.destination)
      |> Plug.Conn.halt()
    else
      _ -> conn
    end
  end
end
