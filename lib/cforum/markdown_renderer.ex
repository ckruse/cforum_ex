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
  # alias Cforum.Accounts.User

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init([]) do
    md_dir = Application.app_dir(:cforum, "priv")

    proc =
      Porcelain.spawn_shell(
        "node #{md_dir}/cf_mdparser/cf_mdparser.js",
        in: :receive,
        out: :stream
      )

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

  def render_doc(markdown) do
    :poolboy.transaction(pool_name(), fn pid -> :gen_server.call(pid, {:render_doc, markdown}) end)
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
        {:reply, {:ok, retval["html"]}, proc}

      _ ->
        {:reply, {:error, retval["message"]}, proc}
    end
  end
end
