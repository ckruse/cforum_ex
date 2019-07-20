defmodule CforumWeb.Views.Helpers.Feeds do
  alias CforumWeb.Views.Helpers.Path
  alias Cforum.Messages.Message

  import CforumWeb.Gettext

  def atom_feed_head_for_thread(conn, thread, messages) do
    forum = conn.assigns[:current_forum]
    message = List.first(thread.sorted_messages)

    {:feed, %{"xml:lang" => Gettext.get_locale(CforumWeb.Gettext), "xmlns" => "http://www.w3.org/2005/Atom"},
     [
       {:id, nil, "tag:forum.selfhtml.org,2005:/self"},
       {:link, %{"rel" => "alternate", "type" => "text/html", "href" => Path.message_url(conn, :show, thread, message)},
        []},
       {:link, %{"rel" => "self", "type" => "application/atom+xml", "href" => Path.thread_url(conn, :atom, thread)},
        []},
       {:title, nil, "#{message.subject} – #{CforumWeb.LayoutView.forum_name(forum)}"},
       {:updated, nil, Timex.lformat!(thread.latest_message, "{RFC3339z}", "en")},
       messages
     ]}
  end

  def atom_feed_head(conn, threads, last_updated) do
    forum = conn.assigns[:current_forum]

    {:feed, %{"xml:lang" => Gettext.get_locale(CforumWeb.Gettext), "xmlns" => "http://www.w3.org/2005/Atom"},
     [
       {:id, nil, "tag:forum.selfhtml.org,2005:/self"},
       {:link, %{"rel" => "alternate", "type" => "text/html", "href" => Path.forum_url(conn, :index, forum)}, []},
       {:link, %{"rel" => "self", "type" => "application/atom+xml", "href" => Path.forum_url(conn, :atom, forum)}, []},
       {:title, nil, CforumWeb.LayoutView.forum_name(forum)},
       {:updated, nil, Timex.lformat!(last_updated, "{RFC3339z}", "en")},
       threads
     ]}
  end

  def atom_feed_message(conn, thread, message) do
    {:safe, html} = Cforum.MarkdownRenderer.to_html(message, conn)

    {:entry, nil,
     [
       {:id, nil, Path.message_url(conn, :show, thread, message)},
       atom_author(message),
       {:published, nil, Timex.lformat!(message.created_at, "{RFC3339z}", "en")},
       {:updated, nil, Timex.lformat!(message.updated_at, "{RFC3339z}", "en")},
       {:link,
        %{
          "rel" => "alternate",
          "type" => "text/html",
          "href" => Path.message_url(conn, :show, thread, message)
        }, []},
       {:title, nil, message.subject},
       {:content, %{"type" => "html"}, html}
     ]}
  end

  def atom_feed_thread(conn, thread) do
    {:safe, html} = Cforum.MarkdownRenderer.to_html(thread.message, conn)

    {:entry, nil,
     [
       {:id, nil, Path.thread_url(conn, :show, thread)},
       atom_author(thread.message),
       {:published, nil, Timex.lformat!(thread.created_at, "{RFC3339z}", "en")},
       {:updated, nil, Timex.lformat!(thread.updated_at, "{RFC3339z}", "en")},
       {:link,
        %{
          "rel" => "alternate",
          "type" => "text/html",
          "href" => Path.message_url(conn, :show, thread, thread.message)
        }, []},
       {:title, nil, thread.message.subject},
       {:content, %{"type" => "html"}, html}
     ]}
  end

  def atom_author(msg) do
    infos =
      [{:name, nil, msg.author}]
      |> atom_maybe_add_email(msg)
      |> atom_maybe_add_url(msg)

    {:author, nil, infos}
  end

  defp atom_maybe_add_email(children, %Message{email: email}) when not is_nil(email) and email != "",
    do: [children | [{:email, nil, email}]]

  defp atom_maybe_add_email(children, _), do: children

  defp atom_maybe_add_url(children, %Message{homepage: hp}) when not is_nil(hp) and hp != "",
    do: [children | [{:uri, nil, hp}]]

  defp atom_maybe_add_url(children, _), do: children

  def rss_feed_head(conn, threads) do
    forum = conn.assigns[:current_forum]

    desc =
      if forum && forum.description,
        do: forum.description,
        else: gettext("A forum as a completion to the wiki and the weblog")

    {:rss, %{"version" => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom"},
     [
       {:channel, nil,
        [
          {:title, nil, CforumWeb.LayoutView.forum_name(forum)},
          {:description, nil, desc},
          {:link, nil, Path.forum_url(conn, :index, forum)},
          {"atom:link",
           %{"rel" => "self", "type" => "application/rss+xml", "href" => Path.forum_url(conn, :rss, forum)}, []},
          threads
        ]}
     ]}
  end

  def rss_feed_head_for_thread(conn, thread, messages) do
    forum = conn.assigns[:current_forum]
    message = List.first(thread.sorted_messages)

    desc =
      if forum && forum.description,
        do: forum.description,
        else: gettext("A forum as a completion to the wiki and the weblog")

    {:rss, %{"version" => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom"},
     [
       {:channel, nil,
        [
          {:title, nil, "#{message.subject} – #{CforumWeb.LayoutView.forum_name(forum)}"},
          {:description, nil, desc},
          {:link, nil, Path.forum_url(conn, :index, forum)},
          {"atom:link",
           %{"rel" => "self", "type" => "application/rss+xml", "href" => Path.thread_url(conn, :rss, thread)}, []},
          messages
        ]}
     ]}
  end

  def rss_feed_thread(conn, thread) do
    {:safe, html} = Cforum.MarkdownRenderer.to_html(thread.message, conn)

    {:item, nil,
     [
       {:title, nil, thread.message.subject},
       {:pubDate, nil, Timex.lformat!(thread.message.created_at, "{RFC822z}", "en")},
       {:link, nil, Path.message_url(conn, :show, thread, thread.message)},
       {:guid, nil, Path.message_url(conn, :show, thread, thread.message)},
       {:description, nil, html}
     ]}
  end

  def rss_feed_message(conn, thread, message) do
    {:safe, html} = Cforum.MarkdownRenderer.to_html(message, conn)

    {:item, nil,
     [
       {:title, nil, message.subject},
       {:pubDate, nil, Timex.lformat!(message.created_at, "{RFC822z}", "en")},
       {:link, nil, Path.message_url(conn, :show, thread, message)},
       {:guid, nil, Path.message_url(conn, :show, thread, message)},
       {:description, nil, html}
     ]}
  end
end
