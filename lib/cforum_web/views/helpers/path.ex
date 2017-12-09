defmodule CforumWeb.Views.Helpers.Path do
  @moduledoc "Contains all path helpers"

  alias Cforum.Forums.Message
  alias Cforum.Forums.Thread

  import CforumWeb.Router.Helpers

  @doc """
  Generates URL path part to the thread (w/o message part). Mainly
  used internally, but in case you need it, it is there. Waiting
  patiently. ;-)

  ## Parameters

  - `conn` - the current `%Plug.Conn{}` struct
  - `thread` - the thread to generate the path to
  - `params` - an optional query string as a dict
  """
  def thread_path(conn, %Thread{} = thread, params \\ []) do
    root = forum_path(conn, :index, thread.forum.slug)
    "#{root}#{thread.slug}#{encode_query_string(params)}"
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
    do: "#{thread_path(conn, thread)}/#{message.message_id}#{encode_query_string(params)}"

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
  def message_path(conn, thread, message, action \\ :show, params \\ [])

  def message_path(conn, %Thread{} = thread, %Message{} = msg, :show, params),
    do: "#{int_message_path(conn, thread, msg, params)}#m#{msg.message_id}"

  def message_path(conn, %Thread{} = thread, %Message{} = msg, :new, params),
    do: "#{int_message_path(conn, thread, msg)}/new#{encode_query_string(params)}"
end
