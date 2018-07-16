defmodule Cforum.Errors.ForbiddenError do
  defexception plug_status: 403, message: "Access forbidden", conn: nil

  def exception(opts) do
    conn = Keyword.fetch!(opts, :conn)
    path = "/" <> Enum.join(conn.path_info, "/")
    %Cforum.Errors.ForbiddenError{message: "Access forbidden for #{conn.method} #{path}", conn: conn}
  end
end
