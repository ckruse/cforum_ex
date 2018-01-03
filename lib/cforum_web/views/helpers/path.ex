defmodule CforumWeb.Views.Helpers.Path do
  @moduledoc "Contains all path helpers"

  alias Cforum.Forums.Message
  alias Cforum.Forums.Thread
  alias Cforum.Forums.Forum

  import CforumWeb.Router.Helpers

  def forum_slug(nil), do: "all"
  def forum_slug(%Forum{} = forum), do: forum.slug
  def forum_slug(slug), do: slug

  def forum_path(conn, :index, slug, params \\ []),
    do: "#{root_path(conn, :index)}#{forum_slug(slug)}#{encode_query_string(params)}"

  def forum_url(conn, :index, slug, params \\ []),
    do: "#{root_url(conn, :index)}#{forum_slug(slug)}#{encode_query_string(params)}"

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
end
