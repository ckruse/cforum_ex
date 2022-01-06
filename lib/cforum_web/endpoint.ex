defmodule CforumWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :cforum
  use Appsignal.Phoenix

  socket "/socket", CforumWeb.UserSocket, websocket: true
  socket "/live", Phoenix.LiveView.Socket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(
    Plug.Static,
    at: "/",
    from: :cforum,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt humans.txt)
  )

  plug(CforumWeb.Plug.CfStatic)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug(Phoenix.LiveDashboard.RequestLogger, param_key: "request_logger", cookie_key: "request_logger")
  plug(Plug.RequestId)
  plug(Plug.Logger)
  plug(CforumWeb.Plug.CurrentForum)

  plug(GhWebhookPlug,
    secret: Application.get_env(:cforum, :deploy_secret),
    path: "/api/gh/deploy",
    action: {Cforum.DeployTask, :deploy}
  )

  plug(Plug.Parsers,
    parsers: [:urlencoded, {:multipart, length: 104_857_600}, :json],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(CforumWeb.Plug.Session,
    store: :cookie,
    key: "_cforum_key",
    signing_salt: "aRQT3uvM",
    http_only: true
  )

  plug(CforumWeb.Router)

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  @impl true
  def init(_key, config) do
    if config[:load_from_system_env] do
      port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
      {:ok, Keyword.put(config, :http, [:inet6, port: port])}
    else
      {:ok, config}
    end
  end
end
