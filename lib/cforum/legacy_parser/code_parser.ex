defmodule Cforum.LegacyParser.CodeParser do
  # def markdown(_rest, args, context, _line, _offset) do
  #   #  |> to_charlist()
  #   transformed =
  #     args
  #     |> Enum.reverse()
  #     |> transform_code([])
  #     |> List.flatten()
  #     |> Enum.reverse()

  #   {transformed, context}
  # end

  # defp transform_code([:code_start, :code_start_end | rest], transformed), do: transform_code(rest, transformed)

  # defp transform_code([:code_start, :code_lang | rest], transformed) do
  #   {rest, lang} = get_lang(rest, [])
  #   transform_code(rest, [transformed | ["~~~#{lang}"]])
  # end

  # defp transform_code([:code_end | rest], transformed), do: transform_code(rest, [transformed | ["~~~"]])

  # defp transform_code([c | rest], transformed), do: transform_code(rest, [transformed | [c]])
  # defp transform_code([], transformed), do: transformed

  # defp get_lang([:code_start_end | rest], lang), do: {rest, lang}
  # defp get_lang([c | rest], lang), do: get_lang(rest, [lang | [c]])

  def markdown_inline(_rest, args, context, _line, _offset) do
    {_, map} =
      args
      |> Enum.reduce({nil, %{}}, fn
        :code_start, {_, map} -> {:start, map}
        :code_lang, {_, map} -> {:lang, map}
        :code_end, {_, map} -> {:end, map}
        :code_start_end, {_, map} -> {:lang, map}
        c, {el, map} -> {el, Map.update(map, el, [c], &[[c] | &1])}
      end)

    code =
      if map[:lang] do
        [?`, map[:end], ?`, "{:.language-", map[:lang], "}"]
      else
        [?`, map[:end], ?`]
      end
      |> List.flatten()
      |> Enum.reverse()

    {code, context}
  end

  def markdown_block(_rest, args, context, _line, _offset) do
    args =
      args
      |> Enum.map(fn
        :code_start -> [?~, ?~, ?~]
        :code_start_end -> ?\n
        :code_end -> [?~, ?~, ?~, ?\n]
        :code_lang -> nil
        c -> c
      end)
      |> Enum.reject(&is_nil/1)
      |> List.flatten()

    {args, context}
  end
end
