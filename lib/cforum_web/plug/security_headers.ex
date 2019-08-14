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

      script_csp = "script-src 'self' 'nonce-#{js_nonce}'"
      style_csp = "style-src 'self' 'nonce-#{style_nonce}'"

      conn
      |> Plug.Conn.assign(:nonce_for_js, js_nonce)
      |> Plug.Conn.assign(:nonce_for_style, style_nonce)
      |> Plug.Conn.put_resp_header("Content-Security-Policy", "default-src 'self'; #{script_csp}; #{style_csp}")
    else
      conn
      |> Plug.Conn.assign(:nonce_for_js, "")
      |> Plug.Conn.assign(:nonce_for_style, "")
    end
  end
end
