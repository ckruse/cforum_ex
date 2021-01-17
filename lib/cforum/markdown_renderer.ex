defmodule Cforum.MarkdownRenderer do
  @moduledoc """
  This is a gen server which creates a long-running nodejs process and
  communicates with it to render JSON documents to HTML or plain text
  """

  use GenServer

  alias Cforum.Cites.Cite
  alias Cforum.Events.Event
  alias Cforum.Messages.Message
  alias Cforum.PrivMessages.PrivMessage
  alias Cforum.Badges.Badge

  @max_runs 1000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init([]) do
    {:ok, {nil, @max_runs}}
  end

  def pool_name(), do: :markdown_renderer_pool

  #
  # client API
  #
  @spec to_html(
          Cite.t() | Event.t() | Message.t() | PrivMessage.t() | Badge.t() | String.t(),
          Plug.Conn.t() | :str,
          :content | :excerpt
        ) :: {:safe, String.t()} | {:error, atom}
  def to_html(object, user, part \\ :content)

  def to_html(%{cite_id: id, cite: content}, _user, _) do
    content
    |> render_doc("c-#{id}")
    |> to_html_with_error_handling()
  end

  def to_html(%{description: content, event_id: id}, _user, _) do
    content
    |> render_doc("e-#{id}")
    |> to_html_with_error_handling()
  end

  def to_html(%Message{format: "html"} = message, _conn, :excerpt),
    do: {:safe, message.excerpt}

  def to_html(%Message{format: "html"} = message, _conn, :content),
    do: {:safe, message.content}

  def to_html(%Message{format: "markdown" <> rest} = message, conn, part) do
    content = Cforum.Messages.content_with_presentational_filters(conn.assigns, message, part)

    target =
      if Cforum.ConfigManager.uconf(conn, "target_blank_for_posting_links") == "yes",
        do: "_blank",
        else: nil

    conf = %{
      "followWhitelist" => String.split(Cforum.ConfigManager.conf(conn, "links_white_list"), ~r/\015\012|\012|\015/),
      "linkTarget" => target,
      "base" => Application.get_env(:cforum, :base_url, "http://localhost/"),
      "html" => rest == "-blog"
    }

    content
    |> render_doc("m-#{message.message_id}", conf)
    |> to_html_with_error_handling()
  end

  def to_html(%Message{format: "cforum"} = message, conn, part) do
    message
    |> Cforum.LegacyParser.parse()
    |> to_html(conn, part)
  end

  def to_html(%{body: content, priv_message_id: id}, _user, _) do
    content
    |> render_doc("pm-#{id}")
    |> to_html_with_error_handling()
  end

  def to_html(%{description: content, badge_id: id}, _user, _) do
    content
    |> render_doc("b-#{id}")
    |> to_html_with_error_handling()
  end

  def to_html(str, :str, _) do
    str
    |> render_doc("str")
    |> to_html_with_error_handling()
  end

  def to_html(str) when is_bitstring(str),
    do: to_html(str, :str)

  defp to_html_with_error_handling({:ok, str}), do: {:safe, str}
  defp to_html_with_error_handling(_), do: System.halt(1)

  def render_doc(markdown, id, config \\ nil) do
    try do
      :poolboy.transaction(pool_name(), fn pid -> GenServer.call(pid, {:render_doc, markdown, id, config}) end)
    catch
      :exit, _ -> System.halt(1)
    end
  end

  @spec to_plain(Message.t() | Cite.t()) :: String.t()
  def to_plain(object)

  def to_plain(%Message{format: "cforum"} = message) do
    message
    |> Cforum.LegacyParser.parse()
    |> to_plain()
  end

  def to_plain(%Message{} = message) do
    message.content
    |> render_plain("m-#{message.message_id}")
    |> to_plain_with_error_handling()
  end

  def to_plain(%Cite{} = cite) do
    cite.cite
    |> render_plain("c-#{cite.cite_id}")
    |> to_plain_with_error_handling()
  end

  defp to_plain_with_error_handling({:ok, str}), do: str
  defp to_plain_with_error_handling(_), do: System.halt(1)

  def render_plain(markdown, id) do
    try do
      :poolboy.transaction(pool_name(), fn pid -> :gen_server.call(pid, {:render_plain, markdown, id}) end)
    catch
      :exit, _ -> System.halt(1)
    end
  end

  defp read_line(data, timeout, terminator) do
    receive do
      {_, {:data, chunk}} ->
        if String.ends_with?(chunk, terminator),
          do: {:ok, data <> String.replace_suffix(chunk, terminator, "")},
          else: read_line(data <> chunk, timeout, terminator)
    after
      timeout ->
        {:error, :timeout}
    end
  end

  defp start_new_proc() do
    conf = Application.get_env(:cforum, :cfmarkdown)

    port =
      if conf[:pwd],
        do: Port.open({:spawn, conf[:cli]}, [:binary, {:cd, conf[:pwd]}]),
        else: Port.open({:spawn, conf[:cli]}, [:binary])

    {:ok, "ok"} = read_line("", 5000, "\n")
    port
  end

  defp ensure_port(nil, _), do: {start_new_proc(), @max_runs}

  defp ensure_port(port, runs) do
    if runs > 0 do
      {port, runs - 1}
    else
      Port.close(port)
      {start_new_proc(), @max_runs}
    end
  end

  # defp read_line(proc) do
  #   Enum.reduce_while(proc.out, "", fn line, acc ->
  #     if Regex.match?(~r/--eof--$/, line),
  #       do: {:halt, acc <> Regex.replace(~r/--eof--$/, line, "")},
  #       else: {:cont, acc <> line}
  #   end)
  # end

  defp send_and_receive(port, out) do
    Port.command(port, out)

    with {:ok, line} <- read_line("", 1000, "--eof--\n"),
         {:ok, json} <- Jason.decode(line) do
      json
    end
  end

  defp response(%{"status" => "ok", "html" => html}, port, runs),
    do: {:reply, {:ok, html}, {port, runs}}

  defp response(v, port, _) when not is_map(v) do
    Port.close(port)
    {:reply, {:error, :unknown_retval}, {nil, 0}}
  end

  defp response(v, port, _) do
    Port.close(port)
    {:reply, {:error, v["message"]}, {nil, 0}}
  end

  #
  # server callbacks
  #
  def handle_call({:render_doc, markdown, id, config}, _sender, {port, runs}) do
    if Application.get_env(:cforum, :environment) == :test do
      {:reply, {:ok, markdown}, {port, runs + 1}}
    else
      {port, runs} = ensure_port(port, runs)
      out = Jason.encode!(%{markdown: markdown, id: id, config: config}) <> "\n"

      port
      |> send_and_receive(out)
      |> response(port, runs)
    end
  end

  def handle_call({:render_plain, markdown, id}, _sender, {port, runs}) do
    if Application.get_env(:cforum, :environment) == :test do
      {:reply, {:ok, markdown}, {port, runs + 1}}
    else
      {port, runs} = ensure_port(port, runs)
      out = Jason.encode!(%{markdown: markdown, target: "plain", id: id}) <> "\n"

      port
      |> send_and_receive(out)
      |> response(port, runs)
    end
  end

  def handle_info({:EXIT, port, _reason}, _state) do
    Port.close(port)
    {:noreply, {nil, 0}}
  end

  def terminate(_, {port, _runs}) do
    if port,
      do: Port.close(port)

    {nil, 0}
  end
end
