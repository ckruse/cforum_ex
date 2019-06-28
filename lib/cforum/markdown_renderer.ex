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
  def to_html(%Cite{} = cite, _user) do
    # TODO handle user specific foo
    {:ok, html} = render_doc(cite.cite, "c-#{cite.cite_id}")
    {:safe, html}
    # [{:safe, "<pre>"}, message.content, {:safe, "</pre>"}]
  end

  def to_html(%Event{} = event, _user) do
    # TODO handle user specific foo
    {:ok, html} = render_doc(event.description, "e-#{event.event_id}")
    {:safe, html}
    # [{:safe, "<pre>"}, message.content, {:safe, "</pre>"}]
  end

  def to_html(%Message{format: "markdown"} = message, assigns) do
    # TODO handle user specific foo
    content = Cforum.Messages.content_with_presentational_filters(assigns, message)
    {:ok, html} = render_doc(content, "m-#{message.message_id}")
    {:safe, html}
    # [{:safe, "<pre>"}, message.content, {:safe, "</pre>"}]
  end

  def to_html(%Message{format: "cforum"} = message, assigns) do
    message
    |> Cforum.LegacyParser.parse()
    |> to_html(assigns)
  end

  def to_html(%PrivMessage{} = message, _user) do
    # TODO handle user specific foo
    {:ok, html} = render_doc(message.body, "pm-#{message.priv_message_id}")
    {:safe, html}
    # [{:safe, "<pre>"}, message.content, {:safe, "</pre>"}]
  end

  def to_html(%Badge{} = badge, _user) do
    # TODO handle user specific foo
    {:ok, html} = render_doc(badge.description, "b-#{badge.badge_id}")
    {:safe, html}
  end

  def to_html(str) when is_bitstring(str) do
    {:ok, html} = render_doc(str, "str")
    {:safe, html}
  end

  def render_doc(markdown, id) do
    :poolboy.transaction(pool_name(), fn pid -> GenServer.call(pid, {:render_doc, markdown, id}) end)
  end

  @spec to_plain(%Message{} | %Cite{}) :: String.t()
  def to_plain(%Message{} = message) do
    {:ok, text} = render_plain(message.content, "m-#{message.message_id}")
    text
  end

  def to_plain(%Cite{} = cite) do
    {:ok, text} = render_plain(cite.cite, "c-#{cite.cite_id}")
    text
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
  def handle_call({:render_doc, markdown, id}, _sender, {proc, runs}) do
    {proc, runs} = ensure_proc(proc, runs)
    out = Jason.encode!(%{markdown: markdown, id: id}) <> "\n"
    Proc.send_input(proc, out)
    line = read_line(proc)
    retval = Jason.decode!(line)

    case retval["status"] do
      "ok" ->
        # {:reply, {:ok, to_html(markdown) <> "<br><br>" <> retval["html"]}, proc}
        {:reply, {:ok, retval["html"]}, {proc, runs}}

      _ ->
        Proc.stop(proc)
        {:reply, {:error, retval["message"]}, {nil, 0}}
    end
  end

  def handle_call({:render_plain, markdown, id}, _sender, {proc, runs}) do
    {proc, runs} = ensure_proc(proc, runs)
    out = Jason.encode!(%{markdown: markdown, target: "plain", id: id}) <> "\n"
    Proc.send_input(proc, out)
    line = read_line(proc)
    retval = Jason.decode!(line)

    case retval["status"] do
      "ok" ->
        # {:reply, {:ok, to_html(markdown) <> "<br><br>" <> retval["html"]}, proc}
        {:reply, {:ok, retval["html"]}, {proc, runs}}

      _ ->
        {:reply, {:error, retval["message"]}, {proc, runs}}
    end
  end
end
