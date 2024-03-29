defmodule Cforum.ConfigManager do
  @moduledoc """
  Configuration management module, handling getting config values with
  increasing specifity
  """

  alias Cforum.Settings
  alias Cforum.Settings.Setting
  alias Cforum.Users.User
  alias Cforum.Forums.Forum

  alias Cforum.Helpers

  @type conf_map() :: %{global: Setting.t() | nil, forum: Setting.t() | nil, user: Setting.t() | nil}

  @defaults %{
    "pagination" => 50,
    "pagination_users" => 50,
    "pagination_search" => 50,
    "use_paging" => "yes",
    "locked" => "no",
    "css_ressource" => nil,
    "js_ressource" => nil,
    "sort_threads" => "newest-first",
    "sort_messages" => "ascending",
    "standard_view" => "nested-view",
    "max_tags_per_message" => 3,
    "min_tags_per_message" => 1,
    "header_start_index" => 2,
    "editing_enabled" => "yes",
    "edit_until_has_answer" => "yes",
    "max_editable_age" => 10,
    "hide_subjects_unchanged" => "yes",
    "hide_repeating_tags" => "yes",
    "archiver_active" => "yes",
    "archive_by" => "oldest_message",
    "max_threads" => 150,
    "max_messages_per_thread" => 50,
    "max_age_deleted" => 0,
    "max_age_no_archive" => 0,
    "cites_min_age_to_archive" => 2,
    "accept_value" => 15,
    "accept_self_value" => 15,
    "vote_down_value" => -1,
    "vote_up_value" => 10,
    "date_format_index" => "%d.%m.%Y %H:%M",
    "date_format_index_sameday" => "%H:%M",
    "date_format_post" => "%d.%m.%Y %H:%M",
    "date_format_search" => "%d.%m.%Y",
    "date_format_default" => "%d.%m.%Y %H:%M",
    "date_format_date" => "%d.%m.%Y",
    "date_format_blog_index" => "%d. %B %Y",
    "mail_thread_sort" => "ascending",
    "subject_black_list" => "",
    "url_black_list" => "",
    "content_black_list" => "",
    "mathjax_url" => "",
    "min_message_length" => 10,
    "max_message_length" => 12_288,

    # search settings
    "search_forum_relevance" => 1,
    "search_cites_relevance" => 0.9,

    # user settings
    "email" => nil,
    "url" => nil,
    "greeting" => nil,
    "farewell" => nil,
    "signature" => nil,
    "autorefresh" => nil,
    "quote_signature" => "no",
    "show_unread_notifications_in_title" => "no",
    "show_unread_pms_in_title" => "no",
    "show_new_messages_since_last_visit_in_title" => "no",
    "notify_on_new_mail" => "no",
    "notify_on_abonement_activity" => "no",
    "autosubscribe_on_post" => "yes",
    "notify_on_flagged" => "no",
    "notify_on_move" => "no",
    "notify_on_new_thread" => "no",
    "notify_on_mention" => "yes",
    "highlighted_users" => "",
    "highlight_self" => "yes",
    "quote_by_default" => "button",
    "delete_read_notifications" => "yes",
    "open_close_default" => "open",
    "open_close_close_when_read" => "no",
    "own_css_file" => nil,
    "own_js_file" => nil,
    "own_css" => nil,
    "own_js" => nil,
    "mark_suspicious" => "yes",
    "hide_read_threads" => "no",
    "links_white_list" => "",
    "notify_on_cite" => "yes",
    "max_image_filesize" => 2,
    "fold_read_nested" => "no",
    "target_blank_for_posting_links" => "no",
    "mark_nested_read_via_js" => "no"
  }

  @user_config_keys [
    "email",
    "url",
    "jabber_id",
    "twitter_handle",
    "description",
    "greeting",
    "farewell",
    "signature",
    "quote_signature",
    "quote_by_default",
    "show_unread_notifications_in_title",
    "show_unread_pms_in_title",
    "show_new_messages_since_last_visit_in_title",
    "autorefresh",
    "notify_on_new_mail",
    "notify_on_new_thread",
    "autosubscribe_on_post",
    "notify_on_abonement_activity",
    "delete_read_notifications",
    "notify_on_move",
    "notify_on_mention",
    "notify_on_cite",
    "notify_on_flagged",
    "open_close_default",
    "open_close_close_when_read",
    "own_css_file",
    "own_js_file",
    "own_css",
    "own_js",
    "date_format_index",
    "date_format_post",
    "date_format_default",
    "standard_view",
    "fold_read_nested",
    "hide_subjects_unchanged",
    "hide_repeating_tags",
    "hide_repeating_date",
    "mark_suspicious",
    "sort_threads",
    "sort_messages",
    "highlight_self",
    "hide_read_threads",
    "mail_thread_sort",
    "highlighted_users",
    "use_paging",
    "target_blank_for_posting_links",
    "mark_nested_read_via_js"
  ]

  @visible_config [
                    "max_tags_per_message",
                    "min_tags_per_message",
                    "max_image_filesize",
                    "min_message_length",
                    "max_message_length"
                  ] ++ @user_config_keys

  def user_config_keys, do: @user_config_keys

  def visible_config_keys, do: @visible_config

  @doc """
  Returns the default configuration of the forum
  """
  def defaults, do: @defaults

  defp get_val(nil, _), do: nil

  defp get_val(conf, nam) do
    v = conf.options[nam]
    if v == "", do: nil, else: v
  end

  @doc """
  Gets a config value from three different configs: if the value is
  defined in the user config, it returns this value. If not and the
  value is defined in the forum config, it returns this value. If not
  and the value is defined in the global config, it returns this
  value. Returns the default value otherwise.

  ## Parameters

  - confs: a map with the following keys: `:global` containing the
    global configuration, `:forum` containing the configuration of the
    current forum and `:user`, containing the config of the current
    user
  - name: the name of the configuration option
  - user: the current user
  - forum: the current forum

  ## Examples

      iex> get(%{global: %Settings{options: %{"diff_context_lines" => 3}}}, "diff_context_lines")
      3

  """
  def get(confs, name, user \\ nil, forum \\ nil)

  def get(confs, name, nil, nil), do: get_val(confs[:global], name) || @defaults[name]
  def get(confs, name, nil, forum) when not is_nil(forum), do: get_val(confs[:forum], name) || get(confs, name)
  def get(confs, name, user, nil) when not is_nil(user), do: get_val(confs[:user], name) || get(confs, name)
  def get(confs, name, _, _), do: get_val(confs[:user], name) || get_val(confs[:forum], name) || get(confs, name)

  @doc """
  Returns the config value we're searching for with the user
  configuration in respect.

  ## Parameters

  - conn_or_user: The `%Plug.Conn{}` struct of the current request or
    a `%Cforum.Users.User{}` struct
  - name: The name of the configuration option
  - type: the type we expect; currently only `:int` or `:none` is
    supported. If `:int` is specified, we cast the value with
    `String.to_integer/1`
  """
  @spec uconf(User.t() | Plug.Conn.t(), String.t(), :none | :int | :float) :: nil | String.t() | integer() | float()
  def uconf(conn_or_user, name, type \\ :none)
  def uconf(conn, name, :int), do: Helpers.to_int(uconf(conn, name))
  def uconf(conn, name, :float), do: Helpers.to_float(uconf(conn, name))

  def uconf(%User{} = user, name, _) do
    settings = Settings.load_relevant_settings(nil, user)
    confs = map_from_confs(settings)

    get(confs, name, user, nil) || @defaults[name]
  end

  def uconf(%Plug.Conn{} = conn, name, _) do
    confs = map_from_conn(conn)
    get(confs, name, conn.assigns[:current_user], conn.assigns[:current_forum]) || @defaults[name]
  end

  def uconf(%{} = confs, name, _), do: get(confs, name, %User{}, %Forum{}) || @defaults[name]

  @doc """
  Returns the config value we're searching for ignoring the user
  configuration.

  ## Parameters

  - conn_or_forum: The `%Plug.Conn{}` struct of the current request or
    a `%Cforum.Forums.Forum{}` struct
  - name: The name of the configuration option
  - type: the type we expect; currently only `:int` or `:none` is
    supported. If `:int` is specified, we cast the value with
    `String.to_integer/1`
  """
  @spec conf(Setting.t() | Forum.t() | Plug.Conn.t() | conf_map() | nil, String.t(), :none | :int | :float) ::
          nil | String.t() | integer() | float()
  def conf(conn_setting_or_forum, name, type \\ :none)
  def conf(conn_setting_or_forum, name, :int), do: Helpers.to_int(conf(conn_setting_or_forum, name))
  def conf(conn_setting_or_forum, name, :float), do: Helpers.to_float(conf(conn_setting_or_forum, name))

  def conf(nil, name, _), do: @defaults[name]

  def conf(%Setting{} = setting, name, _) do
    confs = %{
      global: setting,
      forum: nil,
      user: nil
    }

    get(confs, name, nil, nil) || @defaults[name]
  end

  def conf(%Forum{} = forum, name, _) do
    settings = Settings.load_relevant_settings(forum, nil)

    confs = %{
      global: List.first(settings),
      forum: Enum.at(settings, 1),
      user: nil
    }

    get(confs, name, nil, forum) || @defaults[name]
  end

  def conf(%Plug.Conn{} = conn, name, _) do
    confs = map_from_conn(conn)
    get(confs, name, nil, conn.assigns[:current_forum]) || @defaults[name]
  end

  def conf(%{} = confs, name, _), do: get(confs, name, nil, %Forum{}) || @defaults[name]

  defp map_from_conn(conn) do
    %{
      global: conn.assigns[:global_config],
      forum: conn.assigns[:forum_config],
      user: conn.assigns[:user_config]
    }
  end

  defp map_from_confs(confs) do
    Enum.reduce(confs, %{}, fn
      conf = %Setting{user_id: nil, forum_id: nil}, acc -> Map.put(acc, :global, conf)
      conf = %Setting{user_id: nil}, acc -> Map.put(acc, :forum, conf)
      conf = %Setting{forum_id: nil}, acc -> Map.put(acc, :user, conf)
    end)
  end

  @spec settings_map(nil | Cforum.Forums.Forum.t(), nil | Cforum.Users.User.t()) :: conf_map()
  def settings_map(forum, user) do
    settings = Settings.load_relevant_settings(forum, user)
    map_from_confs(settings)
  end
end
