defmodule Cforum.LegacyParser.ImageParser do
  def markdown_with_title(_rest, args, context, _line, _offset) do
    {_, map} =
      args
      |> Enum.reduce({nil, %{}}, fn
        :image_start, {_, map} -> {:start, map}
        :image_alt, {_, map} -> {:title, map}
        :image_end, {_, map} -> {:end, map}
        c, {el, map} -> {el, Map.update(map, el, [c], &[[c] | &1])}
      end)

    img =
      [?!, ?[, map[:end], ?], ?(, map[:title], ?)]
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Enum.reverse()

    {img, context}
  end

  def markdown(_rest, args, context, _line, _offset) do
    {[?)] ++ args ++ [?(, ?], ?[, ?!], context}
  end
end
