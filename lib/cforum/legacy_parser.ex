defmodule Cforum.LegacyParser do
  import NimbleParsec

  alias Cforum.Messages.Message

  alias Cforum.LegacyParser.{LinkParser, ImageParser, CodeParser}

  text = utf8_char([])

  link_text = repeat(choice([string("\\]"), utf8_char(not: ?])]))
  link_text_title = repeat(lookahead_not(string("@title=")) |> choice([utf8_char(not: ?]), string("\\]")]))
  image_text_title = repeat(lookahead_not(string("@alt=")) |> choice([utf8_char(not: ?]), string("\\]")]))

  escapes =
    [
      replace(lookahead_not(string("\n-- \n")) |> string("\n--"), "\n\\--"),
      replace(ascii_char([?*]), "\\*"),
      replace(ascii_char([?_]), "\\_")
    ]
    |> choice()

  link_with_title =
    replace(string("[link:"), :link_start)
    |> concat(link_text_title)
    |> replace(string("@title="), :link_title)
    |> concat(link_text)
    |> replace(string("]"), :link_end)

  link =
    ignore(string("[link:"))
    |> concat(link_text)
    |> ignore(string("]"))

  pref =
    ignore(string("[pref:"))
    |> replace(string("t="), :tid)
    |> integer(min: 1)
    |> replace(string(";m="), :mid)
    |> integer(min: 1)
    |> ignore(string("]"))

  pref_with_title =
    ignore(string("[pref:"))
    |> replace(string("t="), :tid)
    |> integer(min: 1)
    |> replace(string(";m="), :mid)
    |> integer(min: 1)
    |> replace(string("@title="), :pref_title)
    |> concat(link_text)
    |> ignore(string("]"))

  ref_target =
    choice([
      string("self812"),
      string("self811"),
      string("self81"),
      string("self8"),
      string("sel811"),
      string("sef811"),
      string("slef812"),
      string("self7"),
      string("zitat")
    ])

  ref =
    ignore(string("[ref:"))
    |> concat(ref_target)
    |> ignore(ascii_char([?;]))
    |> concat(link_text)
    |> ignore(string("]"))

  ref_with_title =
    ignore(string("[ref:"))
    |> concat(ref_target)
    |> replace(ascii_char([?;]), :ref_link)
    |> concat(link_text_title)
    |> replace(string("@title="), :ref_title)
    |> concat(link_text)
    |> ignore(string("]"))

  image =
    ignore(string("[image:"))
    |> concat(link_text)
    |> ignore(string("]"))

  image_with_title =
    replace(string("[image:"), :image_start)
    |> concat(image_text_title)
    |> replace(string("@alt="), :image_alt)
    |> concat(link_text)
    |> replace(string("]"), :image_end)

  code_start =
    replace(string("[code"), :code_start)
    |> optional(repeat(ignore(string(" "))) |> replace(string("lang="), :code_lang) |> repeat(utf8_char(not: ?])))
    |> replace(string("]"), :code_start_end)

  code_end = replace(string("[/code]"), :code_end)

  code_inline =
    code_start
    |> repeat(lookahead_not(code_end) |> utf8_char(not: ?\n))
    |> concat(code_end)

  code_block =
    code_start
    |> repeat(lookahead_not(code_end) |> concat(text))
    |> concat(code_end)

  defparsec(
    :tokenize,
    [
      link_with_title |> post_traverse({LinkParser, :markdown_with_title, []}),
      link |> post_traverse({LinkParser, :markdown, []}),
      pref |> post_traverse({LinkParser, :markdown_pref, []}),
      pref_with_title |> post_traverse({LinkParser, :markdown_pref_title, []}),
      ref |> post_traverse({LinkParser, :markdown_ref, []}),
      ref_with_title |> post_traverse({LinkParser, :markdown_ref_title, []}),
      image_with_title |> post_traverse({ImageParser, :markdown_with_title, []}),
      image |> post_traverse({ImageParser, :markdown, []}),
      code_inline |> post_traverse({CodeParser, :markdown_inline, []}),
      code_block |> post_traverse({CodeParser, :markdown_block, []}),
      escapes,
      text
    ]
    |> choice()
    |> repeat()
    # |> post_traverse({CodeParser, :markdown, []})
  )

  def parse(message) do
    content =
      message.content
      |> String.replace(~r{<br ?/>-- <br ?/>}, "\n-- \n")
      |> String.replace(~r{<br ?/>}, "  \n")
      |> String.replace(~r/\x7f/, "> ")
      |> String.replace(~r/^(\d+)\./m, "\\1\\.")

    content =
      with {:ok, str, "", _v1, _v2, _v3} <- tokenize(content) do
        str
        |> to_string()
        |> HtmlEntities.decode()
      else
        _ -> message.content
      end

    %Message{message | content: content, format: "markdown"}
  end

  # defp to_markdown([], str), do: str
  # defp to_markdown([%Token{name: :default, value: val} | rest], str), do: to_markdown(rest, [str | [val]])

  # defp parse_content("", new_content), do: new_content
  # defp parse_content("\u007F" <> rest, new_content), do: parse_content(rest, new_content <> "> ")
  # defp parse_content("|" <> rest, new_content), do: parse_content(rest, new_content <> "\\|")

  # defp parse_content("<br" <> rest, new_content) do
  #   cond do
  #     String.match?(rest, ~r{^ ?/>-- <br ?/>}) ->
  #       parse_content(drop_prefix(rest, ~r{^ ?/>-- <br ?/>}), new_content <> "\n-- \n")

  #     String.match?(rest, ~r{^ ?/>}) ->
  #       parse_content(drop_prefix(rest, ~r{^ ?/>}), new_content <> "  \n")

  #     true ->
  #       raise "Hu?! #{inspect(rest)}"
  #   end
  # end

  # defp parse_content("[link:" <> rest, new_content) do
  #   with {target, desc, rest} <- LinkParser.parse(rest) do
  #     parse_content(rest, new_content <> LinkParser.markdown(target, desc))
  #   else
  #     _ -> parse_content(rest, new_content <> "[link:")
  #   end
  # end

  # defp parse_content("[image:" <> rest, new_content) do
  #   with {target, desc, rest} <- ImageParser.parse(rest) do
  #     parse_content(rest, new_content <> ImageParser.markdown(target, desc))
  #   else
  #     _ -> parse_content(rest, new_content <> "[link:")
  #   end
  # end

  # defp parse_content("[code" <> rest, new_content) do
  # end

  # defp parse_content(str, new_content) do
  #   cond do
  #     retval = Regex.run(~r/^(-{2,})|\*|_/, str, capture: :first) ->
  #       match = List.first(retval)
  #       rest = String.slice(str, String.length(match)..-1)
  #       parse_content(rest, new_content <> "\\" <> match)

  #     true ->
  #       parse_content(String.slice(str, 1..-1), new_content <> String.first(str))
  #   end
  # end

  # defp drop_prefix(value, pattern), do: Regex.replace(pattern, value, "", global: false)
end
