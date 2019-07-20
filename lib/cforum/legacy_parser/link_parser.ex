defmodule Cforum.LegacyParser.LinkParser do
  def markdown_with_title(_rest, args, context, _line, _offset) do
    {_, map} =
      args
      |> Enum.reduce({nil, %{}}, fn
        :link_start, {_, map} -> {:start, map}
        :link_title, {_, map} -> {:title, map}
        :link_end, {_, map} -> {:end, map}
        c, {el, map} -> {el, Map.update(map, el, [c], &[[c] | &1])}
      end)

    title =
      map[:end]
      |> to_string()
      |> escape_title()

    link =
      "[#{title}](#{map[:title]})"
      |> to_charlist()
      |> Enum.reverse()

    {link, context}
  end

  def markdown(_rest, args, context, _line, _offset) do
    {[?>] ++ args ++ [?<], context}
  end

  def markdown_pref(_rest, [mid, :mid, tid, :tid], context, _line, _offset) do
    link =
      "<#{CforumWeb.Router.Helpers.root_url(CforumWeb.Endpoint, :index)}?t=#{tid}&m=#{mid}>"
      |> to_charlist()
      |> Enum.reverse()

    {link, context}
  end

  def markdown_pref_title(_rest, args, context, _line, _offset) do
    [:tid, tid, :mid, mid, :pref_title | tail] = Enum.reverse(args)

    title = to_string(tail) |> escape_title()

    link =
      "[#{title}](#{CforumWeb.Router.Helpers.root_url(CforumWeb.Endpoint, :index)}?t=#{tid}&m=#{mid})"
      |> to_charlist()
      |> Enum.reverse()

    {link, context}
  end

  def markdown_ref(_rest, args, context, _line, _offset) do
    [ref | target] = Enum.reverse(args)
    base_url = url_by_ref(ref)

    link =
      "<#{base_url}#{target}>"
      |> to_charlist()
      |> Enum.reverse()

    {link, context}
  end

  def markdown_ref_title(_rest, args, context, _line, _offset) do
    [ref | tail] = Enum.reverse(args)

    base_url = url_by_ref(ref)

    {_, values} =
      Enum.reduce(tail, {:title, %{}}, fn
        :ref_link, {_, map} -> {:href, map}
        :ref_title, {_, map} -> {:title, map}
        s, _ when is_atom(s) -> raise inspect(s)
        c, {el, map} -> {el, Map.update(map, el, [c], &[&1 | [c]])}
      end)

    title =
      values[:title]
      |> to_string()
      |> escape_title()

    link = "[#{title}](#{base_url}#{values[:href]})" |> to_charlist() |> Enum.reverse()

    {link, context}
  end

  defp url_by_ref(ref) when ref in ~w[self8 self81 self811 self812 sel811 sef811 slef812], do: "http://de.selfhtml.org/"
  defp url_by_ref("self7"), do: "http://aktuell.de.selfhtml.org/archiv/doku/7.0/"
  defp url_by_ref("zitat"), do: "/cites/old/"

  defp escape_title(text), do: String.replace(text, "[", "\\[")
end
