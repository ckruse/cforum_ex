defmodule Cforum.Messages.Mentions do
  alias Ecto.Changeset
  alias Cforum.Helpers
  alias Cforum.Messages.Message
  alias Cforum.ConfigManager
  alias Cforum.Messages.HighlightsHelper

  def parse_mentions(%Changeset{valid?: true} = changeset) do
    content = Changeset.get_field(changeset, :content)
    options = %Earmark.Options{smartypants: true, gfm: true, breaks: false}
    {blocks, context} = Earmark.Parser.parse_markdown(content, options)

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
      rec -> !Map.has_key?(rec, :lines) && !Map.has_key?(rec, :blocks)
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
          |> Enum.reject(&Helpers.blank?/1)

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
          |> Enum.reject(&Helpers.blank?/1)

        [found | mentions]
    end)
    |> Enum.reject(&Helpers.blank?/1)
    |> List.flatten()
  end

  defp find_mentions(content, mentions, in_quote)
  defp find_mentions("\\@" <> rest, mentions, in_quote), do: find_mentions(rest, mentions, in_quote)
  defp find_mentions("@@" <> rest, mentions, in_quote), do: find_mentions(rest, mentions, in_quote)

  defp find_mentions("@" <> rest, mentions, in_quote) do
    # a mention?
    [line] = Regex.run(~r/^(.*)$/m, rest, capture: :all_but_first)
    user = find_user(line)

    if Helpers.blank?(user),
      do: find_mentions(rest, mentions, in_quote),
      else: find_mentions(rest, [{user.username, user.user_id, in_quote} | mentions], in_quote)
  end

  defp find_mentions("", mentions, _), do: mentions
  defp find_mentions(s, mentions, in_quote), do: find_mentions(String.slice(s, 1..-1), mentions, in_quote)

  defp find_user(""), do: nil

  defp find_user(line) do
    case Cforum.Users.get_user_by_username(line) do
      nil ->
        find_user(trim_line_for_username_search(line))

      user ->
        user
    end
  end

  defp trim_line_for_username_search(line) do
    if line =~ ~r/[^\w]+$/u,
      do: Regex.replace(~r/[^\w]+$/u, line, ""),
      else: Regex.replace(~r/\s*\w+$/u, line, "")
  end

  def mentions_markup(%Message{flags: %{"mentions" => mentions}} = msg, _user) when not is_list(mentions), do: msg

  def mentions_markup(%Message{flags: %{"mentions" => mentions}} = msg, user) when mentions != [] do
    config = ConfigManager.settings_map(nil, user)
    lines = Regex.split(~r/\015\012|\015|\012/, msg.content)
    mentions = Enum.reduce(mentions, %{}, fn [username, _, _] = mention, acc -> Map.put(acc, username, mention) end)
    names = Map.keys(mentions) |> Enum.map(&"(?:#{Regex.escape(&1)})") |> Enum.join("|")
    rx = Regex.compile!("^@(#{names})(?:\\b|[^\\w]|\\z)", "u")

    content =
      gen_markup(config, user, lines, mentions, rx, [])
      |> Enum.join("\n")

    %Message{msg | content: content}
  end

  def mentions_markup(msg, _user), do: msg

  defp gen_markup(config, user, lines, mentions, regex, new_content)
  defp gen_markup(_config, _user, [], _mentions, _regex, new_content), do: new_content

  defp gen_markup(config, user, [line | lines], mentions, regex, new_content) do
    if line =~ ~r/^(?:> *)*\s*~~~\s*\S*$/m do
      {code_lines, rest} = Enum.split_while(lines, fn line -> !Regex.match?(~r/^(?:> *)*~~~\s*$/m, line) end)

      if Helpers.blank?(rest) do
        # unfinished code block
        gen_markup(config, user, lines, mentions, regex, Enum.concat(new_content, [line]))
      else
        # finished code blocks
        val =
          new_content
          |> Enum.concat([line])
          |> Enum.concat(code_lines)
          |> Enum.concat([hd(rest)])

        gen_markup(config, user, tl(rest), mentions, regex, val)
      end
    else
      cnt = Enum.concat(new_content, [parse_line(config, user, line, regex, mentions, "")])
      gen_markup(config, user, lines, mentions, regex, cnt)
    end
  end

  defp parse_line(_config, _user, "", _regex, _mentions, new_line), do: new_line

  defp parse_line(config, user, "@@" <> rest, regex, mentions, new_line),
    do: parse_line(config, user, rest, regex, mentions, new_line <> "@@")

  defp parse_line(config, user, line, regex, mentions, new_line) do
    cond do
      match = Regex.run(regex, line, capture: :all_but_first) ->
        name = List.first(match)
        [_, id, _] = mentions[name]

        classes =
          HighlightsHelper.highlights_for_username(config, user, name)
          |> Enum.map(&".#{&1}")
          |> Enum.join(" ")

        url = CforumWeb.Router.Helpers.user_path(CforumWeb.Endpoint, :show, id)
        link = "[@#{name}](#{url}){: .mention .registered-user #{classes}}"
        parse_line(config, user, String.slice(line, (String.length(name) + 1)..-1), regex, mentions, new_line <> link)

      String.first(line) == "`" ->
        {code, rest} = skip_code(String.slice(line, 1..-1), "`")

        if String.first(rest) == "`" && Helpers.blank?(code),
          # unterminated code
          do: parse_line(config, user, String.slice(rest, 1..-1), regex, mentions, new_line <> "`"),
          # terminated code
          else: parse_line(config, user, rest, regex, mentions, new_line <> code)

      true ->
        parse_line(config, user, String.slice(line, 1..-1), regex, mentions, new_line <> String.first(line))
    end
  end

  # unterminated code
  defp skip_code("", code), do: {"", code}
  defp skip_code("`" <> rest, code), do: {code <> "`", rest}
  defp skip_code("\\`" <> rest, code), do: skip_code(rest, code <> "\\`")
  defp skip_code(str, code), do: skip_code(String.slice(str, 1..-1), code <> String.first(str))
end
