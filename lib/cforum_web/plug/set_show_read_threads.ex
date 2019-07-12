defmodule CforumWeb.Plug.SetShowReadThreads do
  @moduledoc """
  This plug is plugged in the browser pipeline and sets the view_all switch if
  the user may use it and if it is present in the query parameters
  """

  alias CforumWeb.Views.Helpers.Path

  def init(opts), do: opts

  def call(conn, _) do
    if conn.params["srt"] do
      Path.add_url_flag(conn, :srt, "yes")
    else
      Path.del_url_flag(conn, :srt)
    end
  end
end
