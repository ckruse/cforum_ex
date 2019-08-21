defmodule Cforum.MarkdownRenderer do
  @moduledoc """
  This is a gen server which creates a long-running nodejs process and
  communicates with it to render JSON documents to HTML or plain text
  """

  use GenServer

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
  def to_html(object, user)

  def to_html(%Cite{} = cite, _user) do
    {:ok, html} = render_doc(cite.cite, "c-#{cite.cite_id}")
    {:safe, html}
  end

  def to_html(%Event{} = event, _user) do
    {:ok, html} = render_doc(event.description, "e-#{event.event_id}")
    {:safe, html}
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

    {:ok, html} = render_doc(content, "m-#{message.message_id}", conf)
    {:safe, html}
  end

  def to_html(%Message{format: "cforum"} = message, conn) do
    message
    |> Cforum.LegacyParser.parse()
    |> to_html(conn)
  end

  def to_html(%PrivMessage{} = message, _user) do
    {:ok, html} = render_doc(message.body, "pm-#{message.priv_message_id}")
    {:safe, html}
  end

  def to_html(%Badge{} = badge, _user) do
    {:ok, html} = render_doc(badge.description, "b-#{badge.badge_id}")
    {:safe, html}
  end

  def to_html(str) when is_bitstring(str) do
    {:ok, html} = render_doc(str, "str")
    {:safe, html}
  end

  def render_doc(markdown, id, config \\ nil) do
    :poolboy.transaction(pool_name(), fn pid -> GenServer.call(pid, {:render_doc, markdown, id, config}) end)
  end

  @spec to_plain(%Message{} | %Cite{}) :: String.t()
  def to_plain(object)

  def to_plain(%Message{format: "cforum"} = message) do
    message
    |> Cforum.LegacyParser.parse()
    |> to_plain()
  end

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

  #
  # server callbacks
  #
  def handle_call({:render_doc, markdown, id, config}, _sender, state) do
    json = Jason.encode!(%{markdown: markdown, id: id, config: config})
    url = Keyword.get(Application.get_env(:cforum, :cfmarkdown, []), :md_url, "http://localhost:4001/markdown")

    retval =
      with %HTTPotion.Response{} = response <-
             HTTPotion.post(url, body: json, headers: ["Content-Type": "application/json"]),
           200 <- response.status_code,
           {:ok, response_json} <- Jason.decode(response.body) do
        response_json
      else
        _ -> nil
      end

    case retval do
      %{"status" => "ok"} ->
        {:reply, {:ok, retval["html"]}, state}

      v when not is_map(v) ->
        {:reply, {:error, :unknown_retval}, state}

      _ ->
        {:reply, {:error, retval["message"]}, state}
    end
  end

  def handle_call({:render_plain, markdown, id}, _sender, state) do
    json = Jason.encode!(%{markdown: markdown, target: "plain", id: id})
    url = Keyword.get(Application.get_env(:cforum, :cfmarkdown, []), :plain_url, "http://localhost:4001/plain")

    retval =
      with %HTTPotion.Response{} = response <-
             HTTPotion.post(url, body: json, headers: ["Content-Type": "application/json"]),
           200 <- response.status_code,
           {:ok, response_json} <- Jason.decode(response.body) do
        response_json
      else
        _ -> nil
      end

    case retval do
      %{"status" => "ok"} ->
        # {:reply, {:ok, to_html(markdown) <> "<br><br>" <> retval["html"]}, proc}
        {:reply, {:ok, retval["html"]}, state}

      v when not is_map(v) ->
        {:reply, {:error, :unknown_retval}, state}

      _ ->
        {:reply, {:error, retval["message"]}, state}
    end
  end
end
