defmodule Cforum.Errors.NotFoundError do
  defexception plug_status: 404, message: "Not found", conn: nil

  def exception(opts) do
    conn = Keyword.fetch!(opts, :conn)
    path = "/" <> Enum.join(conn.path_info, "/")
    %Cforum.Errors.NotFoundError{message: "#{conn.method} #{path} not found", conn: conn}
  end
end
