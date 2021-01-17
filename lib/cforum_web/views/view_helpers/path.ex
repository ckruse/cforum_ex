defmodule CforumWeb.Views.ViewHelpers.Path do
  @moduledoc "Contains all path helpers"

  alias Cforum.PrivMessages.PrivMessage

  alias Cforum.Forums.Forum
  alias Cforum.Threads.Thread
  alias Cforum.Messages.{Message, MessageVersion}
  alias Cforum.Tags.{Tag, Synonym}

  alias CforumWeb.Router.Helpers, as: Routes
  alias Cforum.Helpers

  @typep conn :: Plug.Conn.t() | CforumWeb.Endpoint
  @typep params :: map() | list()
  @typep opt_params :: map() | list() | false
  @typep id() :: String.t() | non_neg_integer()

  def add_url_flag(conn, flag, value) do
    new_flags =
      (conn.assigns[:_url_flags] || [])
      |> Keyword.put(flag, value)

    Plug.Conn.assign(conn, :_url_flags, new_flags)
  end

  def del_url_flag(conn, flag) do
    new_flags =
      (conn.assigns[:_url_flags] || [])
      |> Keyword.delete(flag)

    Plug.Conn.assign(conn, :_url_flags, new_flags)
  end

  @spec forum_slug(Forum.t() | nil | String.t(), boolean()) :: String.t() | nil
  def forum_slug(forum, with_all \\ true)
  def forum_slug(nil, true), do: "all"
  def forum_slug(nil, _), do: nil
  def forum_slug(%Forum{} = forum, _), do: forum.slug
  def forum_slug(slug, _), do: slug

  def root_path(conn, :index, params \\ []),
    do: "#{Routes.root_path(conn, :index)}#{encode_query_string(conn, params)}"

  def root_url(conn, :index, params \\ []),
    do: "#{Routes.root_url(conn, :index)}#{encode_query_string(conn, params)}"

  @spec forum_path(conn(), atom(), String.t() | Forum.t() | nil, opt_params()) :: String.t()
  def forum_path(conn, action, slug, params \\ [])

  def forum_path(conn, :index, slug, params),
    do: "#{root_path(conn, :index, false)}#{forum_slug(slug)}#{encode_query_string(conn, params)}"

  def forum_path(conn, :atom, slug, params),
    do: "#{root_path(conn, :index, false)}#{forum_slug(slug)}/feeds/atom#{encode_query_string(conn, params)}"

  def forum_path(conn, :rss, slug, params),
    do: "#{root_path(conn, :index, false)}#{forum_slug(slug)}/feeds/rss#{encode_query_string(conn, params)}"

  def forum_path(conn, :stats, slug, params),
    do: "#{root_path(conn, :index, false)}#{forum_slug(slug)}/stats#{encode_query_string(conn, params)}"

  def forum_path(conn, :unanswered, slug, params),
    do: "#{root_path(conn, :index, false)}#{forum_slug(slug)}/unanswered#{encode_query_string(conn, params)}"

  @spec forum_url(conn(), atom(), String.t() | Forum.t() | nil, opt_params()) :: String.t()
  def forum_url(conn, action, slug, params \\ [])

  def forum_url(conn, :index, slug, params),
    do: "#{root_url(conn, :index, false)}#{forum_slug(slug)}#{encode_query_string(conn, params)}"

  def forum_url(conn, :atom, slug, params),
    do: "#{root_url(conn, :index, false)}#{forum_slug(slug)}/feeds/atom#{encode_query_string(conn, params)}"

  def forum_url(conn, :rss, slug, params),
    do: "#{root_url(conn, :index, false)}#{forum_slug(slug)}/feeds/rss#{encode_query_string(conn, params)}"

  def forum_url(conn, :stats, slug, params),
    do: "#{root_url(conn, :index, false)}#{forum_slug(slug)}/stats#{encode_query_string(conn, params)}"

  def forum_url(conn, :unanswered, slug, params),
    do: "#{root_url(conn, :index, false)}#{forum_slug(slug)}/unanswered#{encode_query_string(conn, params)}"

  @spec archive_path(
          conn(),
          atom(),
          Forum.t() | String.t() | nil,
          params
          | tuple()
          | DateTime.t()
          | Date.t()
          | NaiveDateTime.t(),
          params()
        ) :: String.t()
  def archive_path(conn, action, forum, year_or_params \\ [], params \\ [])

  def archive_path(conn, :years, forum, params, _),
    do: "#{forum_path(conn, :index, forum, false)}/archive#{encode_query_string(conn, params)}"

  def archive_path(conn, :months, forum, {{year, _, _}, _}, params),
    do: "#{forum_path(conn, :index, forum, false)}/#{year}#{encode_query_string(conn, params)}"

  def archive_path(conn, :months, forum, %Date{} = date, params),
    do: "#{forum_path(conn, :index, forum, false)}/#{date.year}#{encode_query_string(conn, params)}"

  def archive_path(conn, :months, forum, %DateTime{} = date, params),
    do: archive_path(conn, :months, forum, DateTime.to_date(date), params)

  def archive_path(conn, :months, forum, %NaiveDateTime{} = date, params),
    do: archive_path(conn, :months, forum, NaiveDateTime.to_date(date), params)

  def archive_path(conn, :threads, forum, month, params) do
    part = month |> Timex.lformat!("%Y/%b", "en", :strftime) |> String.downcase()
    "#{forum_path(conn, :index, forum, false)}/#{part}#{encode_query_string(conn, params)}"
  end

  @spec tag_path(conn(), atom(), Tag.t() | opt_params(), opt_params()) :: String.t()
  def tag_path(conn, action, tag_or_params \\ [], params \\ [])
  def tag_path(conn, :create, params, _), do: tag_path(conn, :index, params)
  def tag_path(conn, :delete, tag, params), do: tag_path(conn, :show, tag, params)

  def tag_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}tags#{encode_query_string(conn, params)}"

  def tag_path(conn, :show, tag, params),
    do: "#{root_path(conn, :index, false)}tags/#{tag.slug}#{encode_query_string(conn, params)}"

  def tag_path(conn, :edit, tag, params),
    do: "#{root_path(conn, :index, false)}tags/#{tag.slug}/edit#{encode_query_string(conn, params)}"

  def tag_path(conn, :update, tag, params),
    do: "#{root_path(conn, :index, false)}tags/#{tag.slug}#{encode_query_string(conn, params)}"

  def tag_path(conn, :new, params, _),
    do: "#{root_path(conn, :index, false)}tags/new#{encode_query_string(conn, params)}"

  def tag_path(conn, :merge, tag, params),
    do: "#{root_path(conn, :index, false)}tags/#{tag.slug}/merge#{encode_query_string(conn, params)}"

  @spec tag_synonym_path(conn(), atom(), Tag.t(), Synonym.t() | params(), params()) :: String.t()
  def tag_synonym_path(conn, action, tag, synonym \\ [], params \\ [])

  def tag_synonym_path(conn, :new, tag, params, _),
    do: "#{tag_path(conn, :show, tag, false)}/synonyms/new#{encode_query_string(conn, params)}"

  def tag_synonym_path(conn, :create, tag, params, _),
    do: "#{tag_path(conn, :show, tag, false)}/synonyms#{encode_query_string(conn, params)}"

  def tag_synonym_path(conn, :edit, tag, synonym, params) do
    "#{tag_path(conn, :show, tag, false)}/synonyms/" <>
      "#{synonym.tag_synonym_id}/edit#{encode_query_string(conn, params)}"
  end

  def tag_synonym_path(conn, :update, tag, synonym, params) do
    "#{tag_path(conn, :show, tag, false)}/synonyms/" <> "#{synonym.tag_synonym_id}#{encode_query_string(conn, params)}"
  end

  def tag_synonym_path(conn, :delete, tag, synonym, params) do
    "#{tag_path(conn, :show, tag, false)}/synonyms/" <> "#{synonym.tag_synonym_id}#{encode_query_string(conn, params)}"
  end

  @doc """
  Generates URL path part to the thread (w/o message part). Mainly
  used internally, but in case you need it, it is there. Waiting
  patiently. ;-)

  ## Parameters

  - `conn` - the current `%Plug.Conn{}` struct
  - `action` - the request action, e.g. `:show`
  - `resource` - the thread to generate the path to, the forum or `"/all"` (for :new)
  - `params` - an optional query string as a dict
  """
  @spec thread_path(conn(), atom(), Thread.t() | Forum.t() | String.t() | nil, opt_params()) :: String.t()
  def thread_path(conn, action, resource \\ nil, params \\ [])

  def thread_path(conn, :show, %Thread{} = thread, params),
    do: "#{forum_path(conn, :index, thread.forum, false)}#{thread.slug}#{encode_query_string(conn, params)}"

  def thread_path(conn, :rss, %Thread{} = thread, params) do
    "#{forum_path(conn, :index, thread.forum, false)}/feeds/rss/#{thread.thread_id}#{encode_query_string(conn, params)}"
  end

  def thread_path(conn, :atom, %Thread{} = thread, params) do
    "#{forum_path(conn, :index, thread.forum, false)}/feeds/atom/#{thread.thread_id}#{encode_query_string(conn, params)}"
  end

  def thread_path(conn, :new, forum, params),
    do: "#{forum_path(conn, :index, forum, false)}/new#{encode_query_string(conn, params)}"

  def thread_path(conn, :move, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread, false)}/move#{encode_query_string(conn, params)}"

  def thread_path(conn, :sticky, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread, false)}/sticky#{encode_query_string(conn, params)}"

  def thread_path(conn, :unsticky, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread, false)}/unsticky#{encode_query_string(conn, params)}"

  def thread_path(conn, :no_archive, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread, false)}/no-archive#{encode_query_string(conn, params)}"

  def thread_path(conn, :do_archive, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread, false)}/do-archive#{encode_query_string(conn, params)}"

  def thread_path(conn, :hide, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread, false)}/hide#{encode_query_string(conn, params)}"

  def thread_path(conn, :unhide, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread, false)}/unhide#{encode_query_string(conn, params)}"

  def thread_path(conn, :invisible_index, _, params),
    do: "#{root_path(conn, :index)}invisible#{encode_query_string(conn, params)}"

  def thread_path(conn, :open, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread, false)}/open#{encode_query_string(conn, params)}"

  def thread_path(conn, :close, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread, false)}/close#{encode_query_string(conn, params)}"

  def thread_path(conn, :split, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread, false)}/split#{encode_query_string(conn, params)}"

  @spec thread_url(conn(), atom(), Thread.t(), opt_params()) :: String.t()
  def thread_url(conn, action, resource, params \\ [])

  def thread_url(conn, :show, %Thread{} = thread, params),
    do: "#{forum_url(conn, :index, thread.forum, false)}#{thread.slug}#{encode_query_string(conn, params)}"

  def thread_url(conn, :rss, %Thread{} = thread, params) do
    "#{forum_url(conn, :index, thread.forum, false)}/feeds/rss/#{thread.thread_id}#{encode_query_string(conn, params)}"
  end

  def thread_url(conn, :atom, %Thread{} = thread, params) do
    "#{forum_url(conn, :index, thread.forum, false)}/feeds/atom/#{thread.thread_id}#{encode_query_string(conn, params)}"
  end

  defp to_param(int) when is_integer(int), do: Integer.to_string(int)
  defp to_param(bin) when is_binary(bin), do: bin
  defp to_param(false), do: "false"
  defp to_param(true), do: "true"
  defp to_param(data), do: Phoenix.Param.to_param(data)

  @spec encode_query_string(params()) :: String.t()
  def encode_query_string(key_value) when key_value == [] or key_value == %{}, do: ""

  def encode_query_string(key_value) do
    query = Enum.filter(key_value, fn {k, v} -> Helpers.present?(k) && !is_nil(v) end)

    case Plug.Conn.Query.encode(query, &to_param/1) do
      "" -> ""
      qstr -> "?" <> qstr
    end
  end

  @spec encode_query_string(conn(), opt_params()) :: String.t()
  def encode_query_string(CforumWeb.Endpoint, query) when query == [] or query == %{} or query == false, do: ""
  def encode_query_string(CforumWeb.Endpoint, query), do: encode_query_string(query)
  def encode_query_string(_conn, false), do: ""

  def encode_query_string(conn, query) when query == [] or query == %{},
    do: encode_query_string(conn.assigns[:_url_flags] || [])

  def encode_query_string(conn, query) when is_map(query),
    do: encode_query_string(conn, Map.to_list(query))

  def encode_query_string(conn, query) do
    flags = conn.assigns[:_url_flags] || []
    encode_query_string(Keyword.merge(flags, query || []))
  end

  def int_message_path(conn, thread, message),
    do: "#{thread_path(conn, :show, thread, false)}/#{message.message_id}"

  def int_message_url(conn, thread, message),
    do: "#{thread_url(conn, :show, thread, false)}/#{message.message_id}"

  @spec message_url(conn(), atom(), Thread.t(), Message.t(), params()) :: String.t()
  def message_url(conn, action, thread, message, params \\ [])

  def message_url(conn, :show, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_url(conn, thread, msg)}#{encode_query_string(conn, params)}#m#{msg.message_id}"

  @spec blog_url(conn(), params()) :: String.t()
  def blog_url(conn, params \\ []) do
    base_url = Application.get_env(:cforum, :blog_base_url, "") |> String.replace(~r(/+$), "")
    "#{base_url}/#{encode_query_string(conn, params)}"
  end

  @spec blog_rss_url(conn(), params()) :: String.t()
  def blog_rss_url(conn, params \\ []),
    do: "#{blog_url(conn)}feed/rss#{encode_query_string(conn, params)}"

  @spec blog_atom_url(conn(), params()) :: String.t()
  def blog_atom_url(conn, params \\ []),
    do: "#{blog_url(conn)}/feed/atom#{encode_query_string(conn, params)}"

  @spec blog_message_url(conn(), atom(), Thread.t(), Message.t(), params()) :: String.t()
  def blog_message_url(conn, :show, %Thread{} = thread, %Message{} = msg, params \\ []),
    do: "#{blog_thread_url(conn, :show, thread, params)}#m#{msg.message_id}"

  @spec blog_thread_url(conn(), atom(), Thread.t(), params()) :: String.t()
  def blog_thread_url(conn, :show, %Thread{} = thread, params \\ []) do
    url = blog_url(conn) |> String.replace(~r(/+$), "")
    "#{url}#{thread.slug}#{encode_query_string(conn, params)}"
  end

  @spec blog_thread_path(conn(), :show, Thread.t(), params()) :: String.t()
  @spec blog_thread_path(conn(), :new, params(), any) :: String.t()

  def blog_thread_path(conn, action, thread_or_params \\ [], params \\ [])

  def blog_thread_path(conn, :show, %Thread{} = thread, params) do
    url = root_path(conn, :index) |> String.replace(~r(/+$), "")
    "#{url}#{thread.slug}#{encode_query_string(conn, params)}"
  end

  def blog_thread_path(conn, :new, params, _),
    do: "#{root_path(conn, :index)}new#{encode_query_string(conn, params)}"

  @spec blog_comment_path(conn(), atom(), Thread.t(), Message.t() | params(), params()) :: String.t()
  def blog_comment_path(conn, action, thread, message, params \\ [])

  def blog_comment_path(conn, :show, %Thread{} = thread, message, params),
    do: "#{blog_thread_path(conn, :show, thread)}#m#{message.message_id}#{encode_query_string(conn, params)}"

  def blog_comment_path(conn, :new, %Thread{} = thread, message, params),
    do: "#{blog_thread_path(conn, :show, thread)}/#{message.message_id}/new#{encode_query_string(conn, params)}"

  @spec blog_image_url(conn(), atom(), Cforum.Media.Image.t(), params()) :: String.t()
  def blog_image_url(conn, :show, image, params \\ []),
    do: "#{blog_url(conn)}images/#{image.filename}#{encode_query_string(conn, params)}"

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
  @spec message_path(conn(), atom(), Thread.t(), Message.t(), params()) :: String.t()
  def message_path(conn, action, thread, message, params \\ [])

  def message_path(conn, :show, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}#{encode_query_string(conn, params)}#m#{msg.message_id}"

  def message_path(conn, :new, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/new#{encode_query_string(conn, params)}"

  def message_path(conn, :edit, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/edit#{encode_query_string(conn, params)}"

  def message_path(conn, :retag, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/retag#{encode_query_string(conn, params)}"

  def message_path(conn, :flag, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/flag#{encode_query_string(conn, params)}"

  def message_path(conn, :subscribe, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/subscribe#{encode_query_string(conn, params)}"

  def message_path(conn, :unsubscribe, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/unsubscribe#{encode_query_string(conn, params)}"

  def message_path(conn, :interesting, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/interesting#{encode_query_string(conn, params)}"

  def message_path(conn, :boring, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/boring#{encode_query_string(conn, params)}"

  def message_path(conn, :unread, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/unread#{encode_query_string(conn, params)}"

  def message_path(conn, :upvote, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/upvote#{encode_query_string(conn, params)}"

  def message_path(conn, :downvote, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/downvote#{encode_query_string(conn, params)}"

  def message_path(conn, :accept, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/accept#{encode_query_string(conn, params)}"

  def message_path(conn, :unaccept, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/unaccept#{encode_query_string(conn, params)}"

  @spec message_version_path(Plug.Conn.t(), atom(), Thread.t(), Message.t(), params() | MessageVersion.t(), params()) ::
          String.t()
  def message_version_path(conn, action, thread, msg, params_or_version \\ [], params \\ [])

  def message_version_path(conn, :index, %Thread{} = thread, %Message{} = msg, params, _),
    do: "#{int_message_path(conn, thread, msg)}/versions#{encode_query_string(conn, params)}"

  def message_version_path(conn, :delete, %Thread{} = thread, %Message{} = msg, version, params) do
    "#{int_message_path(conn, thread, msg)}/versions/#{version.message_version_id}#{encode_query_string(conn, params)}"
  end

  @spec mark_read_path(conn(), atom(), Thread.t() | nil | params(), params()) :: String.t()
  def mark_read_path(conn, action, thread_or_params \\ nil, params \\ [])

  def mark_read_path(conn, :mark_read, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread, false)}/mark-read#{encode_query_string(conn, params)}"

  def mark_read_path(conn, :mark_all_read, forum, params),
    do: "#{forum_path(conn, :index, forum, false)}/mark-all-read#{encode_query_string(conn, params)}"

  @spec mail_thread_path(conn(), :show, PrivMessage.t(), params()) :: String.t()
  def mail_thread_path(conn, :show, pm, params \\ []) do
    "#{root_path(conn, :index, false)}mails/#{pm.thread_id}#{encode_query_string(conn, params)}#pm#{pm.priv_message_id}"
  end

  # cites

  def cite_path(conn, action, cite \\ nil, params \\ [])
  def cite_path(conn, :delete, cite, params), do: cite_path(conn, :show, cite, params)
  def cite_path(conn, :update, cite, params), do: cite_path(conn, :show, cite, params)
  def cite_path(conn, :create, params, _), do: cite_path(conn, :index, params, nil)

  def cite_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}cites#{encode_query_string(conn, params)}"

  def cite_path(conn, :index_voting, params, _),
    do: "#{root_path(conn, :index, false)}cites/voting#{encode_query_string(conn, params)}"

  def cite_path(conn, :new, params, _),
    do: "#{root_path(conn, :index, false)}cites/new#{encode_query_string(conn, params)}"

  def cite_path(conn, :show, cite, params),
    do: "#{root_path(conn, :index, false)}cites/#{cite.cite_id}#{encode_query_string(conn, params)}"

  def cite_path(conn, :edit, cite, params),
    do: "#{root_path(conn, :index, false)}cites/#{cite.cite_id}/edit#{encode_query_string(conn, params)}"

  def cite_path(conn, :vote, cite, params),
    do: "#{cite_path(conn, :show, cite, false)}/vote#{encode_query_string(conn, params)}"

  # images

  def image_path(conn, action, image_or_params \\ nil, params \\ [])

  def image_path(conn, :delete, image, params),
    do: "#{root_path(conn, :index, false)}images/#{image.medium_id}#{encode_query_string(conn, params)}"

  def image_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}images#{encode_query_string(conn, params)}"

  def image_path(conn, :show, image, params),
    do: "#{root_path(conn, :index, false)}images/#{image.filename}#{encode_query_string(conn, params)}"

  # events

  def event_path(conn, action, event_or_params \\ nil, params \\ [])

  def event_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}events#{encode_query_string(conn, params)}"

  def event_path(conn, :show, event, params),
    do: "#{root_path(conn, :index, false)}events/#{event.event_id}#{encode_query_string(conn, params)}"

  def event_path(conn, :edit, event, params),
    do: "#{root_path(conn, :index, false)}events/#{event.event_id}/edit#{encode_query_string(conn, params)}"

  # event attendees
  def event_attendee_path(conn, action, event, attendee_or_params \\ nil, params \\ [])

  def event_attendee_path(conn, :delete, event, attendee, params),
    do: event_attendee_path(conn, :show, event, attendee, params)

  def event_attendee_path(conn, :update, event, attendee, params),
    do: event_attendee_path(conn, :show, event, attendee, params)

  def event_attendee_path(conn, :create, event, params, _),
    do: "#{event_path(conn, :show, event, false)}/attendees#{encode_query_string(conn, params)}"

  def event_attendee_path(conn, :new, event, params, _),
    do: "#{event_path(conn, :show, event, false)}/attendees/new#{encode_query_string(conn, params)}"

  def event_attendee_path(conn, :edit, event, attendee, params),
    do: "#{event_attendee_path(conn, :show, event, attendee, false)}/edit#{encode_query_string(conn, params)}"

  def event_attendee_path(conn, :show, event, attendee, params),
    do: "#{event_path(conn, :show, event, false)}/attendees/#{attendee.attendee_id}#{encode_query_string(conn, params)}"

  # mails

  @spec mail_path(conn(), atom(), %{priv_message_id: id()} | nil | opt_params(), opt_params()) :: String.t()
  def mail_path(conn, action, mail_or_params \\ nil, params \\ [])
  def mail_path(conn, :new, params, _), do: "#{mail_path(conn, :index, false)}/new#{encode_query_string(conn, params)}"
  def mail_path(conn, :create, params, _), do: mail_path(conn, :index, params)
  def mail_path(conn, :delete, mail, params), do: mail_path(conn, :show, mail, params)

  def mail_path(conn, :update_unread, mail, params),
    do: "#{mail_path(conn, :show, mail, false)}/unread#{encode_query_string(conn, params)}"

  def mail_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}mails#{encode_query_string(conn, params)}"

  def mail_path(conn, :show, mail, params),
    do: "#{root_path(conn, :index, false)}mails/#{mail.priv_message_id}#{encode_query_string(conn, params)}"

  # notifications

  @spec notification_path(conn(), atom(), %{notification_id: id()} | nil | opt_params(), opt_params()) :: String.t()
  def notification_path(conn, action, notification_or_params \\ nil, params \\ [])
  def notification_path(conn, :delete, notification, params), do: notification_path(conn, :show, notification, params)

  def notification_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}notifications#{encode_query_string(conn, params)}"

  def notification_path(conn, :batch_action, params, _),
    do: "#{root_path(conn, :index, false)}notifications/batch#{encode_query_string(conn, params)}"

  def notification_path(conn, :show, notification, params) do
    "#{root_path(conn, :index, false)}notifications/#{notification.notification_id}" <>
      encode_query_string(conn, params)
  end

  def notification_path(conn, :update_unread, notification, params),
    do: "#{notification_path(conn, :show, notification, false)}/unread#{encode_query_string(conn, params)}"

  # sessions
  def session_path(conn, action, params \\ [])
  def session_path(conn, :create, params), do: session_path(conn, :new, params)
  def session_path(conn, :new, params), do: "#{root_path(conn, :index, false)}login#{encode_query_string(conn, params)}"

  def session_path(conn, :delete, params),
    do: "#{root_path(conn, :index, false)}logout#{encode_query_string(conn, params)}"

  # users

  def user_path(conn, action, user_or_params \\ nil, params \\ [])
  def user_path(conn, :delete, user, params), do: user_path(conn, :show, user, params)
  def user_path(conn, :update, user, params), do: user_path(conn, :show, user, params)

  def user_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}users#{encode_query_string(conn, params)}"

  def user_path(conn, :show, user, params),
    do: "#{root_path(conn, :index, false)}users/#{user.user_id}" <> encode_query_string(conn, params)

  def user_path(conn, :show_messages, user, params),
    do: "#{user_path(conn, :show, user, false)}/messages#{encode_query_string(conn, params)}"

  def user_path(conn, :show_scores, user, params),
    do: "#{user_path(conn, :show, user, false)}/scores#{encode_query_string(conn, params)}"

  def user_path(conn, :show_votes, user, params),
    do: "#{user_path(conn, :show, user, false)}/votes#{encode_query_string(conn, params)}"

  def user_path(conn, :edit, user, params),
    do: "#{root_path(conn, :index, false)}users/#{user.user_id}/edit" <> encode_query_string(conn, params)

  def user_path(conn, :confirm_delete, user, params),
    do: "#{user_path(conn, :show, user, false)}/delete#{encode_query_string(conn, params)}"

  def user_path(conn, :deletion_started, params, _),
    do: "#{user_path(conn, :index, false)}/deletion-started#{encode_query_string(conn, params)}"

  # moderation queue

  def moderation_path(conn, action, moderation_or_params \\ nil, params \\ [])
  def moderation_path(conn, :update, moderation, params), do: moderation_path(conn, :show, moderation, params)

  def moderation_path(conn, :edit, moderation, params),
    do: "#{moderation_path(conn, :show, moderation, false)}/edit#{encode_query_string(conn, params)}"

  def moderation_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}moderation#{encode_query_string(conn, params)}"

  def moderation_path(conn, :index_open, params, _),
    do: "#{root_path(conn, :index, false)}moderation/open#{encode_query_string(conn, params)}"

  def moderation_path(conn, :show, moderation, params) do
    "#{root_path(conn, :index, false)}moderation/#{moderation.moderation_queue_entry_id}" <>
      encode_query_string(conn, params)
  end

  @spec moderation_url(conn(), atom(), %{moderation_queue_entry_id: id()} | nil | opt_params(), opt_params()) ::
          String.t()
  def moderation_url(conn, action, moderation_or_params \\ nil, params \\ [])

  def moderation_url(conn, :show, moderation, params) do
    "#{root_url(conn, :index, false)}moderation/#{moderation.moderation_queue_entry_id}" <>
      encode_query_string(conn, params)
  end

  # badges

  def badge_path(conn, action, badge_or_params \\ nil, params \\ [])

  def badge_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}badges#{encode_query_string(conn, params)}"

  def badge_path(conn, :show, badge, params),
    do: "#{root_path(conn, :index, false)}badges/#{badge.slug}" <> encode_query_string(conn, params)

  def search_path(conn, :show, params \\ []),
    do: "#{root_path(conn, :index, false)}search#{encode_query_string(conn, params)}"

  def search_url(conn, :show, params \\ []),
    do: "#{root_url(conn, :index, false)}search#{encode_query_string(conn, params)}"

  def registration_path(conn, action, params \\ [])

  def registration_path(conn, :new, params),
    do: "#{root_path(conn, :index, false)}registrations/new" <> encode_query_string(conn, params)

  def registration_path(conn, :create, params),
    do: "#{root_path(conn, :index, false)}registrations" <> encode_query_string(conn, params)

  def registration_path(conn, :confirm, params),
    do: "#{root_path(conn, :index, false)}registrations/confirm#{encode_query_string(conn, params)}"

  @spec registration_url(conn(), atom(), opt_params()) :: String.t()
  def registration_url(conn, :confirm, params),
    do: "#{root_url(conn, :index, false)}registrations/confirm#{encode_query_string(conn, params)}"

  # password reset

  @spec password_path(conn(), atom(), opt_params()) :: String.t()
  def password_path(conn, action, params \\ [])
  def password_path(conn, :create, params), do: password_path(conn, :new, params)
  def password_path(conn, :update_reset, params), do: password_path(conn, :edit_reset, params)

  def password_path(conn, :new, params),
    do: "#{root_path(conn, :index, false)}users/password#{encode_query_string(conn, params)}"

  def password_path(conn, :edit_reset, params),
    do: "#{root_path(conn, :index, false)}users/password/reset#{encode_query_string(conn, params)}"

  def password_url(conn, action, params \\ [])

  def password_url(conn, :new, params),
    do: "#{root_url(conn, :index, false)}users/password#{encode_query_string(conn, params)}"

  def password_url(conn, :edit_reset, params),
    do: "#{root_url(conn, :index, false)}users/password/reset#{encode_query_string(conn, params)}"

  # password
  @spec user_password_path(conn(), atom(), %{user_id: id()} | opt_params(), opt_params()) :: String.t()
  def user_password_path(conn, action, user, params \\ [])
  def user_password_path(conn, :update, user, params), do: user_password_path(conn, :edit, user, params)

  def user_password_path(conn, :edit, user, params),
    do: "#{user_path(conn, :show, user, false)}/password#{encode_query_string(conn, params)}"

  # interesting

  def interesting_path(conn, :index, params \\ []),
    do: "#{root_path(conn, :index, false)}interesting#{encode_query_string(conn, params)}"

  def subscription_path(conn, :index, params \\ []),
    do: "#{root_path(conn, :index, false)}subscriptions#{encode_query_string(conn, params)}"

  # pages

  def page_path(conn, page, params \\ [])
  def page_path(conn, :help, params), do: "#{root_path(conn, :index, false)}help#{encode_query_string(conn, params)}"

  #
  # admin routes
  #
  def admin_badge_path(conn, action, badge_or_params \\ nil, params \\ [])
  def admin_badge_path(conn, :create, params, _), do: admin_badge_path(conn, :index, params)
  def admin_badge_path(conn, :update, badge, params), do: admin_badge_path(conn, :show, badge, params)
  def admin_badge_path(conn, :delete, badge, params), do: admin_badge_path(conn, :show, badge, params)

  def admin_badge_path(conn, :new, params, _),
    do: "#{root_path(conn, :index, false)}admin/badges/new#{encode_query_string(conn, params)}"

  def admin_badge_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}admin/badges#{encode_query_string(conn, params)}"

  def admin_badge_path(conn, :show, badge, params),
    do: "#{root_path(conn, :index, false)}admin/badges/#{badge.badge_id}#{encode_query_string(conn, params)}"

  def admin_badge_path(conn, :edit, badge, params),
    do: "#{root_path(conn, :index, false)}admin/badges/#{badge.badge_id}/edit#{encode_query_string(conn, params)}"

  def admin_event_path(conn, action, event_or_params \\ nil, params \\ [])
  def admin_event_path(conn, :create, params, _), do: admin_event_path(conn, :index, params, nil)
  def admin_event_path(conn, :update, event, params), do: admin_event_path(conn, :show, event, params)
  def admin_event_path(conn, :delete, event, params), do: admin_event_path(conn, :show, event, params)

  def admin_event_path(conn, :new, params, _),
    do: "#{root_path(conn, :index, false)}admin/events/new#{encode_query_string(conn, params)}"

  def admin_event_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}admin/events#{encode_query_string(conn, params)}"

  def admin_event_path(conn, :show, event, params),
    do: "#{root_path(conn, :index, false)}admin/events/#{event.event_id}#{encode_query_string(conn, params)}"

  def admin_event_path(conn, :edit, event, params),
    do: "#{root_path(conn, :index, false)}admin/events/#{event.event_id}/edit#{encode_query_string(conn, params)}"

  def admin_forum_path(conn, action, forum_or_params \\ nil, params \\ [])
  def admin_forum_path(conn, :create, params, _), do: admin_forum_path(conn, :index, params, nil)
  def admin_forum_path(conn, :update, forum, params), do: admin_forum_path(conn, :show, forum, params)
  def admin_forum_path(conn, :delete, forum, params), do: admin_forum_path(conn, :show, forum, params)

  def admin_forum_path(conn, :new, params, _),
    do: "#{root_path(conn, :index, false)}admin/forums/new#{encode_query_string(conn, params)}"

  def admin_forum_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}admin/forums#{encode_query_string(conn, params)}"

  def admin_forum_path(conn, :show, forum, params),
    do: "#{root_path(conn, :index, false)}admin/forums/#{forum.slug}#{encode_query_string(conn, params)}"

  def admin_forum_path(conn, :edit, forum, params),
    do: "#{root_path(conn, :index, false)}admin/forums/#{forum.slug}/edit#{encode_query_string(conn, params)}"

  def admin_group_path(conn, action, group_or_params \\ nil, params \\ [])
  def admin_group_path(conn, :create, params, _), do: admin_group_path(conn, :index, params, nil)
  def admin_group_path(conn, :update, group, params), do: admin_group_path(conn, :show, group, params)
  def admin_group_path(conn, :delete, group, params), do: admin_group_path(conn, :show, group, params)

  def admin_group_path(conn, :new, params, _),
    do: "#{root_path(conn, :index, false)}admin/groups/new#{encode_query_string(conn, params)}"

  def admin_group_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}admin/groups#{encode_query_string(conn, params)}"

  def admin_group_path(conn, :show, group, params),
    do: "#{root_path(conn, :index, false)}admin/groups/#{group.group_id}#{encode_query_string(conn, params)}"

  def admin_group_path(conn, :edit, group, params),
    do: "#{root_path(conn, :index, false)}admin/groups/#{group.group_id}/edit#{encode_query_string(conn, params)}"

  def admin_redirection_path(conn, action, redirection_or_params \\ nil, params \\ [])
  def admin_redirection_path(conn, :create, params, _), do: admin_redirection_path(conn, :index, params, nil)

  def admin_redirection_path(conn, :update, redirection, params),
    do: admin_redirection_path(conn, :show, redirection, params)

  def admin_redirection_path(conn, :delete, redirection, params),
    do: admin_redirection_path(conn, :show, redirection, params)

  def admin_redirection_path(conn, :new, params, _),
    do: "#{root_path(conn, :index, false)}admin/redirections/new#{encode_query_string(conn, params)}"

  def admin_redirection_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}admin/redirections#{encode_query_string(conn, params)}"

  def admin_redirection_path(conn, :show, redirection, params) do
    "#{root_path(conn, :index, false)}admin/redirections/#{redirection.redirection_id}" <>
      encode_query_string(conn, params)
  end

  def admin_redirection_path(conn, :edit, redirection, params) do
    "#{root_path(conn, :index, false)}admin/redirections/#{redirection.redirection_id}/edit" <>
      encode_query_string(conn, params)
  end

  def admin_search_section_path(conn, action, search_section_or_params \\ nil, params \\ [])
  def admin_search_section_path(conn, :create, params, _), do: admin_search_section_path(conn, :index, params, nil)

  def admin_search_section_path(conn, :update, search_section, params),
    do: admin_search_section_path(conn, :show, search_section, params)

  def admin_search_section_path(conn, :delete, search_section, params),
    do: admin_search_section_path(conn, :show, search_section, params)

  def admin_search_section_path(conn, :new, params, _),
    do: "#{root_path(conn, :index, false)}admin/search_sections/new#{encode_query_string(conn, params)}"

  def admin_search_section_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}admin/search_sections#{encode_query_string(conn, params)}"

  def admin_search_section_path(conn, :show, search_section, params) do
    "#{root_path(conn, :index, false)}admin/search_sections/#{search_section.search_section_id}" <>
      encode_query_string(conn, params)
  end

  def admin_search_section_path(conn, :edit, search_section, params) do
    "#{root_path(conn, :index, false)}admin/search_sections/#{search_section.search_section_id}/edit" <>
      encode_query_string(conn, params)
  end

  def admin_setting_path(conn, action, params \\ []) when action in [:edit, :update],
    do: "#{root_path(conn, :index, false)}admin/settings#{encode_query_string(conn, params)}"

  def admin_user_path(conn, action, user_or_params \\ nil, params \\ [])
  def admin_user_path(conn, :create, params, _), do: admin_user_path(conn, :index, params, nil)
  def admin_user_path(conn, :update, user, params), do: admin_user_path(conn, :show, user, params)
  def admin_user_path(conn, :delete, user, params), do: admin_user_path(conn, :show, user, params)

  def admin_user_path(conn, :new, params, _),
    do: "#{root_path(conn, :index, false)}admin/users/new#{encode_query_string(conn, params)}"

  def admin_user_path(conn, :index, params, _),
    do: "#{root_path(conn, :index, false)}admin/users#{encode_query_string(conn, params)}"

  def admin_user_path(conn, :show, user, params),
    do: "#{root_path(conn, :index, false)}admin/users/#{user.user_id}#{encode_query_string(conn, params)}"

  def admin_user_path(conn, :edit, user, params),
    do: "#{root_path(conn, :index, false)}admin/users/#{user.user_id}/edit#{encode_query_string(conn, params)}"

  def admin_audit_path(conn, :index, params \\ []),
    do: "#{root_path(conn, :index, false)}admin/audit" <> encode_query_string(conn, params)
end
