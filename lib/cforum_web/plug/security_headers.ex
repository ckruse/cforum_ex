defmodule CforumWeb.Plug.SecurityHeaders do
  def init(opts), do: opts

  def call(%{request_path: "/admin/dashboard" <> _} = conn, _), do: conn

  def call(conn, _) do
    if Application.get_env(:cforum, :environment) == :prod do
      js_nonce =
        32
        |> :crypto.strong_rand_bytes()
        |> Base.url_encode64(padding: false)

      style_nonce =
        32
        |> :crypto.strong_rand_bytes()
        |> Base.url_encode64(padding: false)

      script_csp = "script-src 'self' 'nonce-#{js_nonce}' *.selfhtml.org" <> maybe_unsafe_eval(conn.request_path)
      # 'nonce-#{style_nonce}' not yet possible, due to mathjax
      style_csp = "style-src 'self' 'unsafe-inline'"

      connect_csp =
        "connect-src 'self' #{scheme()}://#{CforumWeb.Endpoint.config(:url)[:host]}#{port()}" <>
          maybe_osm_connect(conn.request_path)

      frame_src = "frame-src wiki.selfhtml.org"
      img_src = "img-src 'self' wiki.selfhtml.org blog.selfhtml.org forum.selfhtml.org"

      conn
      |> Plug.Conn.assign(:nonce_for_js, js_nonce)
      |> Plug.Conn.assign(:nonce_for_style, style_nonce)
      |> Plug.Conn.put_resp_header(
        "Content-Security-Policy",
        "default-src 'self'; #{frame_src}; #{img_src}; #{script_csp}; #{style_csp}; #{connect_csp}" <>
          img_csp(conn.request_path)
      )
    else
      conn
      |> Plug.Conn.assign(:nonce_for_js, "")
      |> Plug.Conn.assign(:nonce_for_style, "")
    end
  end

  defp maybe_unsafe_eval("/events/" <> _id), do: " 'unsafe-eval'"
  defp maybe_unsafe_eval(_), do: ""

  defp img_csp("/events/" <> _id), do: "; img-src 'self' *.tile.openstreetmap.de data:"
  defp img_csp(_), do: "; img-src 'self' data:"

  defp maybe_osm_connect("/events/" <> _id), do: " nominatim.openstreetmap.org"
  defp maybe_osm_connect(_), do: ""

  defp scheme do
    port = CforumWeb.Endpoint.config(:url)[:port] || CforumWeb.Endpoint.config(:http)[:port]

    if port == 443,
      do: "wss",
      else: "ws"
  end

  defp port do
    port = CforumWeb.Endpoint.config(:url)[:port] || CforumWeb.Endpoint.config(:http)[:port]

    if port != 443 && port != 80,
      do: ":#{port}",
      else: ""
  end
end
