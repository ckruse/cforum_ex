defmodule CforumWeb.Plug.SecurityHeaders do
  def init(opts), do: opts

  def call(conn, _) do
    if Mix.env() == :prod do
      js_nonce =
        32
        |> :crypto.strong_rand_bytes()
        |> Base.url_encode64(padding: false)

      style_nonce =
        32
        |> :crypto.strong_rand_bytes()
        |> Base.url_encode64(padding: false)

      script_csp = "script-src 'self' 'nonce-#{js_nonce}' *.selfhtml.org"
      # 'nonce-#{style_nonce}' not yet possible, due to mathjax
      style_csp = "style-src 'self' 'unsafe-inline'"
      connect_csp = "connect-src 'self' #{scheme()}://#{CforumWeb.Endpoint.config(:url)[:host]}#{port()}"

      conn
      |> Plug.Conn.assign(:nonce_for_js, js_nonce)
      |> Plug.Conn.assign(:nonce_for_style, style_nonce)
      |> Plug.Conn.put_resp_header(
        "Content-Security-Policy",
        "default-src 'self'; #{script_csp}; #{style_csp}; #{connect_csp}"
      )
    else
      conn
      |> Plug.Conn.assign(:nonce_for_js, "")
      |> Plug.Conn.assign(:nonce_for_style, "")
    end
  end

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
