defmodule CforumWeb.ThreadView do
  use CforumWeb, :view

  alias Cforum.Forums.Thread

  defp archived_class(classes, %Thread{archived: true}), do: [classes | ["archived"]]
  defp archived_class(classes, _), do: classes

  defp sticky_class(classes, %Thread{sticky: true}), do: [classes | ["sticky"]]
  defp sticky_class(classes, _), do: classes

  def thread_classes(thread) do
    thread.attribs[:classes]
    |> archived_class(thread)
    |> sticky_class(thread)
    |> Enum.join(" ")
  end
end
