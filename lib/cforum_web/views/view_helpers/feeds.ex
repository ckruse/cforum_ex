defmodule CforumWeb.Views.ViewHelpers.Feeds do
  import CforumWeb.Gettext

  alias Cforum.Messages.Message
  alias Cforum.Threads.Thread
  alias Cforum.MarkdownRenderer
  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.LayoutView

  @type xml_struct :: {atom, map() | nil, [xml_struct()] | String.t()}

  @spec atom_feed_head_for_thread(Plug.Conn.t(), Thread.t(), [Message.t()]) :: xml_struct
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
       {:title, nil, safe_xml_pcdata("#{message.subject} – #{LayoutView.forum_name(forum)}")},
       {:updated, nil, Timex.lformat!(thread.latest_message, "{RFC3339z}", "en")},
       messages
     ]}
  end

  @spec atom_feed_head(Plug.Conn.t(), [Thread.t()], NaiveDateTime.t(), String.t(), String.t()) :: xml_struct
  def atom_feed_head(conn, threads, last_updated, forum_url, feed_url) do
    forum = conn.assigns[:current_forum]

    {:feed, %{"xml:lang" => Gettext.get_locale(CforumWeb.Gettext), "xmlns" => "http://www.w3.org/2005/Atom"},
     [
       {:id, nil, "tag:forum.selfhtml.org,2005:/self"},
       {:link, %{"rel" => "alternate", "type" => "text/html", "href" => forum_url}, []},
       {:link, %{"rel" => "self", "type" => "application/atom+xml", "href" => feed_url}, []},
       {:title, nil, LayoutView.forum_name(forum)},
       {:updated, nil, Timex.lformat!(last_updated, "{RFC3339z}", "en")},
       threads
     ]}
  end

  @spec atom_feed_message(Plug.Conn.t(), Thread.t(), Message.t()) :: xml_struct
  def atom_feed_message(conn, thread, message) do
    {:safe, html} = MarkdownRenderer.to_html(message, conn)

    {:safe, excerpt} =
      if Helpers.present?(message.excerpt),
        do: MarkdownRenderer.to_html(message, conn, :excerpt),
        else: {:safe, ""}

    children =
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
        {:title, nil, safe_xml_pcdata(message.subject)}
      ]
      |> Helpers.append_if(
        Helpers.present?(message.excerpt),
        {:summary, %{"type" => "html"}, safe_xml_pcdata(excerpt)}
      )

    {:entry, nil, children ++ [{:content, %{"type" => "html"}, safe_xml_pcdata(html)}]}
  end

  @spec atom_feed_thread(
          Plug.Conn.t(),
          Thread.t(),
          (Plug.Conn.t(), atom(), Thread.t() -> String.t()),
          (Plug.Conn.t(), atom(), Thread.t(), Message.t() -> String.t())
        ) ::
          xml_struct
  def atom_feed_thread(conn, thread, guid_fun \\ &Path.thread_url/3, path_fun \\ &Path.message_url/4) do
    {:safe, html} = MarkdownRenderer.to_html(thread.message, conn)

    {:safe, excerpt} =
      if Helpers.present?(thread.message.excerpt),
        do: MarkdownRenderer.to_html(thread.message, conn, :excerpt),
        else: {:safe, ""}

    children =
      [
        {:id, nil, guid_fun.(conn, :show, thread)},
        atom_author(thread.message),
        {:published, nil, Timex.lformat!(thread.created_at, "{RFC3339z}", "en")},
        {:updated, nil, Timex.lformat!(thread.updated_at, "{RFC3339z}", "en")},
        {:link,
         %{
           "rel" => "alternate",
           "type" => "text/html",
           "href" => path_fun.(conn, :show, thread, thread.message)
         }, []},
        {:title, nil, safe_xml_pcdata(thread.message.subject)}
      ]
      |> Helpers.append_if(
        Helpers.present?(thread.message.excerpt),
        {:summary, %{"type" => "html"}, safe_xml_pcdata(excerpt)}
      )

    {:entry, nil, children ++ [{:content, %{"type" => "html"}, safe_xml_pcdata(html)}]}
  end

  @spec atom_author(Message.t()) :: xml_struct
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

  @spec rss_feed_head(Plug.Conn.t(), [Thread.t()]) :: xml_struct()
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
          {:title, nil, LayoutView.forum_name(forum)},
          {:description, nil, desc},
          {:link, nil, Path.forum_url(conn, :index, forum)},
          {"atom:link",
           %{"rel" => "self", "type" => "application/rss+xml", "href" => Path.forum_url(conn, :rss, forum)}, []},
          threads
        ]}
     ]}
  end

  @spec rss_feed_head_for_thread(Plug.Conn.t(), Thread.t(), [Message.t()]) :: xml_struct()
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
          {:title, nil, safe_xml_pcdata("#{message.subject} – #{LayoutView.forum_name(forum)}")},
          {:description, nil, desc},
          {:link, nil, Path.forum_url(conn, :index, forum)},
          {"atom:link",
           %{"rel" => "self", "type" => "application/rss+xml", "href" => Path.thread_url(conn, :rss, thread)}, []},
          messages
        ]}
     ]}
  end

  @spec rss_feed_thread(Plug.Conn.t(), Thread.t()) :: xml_struct()
  def rss_feed_thread(conn, thread) do
    {:safe, html} = MarkdownRenderer.to_html(thread.message, conn)

    {:item, nil,
     [
       {:title, nil, safe_xml_pcdata(thread.message.subject)},
       {:pubDate, nil, Timex.lformat!(thread.message.created_at, "{RFC822z}", "en")},
       {:link, nil, Path.message_url(conn, :show, thread, thread.message)},
       {:guid, nil, Path.message_url(conn, :show, thread, thread.message)},
       {:description, nil, safe_xml_pcdata(html)}
     ]}
  end

  @spec rss_feed_message(Plug.Conn.t(), Thread.t(), Message.t()) :: xml_struct()
  def rss_feed_message(conn, thread, message) do
    {:safe, html} = MarkdownRenderer.to_html(message, conn)

    {:item, nil,
     [
       {:title, nil, safe_xml_pcdata(message.subject)},
       {:pubDate, nil, Timex.lformat!(message.created_at, "{RFC822z}", "en")},
       {:link, nil, Path.message_url(conn, :show, thread, message)},
       {:guid, nil, Path.message_url(conn, :show, thread, message)},
       {:description, nil, safe_xml_pcdata(html)}
     ]}
  end

  defp safe_xml_pcdata(content),
    do: Regex.replace(~r/[^\x{0009}\x{000a}\x{000d}\x{0020}-\x{D7FF}\x{E000}-\x{FFFD}]+/u, content, " ")
end
