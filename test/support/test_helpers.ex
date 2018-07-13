defmodule Cforum.TestHelpers do
  def cf_redirected_params(conn) do
    router = Phoenix.Controller.router_module(conn)

    %URI{path: path, host: host} =
      conn
      |> Phoenix.ConnTest.redirected_to()
      |> URI.parse()

    {slug, path_info} =
      path
      |> split_path()
      |> maybe_replace_path()

    {conn, _pipes, _dispatch} = router.__match_route__(conn, "GET", path_info, host || conn.host)

    conn.path_params
    |> Enum.into(%{}, fn {key, val} -> {String.to_atom(key), val} end)
    |> Map.put(:curr_forum, slug)
  end

  defp split_path(path) do
    for segment <- String.split(path, "/"), segment != "", do: segment
  end

  defp maybe_replace_path([]), do: {nil, []}
  defp maybe_replace_path([head | tail]), do: maybe_replace_path(head, tail)

  defp maybe_replace_path("all", tail), do: {"all", ["all"] ++ tail}
  defp maybe_replace_path("", tail), do: {nil, [""] ++ tail}

  defp maybe_replace_path(slug, tail) do
    case Cforum.Forums.get_forum_by_slug(slug) do
      %Cforum.Forums.Forum{} ->
        {slug, ["all"] ++ tail}

      _ ->
        {nil, [slug] ++ tail}
    end
  end
end
