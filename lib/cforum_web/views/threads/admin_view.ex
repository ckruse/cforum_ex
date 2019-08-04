defmodule CforumWeb.Threads.AdminView do
  use CforumWeb, :view

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.ErrorHelpers

  def page_title(action, %{message: msg}) when action in [:move, :do_move],
    do: gettext("Move thread %{subject} by %{author}", subject: msg.subject, author: msg.author)

  def page_title(action, %{message: msg}) when action in [:split, :do_split],
    do: gettext("Split thread at message %{subject} by %{author}", subject: msg.subject, author: msg.author)

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(action, _) when action in [:move, :do_move], do: "move-thread"
  def body_id(action, _) when action in [:split, :do_split], do: "split-thread"

  def body_classes(action, _) when action in [:move, :do_move], do: "move-thread"
  def body_classes(action, _) when action in [:split, :do_split], do: "split-thread"
end
