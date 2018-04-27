defmodule CforumWeb.Views.Helpers.Path do
  @moduledoc "Contains all path helpers"

  alias Cforum.Forums.Message
  alias Cforum.Forums.Thread
  alias Cforum.Forums.Forum

  import CforumWeb.Router.Helpers

  def forum_slug(forum, with_all \\ true)
  def forum_slug(nil, true), do: "all"
  def forum_slug(nil, _), do: nil
  def forum_slug(%Forum{} = forum, _), do: forum.slug
  def forum_slug(slug, _), do: slug

  def forum_path(conn, :index, slug, params \\ []),
    do: "#{root_path(conn, :index)}#{forum_slug(slug)}#{encode_query_string(params)}"

  def forum_url(conn, :index, slug, params \\ []),
    do: "#{root_url(conn, :index)}#{forum_slug(slug)}#{encode_query_string(params)}"

  def archive_path(conn, action, forum, year_or_params \\ [], params \\ [])

  def archive_path(conn, :years, forum, params, _),
    do: "#{forum_path(conn, :index, forum)}/archive#{encode_query_string(params)}"

  def archive_path(conn, :months, forum, {{year, _, _}, _}, params),
    do: "#{forum_path(conn, :index, forum)}/#{year}#{encode_query_string(params)}"

  def archive_path(conn, :threads, forum, month, params) do
    part = month |> Timex.lformat!("%Y/%b", "en", :strftime) |> String.downcase()
    "#{forum_path(conn, :index, forum)}/#{part}#{encode_query_string(params)}"
  end

  @doc """
  Generates URL path part to the thread (w/o message part). Mainly
  used internally, but in case you need it, it is there. Waiting
  patiently. ;-)

  ## Parameters

  - `conn` - the current `%Plug.Conn{}` struct
  - `action` - the request action, e.g. `:show`
  - `resource` - the thread to generate the path to, the forum or `"/all"` (for :new)
  - `params` - an optional query string as a dict
  """
  def thread_path(conn, action, resource, params \\ [])

  def thread_path(conn, :show, %Thread{} = thread, params) do
    root = forum_path(conn, :index, thread.forum.slug)
    "#{root}#{thread.slug}#{encode_query_string(params)}"
  end

  def thread_path(conn, :new, %Forum{} = forum, params), do: thread_path(conn, :new, forum.slug, params)

  def thread_path(conn, :new, forum, params) do
    root = forum_path(conn, :index, forum)
    "#{root}/new#{encode_query_string(params)}"
  end

  defp to_param(int) when is_integer(int), do: Integer.to_string(int)
  defp to_param(bin) when is_binary(bin), do: bin
  defp to_param(false), do: "false"
  defp to_param(true), do: "true"
  defp to_param(data), do: Phoenix.Param.to_param(data)

  defp encode_query_string([]), do: ""

  defp encode_query_string(query) do
    case Plug.Conn.Query.encode(query, &to_param/1) do
      "" -> ""
      qstr -> "?" <> qstr
    end
  end

  defp int_message_path(conn, thread, message, params \\ []),
    do: "#{thread_path(conn, :show, thread)}/#{message.message_id}#{encode_query_string(params)}"

  @doc """
  Generates URL path part to the `message`. Uses the thread from the
  `message` struct.

  ## Parameters

  - `conn` - the current `%Plug.Conn{}` struct
  - `thread` - the thread of the message
  - `message` - the message to generate the path to
  - `action` - the action for the path, defaults to `:show`
  - `params` - an optional query string as a dict
  """
  def message_path(conn, action, thread, message, params \\ [])

  def message_path(conn, :show, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg, params)}#m#{msg.message_id}"

  def message_path(conn, :new, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/new#{encode_query_string(params)}"

  def subscribe_message_path(conn, %Thread{} = thread, %Message{} = msg, params \\ []),
    do: "#{int_message_path(conn, thread, msg)}/subscribe#{encode_query_string(params)}"

  def unsubscribe_message_path(conn, %Thread{} = thread, %Message{} = msg, params \\ []),
    do: "#{int_message_path(conn, thread, msg)}/unsubscribe#{encode_query_string(params)}"

  def interesting_message_path(conn, %Thread{} = thread, %Message{} = msg, params \\ []),
    do: "#{int_message_path(conn, thread, msg)}/interesting#{encode_query_string(params)}"

  def boring_message_path(conn, %Thread{} = thread, %Message{} = msg, params \\ []),
    do: "#{int_message_path(conn, thread, msg)}/boring#{encode_query_string(params)}"

  def mark_read_path(conn, :mark_read, %Thread{} = thread, params \\ []),
    do: "#{thread_path(conn, :show, thread)}/mark-read#{encode_query_string(params)}"

  def invisible_thread_path(conn, action, thread \\ nil, params \\ [])

  def invisible_thread_path(conn, :hide, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread)}/hide#{encode_query_string(params)}"

  def invisible_thread_path(conn, :unhide, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread)}/unhide#{encode_query_string(params)}"

  def invisible_thread_path(conn, :index, nil, params),
    do: "#{root_path(conn, :index)}invisible#{encode_query_string(params)}"

  def open_thread_path(conn, %Thread{} = thread, params \\ []),
    do: "#{thread_path(conn, :show, thread)}/open#{encode_query_string(params)}"

  def close_thread_path(conn, %Thread{} = thread, params \\ []),
    do: "#{thread_path(conn, :show, thread)}/close#{encode_query_string(params)}"

  def mail_thread_path(conn, :show, pm, params \\ []),
    do: "#{root_path(conn, :index)}mails/#{pm.thread_id}#{encode_query_string(params)}#pm#{pm.priv_message_id}"
end
