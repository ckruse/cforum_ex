defmodule Cforum.Forums.Messages.Mentions do
  alias Ecto.Changeset
  alias Cforum.Forums.Message
  import Cforum.Helpers, only: [blank?: 1]

  def parse_mentions(%Changeset{valid?: true} = changeset) do
    content = Changeset.get_field(changeset, :content)
    {blocks, context} = Earmark.parse(content, %Earmark.Options{smartypants: true, gfm: true, breaks: false})

    mentions =
      blocks
      |> strip_unwanted_elements(context)
      |> find_mentions_in_blocks()
      |> Enum.map(fn {name, id, in_quote} -> [name, id, in_quote] end)

    flags = Changeset.get_field(changeset, :flags, %{})
    Changeset.put_change(changeset, :flags, Map.put(flags, "mentions", mentions))
  end

  def parse_mentions(changeset), do: changeset

  defp strip_unwanted_elements(blocks, context) do
    blocks
    |> Enum.reject(fn
      %Earmark.Block.Code{} -> true
      _ -> false
    end)
    |> Enum.map(fn
      %Earmark.Block.BlockQuote{} = block ->
        blocks = strip_unwanted_elements(block.blocks, context)
        Map.put(block, :blocks, blocks)

      %{blocks: blocks} = block when blocks != [] ->
        new_blocks = strip_unwanted_elements(blocks, context)
        Map.put(block, :blocks, new_blocks)

      block ->
        lines =
          block.lines
          |> Enum.map(&Regex.replace(context.rules.code, &1, ""))
          |> Enum.reject(&blank?/1)

        Map.put(block, :lines, lines)
    end)
  end

  defp find_mentions_in_blocks(blocks, mentions \\ [], in_quote \\ false) do
    Enum.reduce(blocks, mentions, fn
      %Earmark.Block.BlockQuote{} = block, mentions ->
        find_mentions_in_blocks(block.blocks, mentions, true)

      %{blocks: blocks}, mentions when blocks != [] ->
        find_mentions_in_blocks(blocks, mentions, in_quote)

      block, mentions ->
        found =
          Enum.map(block.lines, &find_mentions(&1, [], in_quote))
          |> List.flatten()
          |> Enum.reject(&blank?/1)

        [found | mentions]
    end)
    |> Enum.reject(&blank?/1)
    |> List.flatten()
  end

  defp find_mentions(content, mentions, in_quote)
  defp find_mentions("\\@" <> rest, mentions, in_quote), do: find_mentions(rest, mentions, in_quote)

  defp find_mentions("@" <> rest, mentions, in_quote) do
    # a mention?
    [line] = Regex.run(~r/^(.*)$/m, rest, capture: :all_but_first)

    words =
      Regex.split(~r/\s+/, line)
      |> Enum.slice(0, 60)

    user = find_user(words)

    if blank?(user),
      do: find_mentions(rest, mentions, in_quote),
      else: find_mentions(rest, [{user.username, user.user_id, in_quote} | mentions], in_quote)
  end

  defp find_mentions("", mentions, _), do: mentions
  defp find_mentions(s, mentions, in_quote), do: find_mentions(String.slice(s, 1..-1), mentions, in_quote)

  defp find_user(words) do
    username = Enum.join(words, " ")

    case Cforum.Accounts.Users.get_user_by_username(username) do
      nil -> find_user(words |> Enum.reverse() |> tl() |> Enum.reverse())
      user -> user
    end
  end

  def mentions_markup(%Message{flags: %{"mentions" => mentions}} = msg, _user) when mentions != [] do
    lines = Regex.split(~r/\015\012|\015|\012/, msg.content)
    mentions = Enum.reduce(mentions, %{}, fn [username, _, _] = mention, acc -> Map.put(acc, username, mention) end)
    names = Map.keys(mentions) |> Enum.map(&"(?:#{Regex.escape(&1)})") |> Enum.join("|")
    rx = Regex.compile!("^@(#{names})\\b")

    content =
      gen_markup(lines, mentions, rx, [])
      |> Enum.join("\n")

    %Message{msg | content: content}
  end

  def mentions_markup(msg, _user), do: msg

  defp gen_markup(lines, mentions, regex, new_content)
  defp gen_markup([], _mentions, _regex, new_content), do: new_content

  defp gen_markup([line | lines], mentions, regex, new_content) do
    cond do
      line =~ ~r/^(?:> *)*\s*~~~\s*\S*$/m ->
        {code_lines, rest} = Enum.split_while(lines, fn line -> !Regex.match?(~r/^(?:> *)*~~~\s*$/m, line) end)

        if blank?(rest),
          # unfinished code block
          do: gen_markup(lines, mentions, regex, new_content ++ line),
          # finished code blocks
          else: gen_markup(tl(rest), mentions, regex, new_content ++ [line] ++ code_lines ++ [hd(rest)])

      true ->
        gen_markup(lines, mentions, regex, new_content ++ [parse_line(line, regex, mentions, "")])
    end
  end

  defp parse_line("", _regex, _mentions, new_line), do: new_line

  defp parse_line(line, regex, mentions, new_line) do
    cond do
      match = Regex.run(regex, line, capture: :all_but_first) ->
        name = List.first(match)
        [_, id, _] = mentions[name]

        url = CforumWeb.Router.Helpers.user_path(CforumWeb.Endpoint, :show, id)
        link = "[@#{name}](#{url}){: .mention .registered-user}"
        parse_line(String.slice(line, (String.length(name) + 1)..-1), regex, mentions, new_line <> link)

      String.first(line) == "`" ->
        {code, rest} = skip_code(String.slice(line, 1..-1), "`")

        if String.first(rest) == "`" && blank?(code),
          # unterminated code
          do: parse_line(String.slice(rest, 1..-1), regex, mentions, new_line <> "`"),
          # terminated code
          else: parse_line(rest, regex, mentions, new_line <> code)

      true ->
        parse_line(String.slice(line, 1..-1), regex, mentions, new_line <> String.first(line))
    end
  end

  # unterminated code
  defp skip_code("", code), do: {"", code}
  defp skip_code("`" <> rest, code), do: {code <> "`", rest}
  defp skip_code("\\`" <> rest, code), do: skip_code(rest, code <> "\\`")
  defp skip_code(str, code), do: skip_code(String.slice(str, 1..-1), code <> String.first(str))
end
