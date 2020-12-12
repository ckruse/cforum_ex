defmodule CforumWeb.Plug.GhWebhookAuth do
  def init(opts), do: opts

  def call(conn, _opts) do
    with {:ok, digest} <- get_signature_digest(conn),
         {:ok, secret} <- get_secret(),
         :ok <- valid_request?(digest, secret, conn) do
      conn
    else
      _ -> conn |> Plug.Conn.send_resp(401, "Couldn't Authenticate") |> Plug.Conn.halt()
    end
  end

  defp get_signature_digest(conn) do
    case Plug.Conn.get_req_header(conn, "x-hub-signature") do
      ["sha256=" <> digest] -> {:ok, digest}
      _ -> {:error, "No Github Signature Found"}
    end
  end

  defp get_secret do
    Application.get_env(:cforum, :deploy_secret)
  end

  defp valid_request?(digest, secret, conn) do
    hmac = :crypto.hmac(:sha, secret, conn.assigns.raw_body) |> Base.encode16(case: :lower)

    if Plug.Crypto.secure_compare(digest, hmac),
      do: :ok,
      else: :error
  end
end
