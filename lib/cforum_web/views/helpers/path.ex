defmodule CforumWeb.Views.Helpers.Path do
  alias Cforum.Forums.Message
  alias Cforum.Forums.Thread

  import CforumWeb.Router.Helpers

  def thread_path(conn, %Thread{} = thread) do
    root = thread_path(conn, :index, thread.forum.slug)
    "#{root}#{thread.slug}"
  end

  def message_path(conn, %Message{} = msg), do: message_path(conn, msg.thread, msg)
  def message_path(conn, %Thread{} = thread, %Message{} = msg) do
    "#{thread_path(conn, thread)}/#{msg.message_id}#m#{msg.message_id}"
  end
end
