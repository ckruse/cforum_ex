defmodule CforumWeb.Plug.Session do
  @behaviour Plug

  def init(opts), do: Plug.Session.init(opts)

  def call(conn, opts) do
    domain = Application.get_env(:cforum, :cookie_domain)

    runtime_opts =
      if domain,
        do: Map.update(opts, :cookie_opts, [domain: domain], &Keyword.put(&1, :domain, domain)),
        else: opts

    Plug.Session.call(conn, runtime_opts)
  end
end
