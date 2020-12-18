defmodule CforumWeb.Plug.CfStatic do
  def init(opts), do: opts

  def call(conn, _opts) do
    opts =
      Plug.Static.init(
        at: "/uploads",
        from: Application.get_env(:cforum, :uploads_dir, Path.expand("./priv/uploads")),
        gzip: false,
        cache_control_for_etags: "public, max-age=31536000"
      )

    Plug.Static.call(conn, opts)
  end
end
