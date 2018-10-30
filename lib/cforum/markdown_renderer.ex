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
  alias Cforum.Forums.Message
  alias Cforum.Accounts.PrivMessage
  alias Cforum.Accounts.Badge
  # alias Cforum.Accounts.User

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init([]) do
    conf = Application.get_env(:cforum, :cfmarkdown)

    cli =
      if conf[:pwd],
        do: "cd #{conf[:pwd]} && #{conf[:cli]}",
        else: conf[:cli]

    proc = Porcelain.spawn_shell(cli, in: :receive, out: :stream)

    {:ok, proc}
  end

  def pool_name(), do: :markdown_renderer_pool

  #
  # client API
  #
  def to_html(%Cite{} = cite, _user) do
    # TODO handle user specific foo
    {:ok, html} = render_doc(cite.cite)
    {:safe, html}
    # [{:safe, "<pre>"}, message.content, {:safe, "</pre>"}]
  end

  def to_html(%Event{} = event, _user) do
    # TODO handle user specific foo
    {:ok, html} = render_doc(event.description)
    {:safe, html}
    # [{:safe, "<pre>"}, message.content, {:safe, "</pre>"}]
  end

  def to_html(%Message{} = message, _user) do
    # TODO handle user specific foo
    {:ok, html} = render_doc(message.content)
    {:safe, html}
    # [{:safe, "<pre>"}, message.content, {:safe, "</pre>"}]
  end

  def to_html(%PrivMessage{} = message, _user) do
    # TODO handle user specific foo
    {:ok, html} = render_doc(message.body)
    {:safe, html}
    # [{:safe, "<pre>"}, message.content, {:safe, "</pre>"}]
  end

  def to_html(%Badge{} = badge, _user) do
    # TODO handle user specific foo
    {:ok, html} = render_doc(badge.description)
    {:safe, html}
  end

  def render_doc(markdown) do
    :poolboy.transaction(pool_name(), fn pid -> :gen_server.call(pid, {:render_doc, markdown}) end)
  end

  @spec to_plain(%Message{}) :: String.t()
  def to_plain(%Message{} = message) do
    {:ok, html} = render_plain(message.content)
    html
  end

  def render_plain(markdown) do
    :poolboy.transaction(pool_name(), fn pid -> :gen_server.call(pid, {:render_plain, markdown}) end)
  end

  #
  # server callbacks
  #
  def handle_call({:render_doc, markdown}, _sender, proc) do
    out = Poison.encode!(%{markdown: markdown}) <> "\n"
    Proc.send_input(proc, out)
    [line] = Enum.take(proc.out, 1)
    retval = Poison.decode!(line)

    case retval["status"] do
      "ok" ->
        # {:reply, {:ok, to_html(markdown) <> "<br><br>" <> retval["html"]}, proc}
        {:reply, {:ok, retval["html"]}, proc}

      _ ->
        {:reply, {:error, retval["message"]}, proc}
    end
  end

  def handle_call({:render_plain, markdown}, _sender, proc) do
    out = Poison.encode!(%{markdown: markdown, target: "plain"}) <> "\n"
    Proc.send_input(proc, out)
    [line] = Enum.take(proc.out, 1)
    retval = Poison.decode!(line)

    case retval["status"] do
      "ok" ->
        # {:reply, {:ok, to_html(markdown) <> "<br><br>" <> retval["html"]}, proc}
        {:reply, {:ok, retval["html"]}, proc}

      _ ->
        {:reply, {:error, retval["message"]}, proc}
    end
  end

  def to_html(s) do
    s
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\n", "<br>")
  end
end
