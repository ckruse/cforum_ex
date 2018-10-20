defmodule CforumWeb.Plug.LoadResource do
  def init(opts), do: opts

  def call(conn, _opts) do
    controller = Phoenix.Controller.controller_module(conn)

    if Keyword.has_key?(controller.__info__(:functions), :load_resource),
      do: apply(controller, :load_resource, [conn]),
      else: conn
  end
end
