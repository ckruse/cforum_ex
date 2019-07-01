defmodule CforumWeb.Views.Helpers.Path do
  @moduledoc "Contains all path helpers"

  alias Cforum.Accounts.PrivMessage

  alias Cforum.Forums.Forum
  alias Cforum.Threads.Thread
  alias Cforum.Messages.{Message, MessageVersion}
  alias Cforum.Messages.{Tag, TagSynonym}
  alias Cforum.Messages.CloseVote

  alias CforumWeb.Router.Helpers, as: Routes
  alias Cforum.Helpers

  @spec forum_slug(%Forum{} | nil | String.t(), boolean()) :: String.t() | nil
  def forum_slug(forum, with_all \\ true)
  def forum_slug(nil, true), do: "all"
  def forum_slug(nil, _), do: nil
  def forum_slug(%Forum{} = forum, _), do: forum.slug
  def forum_slug(slug, _), do: slug

  @spec forum_path(Plug.Conn.t() | CforumWeb.Endpoint, atom(), String.t() | %Forum{} | nil, keyword() | map()) ::
          String.t()
  def forum_path(conn, action, slug, params \\ [])

  def forum_path(conn, :index, slug, params),
    do: "#{Routes.root_path(conn, :index)}#{forum_slug(slug)}#{encode_query_string(conn, params)}"

  def forum_path(conn, :atom, slug, params),
    do: "#{Routes.root_path(conn, :index)}#{forum_slug(slug)}/feeds/atom#{encode_query_string(conn, params)}"

  def forum_path(conn, :rss, slug, params),
    do: "#{Routes.root_path(conn, :index)}#{forum_slug(slug)}/feeds/rss#{encode_query_string(conn, params)}"

  def forum_path(conn, :stats, slug, params),
    do: "#{Routes.root_path(conn, :index)}#{forum_slug(slug)}/stats#{encode_query_string(conn, params)}"

  def forum_path(conn, :unanswered, slug, params),
    do: "#{Routes.root_path(conn, :index)}#{forum_slug(slug)}/unanswered#{encode_query_string(conn, params)}"

  @spec forum_url(Plug.Conn.t() | CforumWeb.Endpoint, atom(), String.t() | %Forum{} | nil, keyword() | map()) ::
          String.t()
  def forum_url(conn, action, slug, params \\ [])

  def forum_url(conn, :index, slug, params),
    do: "#{Routes.root_url(conn, :index)}#{forum_slug(slug)}#{encode_query_string(conn, params)}"

  def forum_url(conn, :atom, slug, params),
    do: "#{Routes.root_url(conn, :index)}#{forum_slug(slug)}/feeds/atom#{encode_query_string(conn, params)}"

  def forum_url(conn, :rss, slug, params),
    do: "#{Routes.root_url(conn, :index)}#{forum_slug(slug)}/feeds/rss#{encode_query_string(conn, params)}"

  def forum_url(conn, :stats, slug, params),
    do: "#{Routes.root_url(conn, :index)}#{forum_slug(slug)}/stats#{encode_query_string(conn, params)}"

  def forum_url(conn, :unanswered, slug, params),
    do: "#{Routes.root_url(conn, :index)}#{forum_slug(slug)}/unanswered#{encode_query_string(conn, params)}"

  @spec archive_path(
          Plug.Conn.t() | CforumWeb.Endpoint,
          atom(),
          %Forum{},
          []
          | tuple()
          | DateTime.t()
          | Date.t()
          | NaiveDateTime.t(),
          []
        ) :: String.t()
  def archive_path(conn, action, forum, year_or_params \\ [], params \\ [])

  def archive_path(conn, :years, forum, params, _),
    do: "#{forum_path(conn, :index, forum)}/archive#{encode_query_string(conn, params)}"

  def archive_path(conn, :months, forum, {{year, _, _}, _}, params),
    do: "#{forum_path(conn, :index, forum)}/#{year}#{encode_query_string(conn, params)}"

  def archive_path(conn, :months, forum, %Date{} = date, params),
    do: "#{forum_path(conn, :index, forum)}/#{date.year}#{encode_query_string(conn, params)}"

  def archive_path(conn, :months, forum, %DateTime{} = date, params),
    do: archive_path(conn, :months, forum, DateTime.to_date(date), params)

  def archive_path(conn, :months, forum, %NaiveDateTime{} = date, params),
    do: archive_path(conn, :months, forum, NaiveDateTime.to_date(date), params)

  def archive_path(conn, :threads, forum, month, params) do
    part = month |> Timex.lformat!("%Y/%b", "en", :strftime) |> String.downcase()
    "#{forum_path(conn, :index, forum)}/#{part}#{encode_query_string(conn, params)}"
  end

  @spec tag_path(Plug.Conn.t() | CforumWeb.Endpoint, atom(), %Tag{} | [], keyword() | map()) :: String.t()
  def tag_path(conn, action, tag_or_params \\ [], params \\ [])

  def tag_path(conn, :index, params, _),
    do: "#{Routes.root_path(conn, :index)}tags#{encode_query_string(conn, params)}"

  def tag_path(conn, :show, tag, params),
    do: "#{Routes.root_path(conn, :index)}tags/#{tag.slug}#{encode_query_string(conn, params)}"

  def tag_path(conn, :edit, tag, params),
    do: "#{Routes.root_path(conn, :index)}tags/#{tag.slug}/edit#{encode_query_string(conn, params)}"

  def tag_path(conn, :update, tag, params),
    do: "#{Routes.root_path(conn, :index)}tags/#{tag.slug}#{encode_query_string(conn, params)}"

  def tag_path(conn, :new, params, _),
    do: "#{Routes.root_path(conn, :index)}tags/new#{encode_query_string(conn, params)}"

  def tag_path(conn, :create, params, _), do: tag_path(conn, :index, params)

  def tag_path(conn, :delete, tag, params), do: tag_path(conn, :show, tag, params)

  def tag_path(conn, :merge, tag, params),
    do: "#{Routes.root_path(conn, :index)}tags/#{tag.slug}/merge#{encode_query_string(conn, params)}"

  @spec tag_synonym_path(Plug.Conn.t() | CforumWeb.Endpoint, atom(), %Tag{}, %TagSynonym{} | [], keyword() | map()) ::
          String.t()
  def tag_synonym_path(conn, action, tag, synonym \\ [], params \\ [])

  def tag_synonym_path(conn, :new, tag, params, _),
    do: "#{tag_path(conn, :show, tag)}/synonyms/new#{encode_query_string(conn, params)}"

  def tag_synonym_path(conn, :create, tag, params, _),
    do: "#{tag_path(conn, :show, tag)}/synonyms#{encode_query_string(conn, params)}"

  def tag_synonym_path(conn, :edit, tag, synonym, params),
    do:
      "#{tag_path(conn, :show, tag)}/synonyms/" <> "#{synonym.tag_synonym_id}/edit#{encode_query_string(conn, params)}"

  def tag_synonym_path(conn, :update, tag, synonym, params),
    do: "#{tag_path(conn, :show, tag)}/synonyms/" <> "#{synonym.tag_synonym_id}#{encode_query_string(conn, params)}"

  def tag_synonym_path(conn, :delete, tag, synonym, params),
    do: "#{tag_path(conn, :show, tag)}/synonyms/" <> "#{synonym.tag_synonym_id}#{encode_query_string(conn, params)}"

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
  @spec thread_path(
          Plug.Conn.t() | CforumWeb.Endpoint,
          atom(),
          %Thread{} | %Forum{} | String.t() | nil,
          keyword() | map()
        ) :: String.t()
  def thread_path(conn, action, resource \\ nil, params \\ [])

  def thread_path(conn, :show, %Thread{} = thread, params),
    do: "#{forum_path(conn, :index, thread.forum)}#{thread.slug}#{encode_query_string(conn, params)}"

  def thread_path(conn, :rss, %Thread{} = thread, params),
    do: "#{forum_path(conn, :index, thread.forum)}/feeds/rss/#{thread.thread_id}#{encode_query_string(conn, params)}"

  def thread_path(conn, :atom, %Thread{} = thread, params),
    do: "#{forum_path(conn, :index, thread.forum)}/feeds/atom/#{thread.thread_id}#{encode_query_string(conn, params)}"

  def thread_path(conn, :new, forum, params),
    do: "#{forum_path(conn, :index, forum)}/new#{encode_query_string(conn, params)}"

  def thread_path(conn, :move, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread)}/move#{encode_query_string(conn, params)}"

  def thread_path(conn, :sticky, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread)}/sticky#{encode_query_string(conn, params)}"

  def thread_path(conn, :unsticky, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread)}/unsticky#{encode_query_string(conn, params)}"

  def thread_path(conn, :no_archive, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread)}/no-archive#{encode_query_string(conn, params)}"

  def thread_path(conn, :do_archive, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread)}/do-archive#{encode_query_string(conn, params)}"

  def thread_path(conn, :hide, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread)}/hide#{encode_query_string(conn, params)}"

  def thread_path(conn, :unhide, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread)}/unhide#{encode_query_string(conn, params)}"

  def thread_path(conn, :invisible_index, _, params),
    do: "#{Routes.root_path(conn, :index)}invisible#{encode_query_string(conn, params)}"

  def thread_path(conn, :open, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread)}/open#{encode_query_string(conn, params)}"

  def thread_path(conn, :close, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread)}/close#{encode_query_string(conn, params)}"

  def thread_path(conn, :split, %Thread{} = thread, params),
    do: "#{thread_path(conn, :show, thread)}/split#{encode_query_string(conn, params)}"

  @spec thread_url(Plug.Conn.t() | CforumWeb.Endpoint, atom(), %Thread{}, keyword() | map()) :: String.t()
  def thread_url(conn, action, resource, params \\ [])

  def thread_url(conn, :show, %Thread{} = thread, params),
    do: "#{forum_url(conn, :index, thread.forum)}#{thread.slug}#{encode_query_string(conn, params)}"

  def thread_url(conn, :rss, %Thread{} = thread, params),
    do: "#{forum_url(conn, :index, thread.forum)}/feeds/rss/#{thread.thread_id}#{encode_query_string(conn, params)}"

  def thread_url(conn, :atom, %Thread{} = thread, params),
    do: "#{forum_url(conn, :index, thread.forum)}/feeds/atom/#{thread.thread_id}#{encode_query_string(conn, params)}"

  defp to_param(int) when is_integer(int), do: Integer.to_string(int)
  defp to_param(bin) when is_binary(bin), do: bin
  defp to_param(false), do: "false"
  defp to_param(true), do: "true"
  defp to_param(data), do: Phoenix.Param.to_param(data)

  @spec encode_query_string([] | %{}) :: String.t()
  def encode_query_string(key_value) when key_value == [] or key_value == %{}, do: ""

  def encode_query_string(key_value) do
    query = Enum.filter(key_value, fn {k, v} -> Helpers.present?(k) && Helpers.present?(v) end)

    case Plug.Conn.Query.encode(query, &to_param/1) do
      "" -> ""
      qstr -> "?" <> qstr
    end
  end

  @spec encode_query_string(Plug.Conn.t() | CforumWeb.Endpoint, [] | %{}) :: String.t()
  def encode_query_string(CforumWeb.Endpoint, query) when query == [] or query == %{}, do: ""
  def encode_query_string(CforumWeb.Endpoint, query), do: encode_query_string(query)

  def encode_query_string(conn, query) when query == [] or query == %{},
    do: encode_query_string(conn.assigns[:_link_flags] || %{})

  def encode_query_string(conn, query) when is_list(query),
    do: encode_query_string(conn, Enum.into(query, %{}))

  def encode_query_string(conn, query) do
    flags = conn.assigns[:_link_flags] || %{}
    encode_query_string(Map.merge(flags, query))
  end

  def int_message_path(conn, thread, message, params \\ []),
    do: "#{thread_path(conn, :show, thread)}/#{message.message_id}#{encode_query_string(conn, params)}"

  def int_message_url(conn, thread, message, params),
    do: "#{thread_url(conn, :show, thread)}/#{message.message_id}#{encode_query_string(conn, params)}"

  @spec message_url(Plug.Conn.t() | CforumWeb.Endpoint, atom(), %Thread{}, %Message{}, keyword() | map()) :: String.t()
  def message_url(conn, action, thread, message, params \\ [])

  def message_url(conn, :show, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_url(conn, thread, msg, params)}#m#{msg.message_id}"

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
  @spec message_path(Plug.Conn.t() | CforumWeb.Endpoint, atom(), %Thread{}, %Message{}, keyword() | map()) :: String.t()
  def message_path(conn, action, thread, message, params \\ [])

  def message_path(conn, :show, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg, params)}#m#{msg.message_id}"

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

  def message_path(conn, :upvote, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/upvote#{encode_query_string(conn, params)}"

  def message_path(conn, :downvote, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/downvote#{encode_query_string(conn, params)}"

  def message_path(conn, :accept, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/accept#{encode_query_string(conn, params)}"

  def message_path(conn, :unaccept, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/unaccept#{encode_query_string(conn, params)}"

  def message_path(conn, :delete, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/delete#{encode_query_string(conn, params)}"

  def message_path(conn, :restore, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/restore#{encode_query_string(conn, params)}"

  def message_path(conn, :no_answer, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/no-answer#{encode_query_string(conn, params)}"

  def message_path(conn, :answer, %Thread{} = thread, %Message{} = msg, params),
    do: "#{int_message_path(conn, thread, msg)}/answer#{encode_query_string(conn, params)}"

  @spec message_version_path(
          Plug.Conn.t(),
          atom(),
          %Thread{},
          %Message{},
          keyword() | map() | %MessageVersion{},
          keyword() | map()
        ) :: String.t()
  def message_version_path(conn, action, thread, msg, params_or_version \\ [], params \\ [])

  def message_version_path(conn, :index, %Thread{} = thread, %Message{} = msg, params, _),
    do: "#{int_message_path(conn, thread, msg)}/versions#{encode_query_string(conn, params)}"

  def message_version_path(conn, :delete, %Thread{} = thread, %Message{} = msg, version, params) do
    "#{int_message_path(conn, thread, msg)}/versions/#{version.message_version_id}#{encode_query_string(conn, params)}"
  end

  @spec close_vote_path(Plug.Conn.t() | CforumWeb.Endpoint, %Thread{}, %Message{}, keyword() | map()) :: String.t()
  def close_vote_path(conn, %Thread{} = thread, %Message{} = msg, params \\ []),
    do: "#{int_message_path(conn, thread, msg)}/close-vote#{encode_query_string(conn, params)}"

  @spec open_vote_path(Plug.Conn.t() | CforumWeb.Endpoint, %Thread{}, %Message{}, keyword() | map()) :: String.t()
  def open_vote_path(conn, %Thread{} = thread, %Message{} = msg, params \\ []),
    do: "#{int_message_path(conn, thread, msg)}/open-vote#{encode_query_string(conn, params)}"

  @spec oc_vote_path(Plug.Conn.t() | CforumWeb.Endpoint, %Thread{}, %Message{}, %CloseVote{}, keyword() | map()) ::
          String.t()
  def oc_vote_path(conn, %Thread{} = thread, %Message{} = message, %CloseVote{} = vote, params \\ []),
    do: "#{int_message_path(conn, thread, message)}/oc-vote/#{vote.close_vote_id}#{encode_query_string(conn, params)}"

  @spec mark_read_path(Plug.Conn.t() | CforumWeb.Endpoint, :mark_read, %Thread{}, keyword() | map()) :: String.t()
  def mark_read_path(conn, :mark_read, %Thread{} = thread, params \\ []),
    do: "#{thread_path(conn, :show, thread)}/mark-read#{encode_query_string(conn, params)}"

  @spec mail_thread_path(Plug.Conn.t() | CforumWeb.Endpoint, :show, %PrivMessage{}, keyword() | map()) :: String.t()
  def mail_thread_path(conn, :show, pm, params \\ []) do
    "#{Routes.root_path(conn, :index)}mails/#{pm.thread_id}#{encode_query_string(conn, params)}#pm#{pm.priv_message_id}"
  end
end
