defmodule CforumWeb.Plug.ValidateId do
  def init(opts), do: opts

  def call(conn, _opts) do
    controller = Phoenix.Controller.controller_module(conn)
    action = Phoenix.Controller.action_name(conn)

    if Keyword.has_key?(controller.__info__(:functions), :id_fields),
      do: check_fields(apply(controller, :id_fields, [action]), conn),
      else: conn
  end

  def check_fields(fields, conn) when is_nil(fields) or fields == [],
    do: conn

  def check_fields(fields, conn) do
    Enum.each(
      fields,
      fn
        {field, rx} ->
          cond do
            Map.has_key?(conn.params, field) && is_binary(conn.params[field]) && Regex.match?(rx, conn.params[field]) ->
              :ok

            Map.has_key?(conn.params, field) ->
              raise(Cforum.Errors.NotFoundError, conn: conn)

            true ->
              :ok
          end

        field ->
          cond do
            Map.has_key?(conn.params, field) && is_binary(conn.params[field]) &&
                Regex.match?(~r/\A\d+\z/, conn.params[field]) ->
              :ok

            Map.has_key?(conn.params, field) ->
              raise(Cforum.Errors.NotFoundError, conn: conn)

            true ->
              :ok
          end
      end
    )

    conn
  end
end
