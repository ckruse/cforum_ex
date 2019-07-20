defmodule Cforum.LegacyParser.ImageParser do
  # def parse(rest) do
  #   case Regex.run(~r{((?:[^\]]|\\\])+)\]}, rest) do
  #     nil ->
  #       nil

  #     [full_match, link] ->
  #       {target, desc} = parse_target(link)
  #       {target, desc, String.slice(rest, String.length(full_match)..-1)}
  #   end
  # end

  # defp parse_target(target) do
  #   case Regex.run(~r{(.*?)@alt=(.*)}, target, capture: :all_but_first) do
  #     nil -> {target, nil}
  #     [target, title] -> {target, title}
  #   end
  # end

  # def markdown(target, nil), do: "![](#{target})"
  # def markdown(target, desc), do: "![#{desc}](#{target})"

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
      |> Enum.reverse()

    {img, context}
  end

  def markdown(_rest, args, context, _line, _offset) do
    {[?)] ++ args ++ [?(, ?], ?[, ?!], context}
  end
end
