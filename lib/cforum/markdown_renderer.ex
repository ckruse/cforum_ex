defmodule Cforum.MarkdownRenderer do
  @moduledoc """
  This is a gen server which creates a long-running nodejs process and
  communicates with it to render JSON documents to HTML or plain text
  """

  use GenServer

  alias Porcelain.Process, as: Proc
  # alias Porcelain.Result

  alias Cforum.Cites.Cite
  alias Cforum.Events.Event
  alias Cforum.Messages.Message
  alias Cforum.Accounts.PrivMessage
  alias Cforum.Accounts.Badge
  # alias Cforum.Accounts.User

  @max_runs 10_000

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
  def to_html(object, user, tries \\ 0)
  def to_html(_, _, tries) when tries >= 5, do: {:error, :not_possible}

  def to_html(%Cite{} = cite, user, tries) do
    case render_doc(cite.cite, "c-#{cite.cite_id}") do
      {:ok, html} ->
        {:safe, html}

      _ ->
        Process.sleep(50)
        to_html(cite, user, tries + 1)
    end
  end

  def to_html(%Event{} = event, user, tries) do
    case render_doc(event.description, "e-#{event.event_id}") do
      {:ok, html} ->
        {:safe, html}

      _ ->
        Process.sleep(50)
        to_html(event, user, tries + 1)
    end
  end

  def to_html(%Message{format: "markdown"} = message, conn, tries) do
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

    case render_doc(content, "m-#{message.message_id}", conf) do
      {:ok, html} ->
        {:safe, html}

      _ ->
        Process.sleep(50)
        to_html(message, conn, tries + 1)
    end
  end

  def to_html(%Message{format: "cforum"} = message, conn, tries) do
    message
    |> Cforum.LegacyParser.parse()
    |> to_html(conn, tries)
  end

  def to_html(%PrivMessage{} = message, user, tries) do
    case render_doc(message.body, "pm-#{message.priv_message_id}") do
      {:ok, html} ->
        {:safe, html}

      _ ->
        Process.sleep(50)
        to_html(message, user, tries + 1)
    end
  end

  def to_html(%Badge{} = badge, user, tries) do
    case render_doc(badge.description, "b-#{badge.badge_id}") do
      {:ok, html} ->
        {:safe, html}

      _ ->
        Process.sleep(50)
        to_html(badge, user, tries + 1)
    end
  end

  def to_html(str, :str, tries) do
    case render_doc(str, "str") do
      {:ok, html} ->
        {:safe, html}

      _ ->
        Process.sleep(50)
        to_html(str, :str, tries + 1)
    end
  end

  def to_html(str) when is_bitstring(str), do: to_html(str, :str)

  def render_doc(markdown, id, config \\ nil) do
    :poolboy.transaction(pool_name(), fn pid -> GenServer.call(pid, {:render_doc, markdown, id, config}) end)
  end

  @spec to_plain(%Message{} | %Cite{}) :: String.t()
  def to_plain(object, tries \\ 0)
  def to_plain(_, tries) when tries >= 5, do: {:error, :not_possible}

  def to_plain(%Message{format: "cforum"} = message, tries) do
    message
    |> Cforum.LegacyParser.parse()
    |> to_plain(tries)
  end

  def to_plain(%Message{} = message, tries) do
    case render_plain(message.content, "m-#{message.message_id}") do
      {:ok, text} ->
        text

      _ ->
        Process.sleep(50)
        to_plain(message, tries + 1)
    end
  end

  def to_plain(%Cite{} = cite, tries) do
    case render_plain(cite.cite, "c-#{cite.cite_id}") do
      {:ok, text} ->
        text

      _ ->
        Process.sleep(50)
        to_plain(cite, tries + 1)
    end
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

    Porcelain.spawn_shell(cli, in: :receive, out: :stream)
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

  #
  # server callbacks
  #
  def handle_call({:render_doc, markdown, id, config}, _sender, {proc, runs}) do
    {proc, runs} = ensure_proc(proc, runs)
    out = Jason.encode!(%{markdown: markdown, id: id, config: config}) <> "\n"

    task =
      Task.async(fn ->
        Proc.send_input(proc, out)
        line = read_line(proc)

        with {:ok, json} <- Jason.decode(line) do
          json
        end
      end)

    retval =
      try do
        Task.await(task, 1000)
      catch
        _, _ ->
          if Process.alive?(task.pid),
            do: Process.exit(task.pid, :kill)

          nil
      end

    case retval do
      %{"status" => "ok"} ->
        # {:reply, {:ok, to_html(markdown) <> "<br><br>" <> retval["html"]}, proc}
        {:reply, {:ok, retval["html"]}, {proc, runs}}

      v when not is_map(v) ->
        {:reply, {:error, :unknown_retval}, {proc, runs}}

      _ ->
        Proc.stop(proc)
        {:reply, {:error, retval["message"]}, {nil, 0}}
    end
  end

  def handle_call({:render_plain, markdown, id}, _sender, {proc, runs}) do
    {proc, runs} = ensure_proc(proc, runs)
    out = Jason.encode!(%{markdown: markdown, target: "plain", id: id}) <> "\n"
    # Proc.send_input(proc, out)
    # line = read_line(proc)
    # retval = Jason.decode!(line)

    task =
      Task.async(fn ->
        Proc.send_input(proc, out)
        line = read_line(proc)

        with {:ok, json} <- Jason.decode(line) do
          json
        end
      end)

    retval =
      try do
        Task.await(task, 1000)
      catch
        _, _ ->
          if Process.alive?(task.pid),
            do: Process.exit(task.pid, :kill)

          nil
      end

    case retval do
      %{"status" => "ok"} ->
        # {:reply, {:ok, to_html(markdown) <> "<br><br>" <> retval["html"]}, proc}
        {:reply, {:ok, retval["html"]}, {proc, runs}}

      v when not is_map(v) ->
        {:reply, {:error, :unknown_retval}, {proc, runs}}

      _ ->
        {:reply, {:error, retval["message"]}, {proc, runs}}
    end
  end
end
