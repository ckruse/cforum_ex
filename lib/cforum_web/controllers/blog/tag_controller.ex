defmodule CforumWeb.Blog.TagController do
  use CforumWeb, :controller

  alias Cforum.Threads.Thread
  alias Cforum.Messages.Message
  alias Cforum.MessagesTags
  alias Cforum.Tags

  alias CforumWeb.Paginator

  def show(conn, %{"tag" => tag} = params) do
    tag = Tags.get_tag_by_slug!(tag)

    count = MessagesTags.count_messages_for_tag([conn.assigns[:current_forum]], tag)
    paging = Paginator.paginate(count, page: params["p"])
    entries = MessagesTags.list_messages_for_tag([conn.assigns[:current_forum]], tag, limit: paging.params)

    messages =
      Enum.map(entries, fn msg ->
        thread = %Thread{msg.thread | message: msg}
        %Message{msg | thread: thread}
      end)

    render(conn, "show.html", tag: tag, messages: messages, page: paging)
  end

  def allowed?(_, _, _), do: true
end
