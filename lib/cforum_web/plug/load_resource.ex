defmodule CforumWeb.Plug.LoadResource do
  def init(opts), do: opts

  def call(conn, _opts) do
    if Keyword.has_key?(Phoenix.Controller.controller_module(conn).__info__(:functions), :load_resource),
      do: apply(Phoenix.Controller.controller_module(conn), :load_resource, [conn]),
      else: conn
  end
end
