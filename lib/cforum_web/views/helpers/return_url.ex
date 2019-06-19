defmodule CforumWeb.Views.Helpers.ReturnUrl do
  alias CforumWeb.Views.Helpers.Path

  alias Cforum.Helpers

  def return_path(conn, params, thread \\ nil, message \\ nil, args \\ %{}) do
    args =
      %{p: params["p"], page: params["page"]}
      |> Map.merge(args)
      |> Enum.filter(fn {_k, v} -> Helpers.present?(v) end)
      |> Enum.into(%{})
      |> Helpers.map_maybe_set(:view_all, "yes", conn.assigns[:view_all])

    int_return_path(conn, params, thread, message, args)
  end

  defp int_return_path(conn, _, nil, nil, args),
    do: Path.forum_path(conn, :index, conn.assigns[:current_forum], args)

  defp int_return_path(conn, params, thread, message, args) do
    forum_slug = get_forum_slug(conn, params)

    case params["r"] do
      nil ->
        Path.forum_path(conn, :index, forum_slug, args)

      "thread" ->
        r = Path.forum_path(conn, :index, forum_slug, args)

        if Helpers.blank?(thread) || Helpers.blank?(thread.thread_id),
          do: r,
          else: r <> "#t#{thread.thread_id}"

      "message" ->
        args =
          args
          |> Map.delete(:p)
          |> Map.delete(:page)

        Path.message_path(conn, :show, thread, message || List.first(thread.messages), args)

      "messages/interesting" ->
        Path.interesting_message_path(conn, thread, message || List.first(thread.messages), args)

      "threads/invisible" ->
        Path.invisible_thread_path(conn, :index, nil, args)
    end
  end

  defp get_forum_slug(conn, params) do
    f =
      if Helpers.blank?(params["f"]),
        do: "",
        else: String.replace(params["f"], ~r/[^a-z0-9_-]/, "")

    f = if Helpers.blank?(f), do: Path.forum_slug(conn.assigns[:current_forum], false), else: f
    if Helpers.blank?(f), do: raise(Ecto.NoResultsError, queryable: Forum), else: f
  end
end
