defmodule Cforum.MarkdownRenderer do
  @moduledoc """
  This is a gen server which creates a long-running nodejs process and
  communicates with it to render JSON documents to HTML or plain text
  """

  use GenServer

  alias Porcelain.Process, as: Proc

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
          Plug.Conn.t() | :str
        ) :: {:safe, String.t()} | {:error, atom}
  def to_html(object, user)

  def to_html(%{cite_id: id, cite: content}, _user) do
    with {:ok, html} <- render_doc(content, "c-#{id}"),
         do: {:safe, html}
  end

  def to_html(%{description: content, event_id: id}, _user) do
    with {:ok, html} <- render_doc(content, "e-#{id}"),
         do: {:safe, html}
  end

  def to_html(%Message{format: "markdown"} = message, conn) do
    content = Cforum.Messages.content_with_presentational_filters(conn.assigns, message)

    target =
      if Cforum.ConfigManager.uconf(conn, "target_blank_for_posting_links") == "yes",
        do: "_blank",
        else: nil

    conf = %{
      "followWhitelist" => String.split(Cforum.ConfigManager.conf(conn, "links_white_list"), ~r/\015\012|\012|\015/),
      "linkTarget" => target,
      "base" => Application.get_env(:cforum, :base_url, "http://localhost/")
    }

    with {:ok, html} <- render_doc(content, "m-#{message.message_id}", conf),
         do: {:safe, html}
  end

  def to_html(%Message{format: "cforum"} = message, conn) do
    message
    |> Cforum.LegacyParser.parse()
    |> to_html(conn)
  end

  def to_html(%{body: content, priv_message_id: id}, _user) do
    with {:ok, html} <- render_doc(content, "pm-#{id}"),
         do: {:safe, html}
  end

  def to_html(%{description: content, badge_id: id}, _user) do
    with {:ok, html} <- render_doc(content, "b-#{id}"),
         do: {:safe, html}
  end

  def to_html(str, :str) do
    with {:ok, html} <- render_doc(str, "str"),
         do: {:safe, html}
  end

  def to_html(str) when is_bitstring(str), do: to_html(str, :str)

  def render_doc(markdown, id, config \\ nil) do
    Appsignal.Transaction.set_sample_data("environment", %{id: id, config: config})
    :poolboy.transaction(pool_name(), fn pid -> GenServer.call(pid, {:render_doc, markdown, id, config}) end)
  end

  @spec to_plain(Message.t() | Cite.t()) :: String.t()
  def to_plain(object)

  def to_plain(%Message{format: "cforum"} = message) do
    message
    |> Cforum.LegacyParser.parse()
    |> to_plain()
  end

  def to_plain(%Message{} = message) do
    with {:ok, text} <- render_plain(message.content, "m-#{message.message_id}"),
         do: text
  end

  def to_plain(%Cite{} = cite) do
    with {:ok, text} <- render_plain(cite.cite, "c-#{cite.cite_id}"),
         do: text
  end

  def render_plain(markdown, id) do
    :poolboy.transaction(pool_name(), fn pid -> :gen_server.call(pid, {:render_plain, markdown, id}) end)
  end

  defp start_new_proc() do
    conf = Application.get_env(:cforum, :cfmarkdown)

    cli =
      if conf[:pwd],
        do: "cd #{conf[:pwd]} && #{conf[:cli]}",
        else: conf[:cli]

    proc = Porcelain.spawn_shell(cli, in: :receive, out: :stream)
    ["ok\n"] = Enum.take(proc.out, 1)
    proc
  end

  defp ensure_proc(nil, _), do: {start_new_proc(), @max_runs}

  defp ensure_proc(proc, runs) do
    if Proc.alive?(proc) && runs > 0 do
      {proc, runs - 1}
    else
      Proc.stop(proc)
      {start_new_proc(), @max_runs}
    end
  end

  defp read_line(proc) do
    Enum.reduce_while(proc.out, "", fn line, acc ->
      if Regex.match?(~r/--eof--$/, line),
        do: {:halt, acc <> Regex.replace(~r/--eof--$/, line, "")},
        else: {:cont, acc <> line}
    end)
  end

  defp send_and_receive(proc, out) do
    task =
      Task.async(fn ->
        Proc.send_input(proc, out)
        line = read_line(proc)

        with {:ok, json} <- Jason.decode(line) do
          json
        end
      end)

    try do
      Task.await(task, 1000)
    catch
      :exit, {:timeout, _} ->
        Task.shutdown(task, :brutal_kill)
        nil
    end
  end

  defp response(%{"status" => "ok", "html" => html}, proc, runs),
    do: {:reply, {:ok, html}, {proc, runs}}

  defp response(v, proc, _) when not is_map(v) do
    Proc.stop(proc)
    {:reply, {:error, :unknown_retval}, {nil, 0}}
  end

  defp response(v, proc, _) do
    Proc.stop(proc)
    {:reply, {:error, v["message"]}, {nil, 0}}
  end

  #
  # server callbacks
  #
  def handle_call({:render_doc, markdown, id, config}, _sender, {proc, runs}) do
    if Application.get_env(:cforum, :environment) == :test do
      {:reply, {:ok, markdown}, {proc, runs + 1}}
    else
      {proc, runs} = ensure_proc(proc, runs)
      out = Jason.encode!(%{markdown: markdown, id: id, config: config}) <> "\n"

      proc
      |> send_and_receive(out)
      |> response(proc, runs)
    end
  end

  def handle_call({:render_plain, markdown, id}, _sender, {proc, runs}) do
    if Application.get_env(:cforum, :environment) == :test do
      {:reply, {:ok, markdown}, {proc, runs + 1}}
    else
      {proc, runs} = ensure_proc(proc, runs)
      out = Jason.encode!(%{markdown: markdown, target: "plain", id: id}) <> "\n"

      proc
      |> send_and_receive(out)
      |> response(proc, runs)
    end
  end

  def terminate(_, {proc, _runs}) do
    if proc,
      do: Proc.stop(proc)

    {nil, 0}
  end
end
