defmodule CforumWeb.Plug.LoadMotd do
  @moduledoc """
  This plug loads the message of the day and assigns it
  """

  alias Cforum.ConfigManager
  import Cforum.Helpers, only: [present?: 1]

  def init(opts), do: opts

  def call(conn, _opts) do
    motd = ConfigManager.conf(conn, "motd")
    global_motd = ConfigManager.conf(Plug.Conn.assign(conn, :current_forum, nil), :motd)

    motds =
      [global_motd, motd]
      |> Enum.filter(&present?/1)
      |> Enum.uniq()

    if present?(motds),
      do: Plug.Conn.assign(conn, :motds, motds),
      else: conn
  end
end
