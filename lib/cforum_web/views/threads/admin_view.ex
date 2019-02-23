defmodule CforumWeb.Threads.AdminView do
  use CforumWeb, :view

  def page_title(action, %{message: msg}) when action in [:move, :do_move],
    do: gettext("Move thread %{subject} by %{author}", subject: msg.subject, author: msg.author)

  def page_heading(action, assigns), do: page_title(action, assigns)
  def body_id(action, _) when action in [:move, :do_move], do: "move-thread"
  def body_classes(action, _) when action in [:move, :do_move], do: "move-thread"
end
