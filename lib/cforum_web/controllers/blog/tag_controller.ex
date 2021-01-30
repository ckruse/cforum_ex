defmodule CforumWeb.Blog.TagController do
  use CforumWeb, :controller

  alias Cforum.Threads.Thread
  alias Cforum.Messages.Message
  alias Cforum.MessagesTags
  alias Cforum.Tags
  alias Cforum.Abilities

  alias CforumWeb.Paginator

  def index(conn, _) do
    tags = Tags.list_tags([conn.assigns[:current_forum]])

    {min_cnt, max_cnt} =
      Enum.reduce(tags, {-1, 0}, fn
        tag, {-1, max_cnt} ->
          {tag.num_messages, max(max_cnt, tag.num_messages)}

        tag, {min_cnt, max_cnt} ->
          {min(min_cnt, tag.num_messages), max(max_cnt, tag.num_messages)}
      end)

    render(conn, "index.html", tags: tags, min_cnt: min_cnt, max_cnt: max_cnt)
  end

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

  def allowed?(conn, _, _), do: Abilities.access_forum?(conn)
end
