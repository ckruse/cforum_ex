defmodule Cforum.BlogImport.Autop do
  @allblocks "(?:table|thead|tfoot|caption|col|colgroup|tbody|tr|td|th|div|dl|dd|dt|ul|ol|li|pre|form|map|area|blockquote|address|math|style|p|h[1-6]|hr|fieldset|legend|section|article|aside|hgroup|header|footer|nav|figure|figcaption|details|menu|summary)"
  @opening_blocks_rx ~r/(<#{@allblocks}[\s\/>])/
  @closing_blocks_rx ~r/(<\/#{@allblocks}>)/
  @hr_rx ~r/(<hr\s*?\/?>)/
  @nl_rx ~r/\015\012|\015|\012/

  def parse(text) do
    {masked_tags, pre_tags} = mask_pre(text)

    replaced =
      masked_tags
      |> add_linebreaks_at_blocks()
      |> String.replace(@nl_rx, "\n")
      |> replace_newlines_in_html()
      |> String.replace(~r/\s*<option/, "<option")
      |> String.replace(~r/<\/option>\s*/, "</option>")
      |> String.replace(~r|(<object[^>]*>)\s*|, "\\1")
      |> String.replace(~r|\s*</object>|, "</object>")
      |> String.replace(~r/\s*(<\/?(?:param|embed)[^>]*>)\s*/, "\\1")
      |> String.replace(~r/([<\[](?:audio|video)[^>\]]*[>\]])\s*/, "\\1")
      |> String.replace(~r/\s*([<\[]\/(?:audio|video)[>\]])/, "\\1")
      |> String.replace(~r/\s*(<(?:source|track)[^>]*>)\s*%/, "\\1")
      |> String.replace(~r/\s*(<figcaption[^>]*>)/, "\\1")
      |> String.replace(~r|</figcaption>\s*|, "</figcaption>")
      |> String.replace(~r/\n\n+/, "\n\n")
      |> String.split(~r/\n\s*\n/, trim: true)
      |> Enum.map(fn part -> "<p>#{String.trim(part, "\n")}</p>\n" end)
      |> Enum.join()
      |> String.replace(~r|<p>\s*</p>|, "")
      |> String.replace(~r'<p>([^<]+)</(div|address|form)>', "<p>\\1</p></\\2>")
      |> String.replace(~r|<p>\s*(</?#{@allblocks}[^>]*>)\s*</p>|, "\\1")
      |> String.replace(~r|<p>(<li.+?)</p>|, "\\1")
      |> String.replace(~r|<p><blockquote([^>]*)>|i, "<blockquote\\1><p>")
      |> String.replace("</blockquote></p>", "</p></blockquote>")
      |> String.replace(~r|<p>\s*(</?#{@allblocks}[^>]*>)|, "\\1")
      |> String.replace(~r|(</?#{@allblocks}[^>]*>)\s*</p>|, "\\1")
      |> replace_untouchable_newlines()
      |> String.replace(~r|<br\s*/?>|, "<br>")
      |> String.replace(~r|(?<!<br>)\s*\n|, "<br>\n")
      |> String.replace(~r|<WPPreserveNewline />|, "\n")
      |> String.replace(~r|(</?#{@allblocks}[^>]*>)\s*<br>|, "\\1")
      |> String.replace(~r/<br>(\s*<\/?(?:p|li|div|dl|dd|dt|th|pre|td|ul|ol)[^>]*>)/, "\\1")
      |> String.replace(~r|\n</p>$|, "</p>")

    Enum.reduce(pre_tags, replaced, fn {k, v}, text -> String.replace(text, k, v) end)
    |> String.replace(~r/ ?<!-- wpnl --> ?/, "\n")
  end

  defp replace_untouchable_newlines(str) do
    Regex.replace(~r/<(script|style|svg).*?<\/\\1>/s, str, fn match ->
      String.replace("\n", "<WPPreserveNewline />", match)
    end)
  end

  defp add_linebreaks_at_blocks(text) do
    text
    |> String.replace(@opening_blocks_rx, "\n\n\\1")
    |> String.replace(@closing_blocks_rx, "\\1\n\n")
    |> String.replace(@hr_rx, "\\1\n\n")
  end

  defp index(str, rx) do
    case Regex.run(rx, str, return: :index) do
      [{start, _len}] -> start
      _ -> false
    end
  end

  defp mask_pre(text) do
    if String.contains?(text, "<pre") do
      all_pre_parts = String.split(text, "</pre>") |> Enum.reverse()
      last_pre = hd(all_pre_parts)
      pre_parts = tl(all_pre_parts) |> Enum.reverse()

      {txt, pre_tags, _} =
        Enum.reduce(pre_parts, {"", %{}, 0}, fn pre_part, {txt, pre_tags, i} ->
          start = index(pre_part, ~r/<pre/)

          if start == false do
            {txt <> pre_part, pre_tags, i}
          else
            name = "<pre wp-pre-tag-#{i}></pre>"
            only_pre = String.slice(pre_part, start..-1) <> "</pre>"
            until_pre = String.slice(pre_part, 0..start) <> name

            {txt <> until_pre, Map.put(pre_tags, name, only_pre), i + 1}
          end
        end)

      {txt <> last_pre, pre_tags}
    else
      {text, %{}}
    end
  end

  @split_html_rx ~r'(<(?(?=!--|!\[CDATA\[)(?(?=!-)!(?:-(?!->)[^\-]*+)*+(?:-->)?|!\[CDATA\[[^\]]*+(?:](?!]>)[^\]]*+)*+(?:]]>)?)|[^>]*>?))'

  defp replace_newlines_in_html(txt) do
    textarr = split_html(txt)

    {ary, _} =
      Enum.reduce(textarr, {[], 0}, fn elem, {lst, i} ->
        new_element =
          if i > 0 && rem(i + 1, 2) == 0,
            do: String.replace(elem, "\n", " <!-- wpnl --> "),
            else: elem

        {lst ++ [new_element], i + 1}
      end)

    Enum.join(ary)
  end

  defp split_html(text) do
    Regex.split(@split_html_rx, text, include_captures: true)
  end
end
