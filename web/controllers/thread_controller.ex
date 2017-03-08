defmodule Cforum.ThreadController do
  use Cforum.Web, :controller

  def index(conn, params) do
    page = if blank?(params[:p]) || String.to_integer(params[:p]) <= 0,
             do: 0,
             else: String.to_integer(params[:p])

    limit = String.to_integer(Cforum.ConfigManager.uconf(conn, "pagination"))

    threads = Cforum.ThreadsHelper.index_threads(conn, page: page, limit: limit)

    conn
    |> render("index.html", threads: threads)
  end
end
