defmodule Cforum.Web.MessageView do
  use Cforum.Web, :view

  alias Cforum.Forums.Thread
  alias Cforum.Forums.Message

  def first_class(classes, %{first: true}), do: [classes | ["first"]]
  def first_class(classes, _), do: classes

  def deleted_class(classes, %Message{deleted: true}), do: [classes | ["deleted"]]
  def deleted_class(classes, _), do: classes

  def message_classes(classes, %Message{attribs: %{classes: msg_classes}}), do: [classes | [msg_classes]]
  def message_classes(classes, _), do: classes

  def accepted_class(classes, %Thread{accepted: []}, _), do: classes
  def accepted_class(classes, thread, message) do
    classes = if thread.message.message_id == message.message_id, do: [classes | ["has-accepted-answer"]], else: classes
    if Message.accepted?(message), do: [classes | ["accepted-answer"]], else: classes
  end

  # TODO
  def close_vote_class(classes, _), do: classes
  def open_vote_class(classes, _), do: classes

  def header_classes(thread, message, assigns) do
    first_class([], assigns)
    |> deleted_class(message)
    |> message_classes(message)
    |> accepted_class(thread, message)
    |> close_vote_class(message)
    |> open_vote_class(message)
    |> Enum.join
  end

  def message_tree(conn, thread, parent, messages, opts \\ [show_icons: true]) do
    parts = Enum.map(messages, fn(msg) ->
      # TODO classes
      subtree = if Cforum.Web.Helpers.blank?(msg.messages), do: "", else: message_tree(conn, thread, msg, msg.messages)
      [{:safe, "<li>"} |
       [ render(Cforum.Web.MessageView, "header.html", Keyword.merge([conn: conn, thread: thread, parent: parent, message: msg], opts)) |
         [subtree | {:safe, "</li>"}] ] ]
    end)

    [{:safe, "<ol>"} | [parts | {:safe, "</ol>"}]]
  end

  def message_date_format(conn, opts) do
    if opts[:tree] do
      date_format(conn, "date_format_index") # TODO+ day_changed_key(message))
    else
      date_format(conn, "date_format_post")
    end
  end
end
