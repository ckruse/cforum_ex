defmodule Cforum.ConfigManager do
  import Cforum.Helpers

  @defaults %{
    "pagination" => 50,
    "pagination_users" => 50,
    "pagination_search" => 50,
    "locked" => "no",
    "css_ressource" => nil,
    "js_ressource" => nil,
    "sort_threads" => "newest-first",
    "sort_messages" => "ascending",
    "standard_view" => "nested-view",
    "max_tags_per_message" => 3,
    "min_tags_per_message" => 1,
    "close_vote_votes" => 5,
    "close_vote_action_off-topic" => "close",
    "close_vote_action_not-constructive" => "close",
    "close_vote_action_illegal" => "hide",
    "close_vote_action_duplicate" => "close",
    "close_vote_action_custom" => "close",
    "header_start_index" => 2,
    "editing_enabled" => "yes",
    "edit_until_has_answer" => "yes",
    "max_editable_age" => 10,
    "hide_subjects_unchanged" => "yes",
    "hide_repeating_tags" => "yes",
    "max_threads" => 150,
    "max_messages_per_thread" => 50,
    "cites_min_age_to_archive" => 2,
    "accept_value" => 15,
    "accept_self_value" => 15,
    "vote_down_value" => -1,
    "vote_up_value" => 10,
    "vote_up_value_user" => 10,
    "date_format_index" => "%d.%m.%Y %H:%M",
    "date_format_index_sameday" => "%H:%M",
    "date_format_post" => "%d.%m.%Y %H:%M",
    "date_format_search" => "%d.%m.%Y",
    "date_format_default" => "%d.%m.%Y %H:%M",
    "date_format_date" => "%d.%m.%Y",
    "mail_thread_sort" => "ascending",
    "subject_black_list" => "",
    "content_black_list" => "",

    # search settings
    "search_forum_relevance" => 1,
    "search_cites_relevance" => 0.9,

    # user settings
    "email" => nil,
    "url" => nil,
    "greeting" => nil,
    "farewell" => nil,
    "signature" => nil,
    "flattr" => nil,
    "autorefresh" => 0,
    "quote_signature" => "no",
    "show_unread_notifications_in_title" => "no",
    "show_unread_pms_in_title" => "no",
    "show_new_messages_since_last_visit_in_title" => "no",
    "use_javascript_notifications" => "yes",
    "notify_on_new_mail" => "no",
    "notify_on_abonement_activity" => "no",
    "autosubscribe_on_post" => "yes",
    "notify_on_flagged" => "no",
    "notify_on_open_close_vote" => "no",
    "notify_on_move" => "no",
    "notify_on_new_thread" => "no",
    "notify_on_mention" => "yes",
    "highlighted_users" => "",
    "highlight_self" => "yes",
    "inline_answer" => "yes",
    "quote_by_default" => "no",
    "delete_read_notifications_on_abonements" => "yes",
    "delete_read_notifications_on_mention" => "yes",
    "open_close_default" => "open",
    "open_close_close_when_read" => "no",
    "own_css_file" => nil,
    "own_js_file" => nil,
    "own_css" => nil,
    "own_js" => nil,
    "mark_suspicious" => "yes",
    "page_messages" => "yes",
    "fold_quotes" => "no",
    "live_preview" => "yes",
    "load_messages_via_js" => "yes",
    "hide_read_threads" => "no",
    "links_white_list" => "",
    "notify_on_cite" => "yes",
    "delete_read_notifications_on_cite" => "no",
    "max_image_filesize" => 2,
    "diff_context_lines" => nil
  }

  def defaults, do: @defaults

  defp get_val(nil, _), do: nil

  defp get_val(conf, nam) do
    v = conf.options[nam]
    if v == "", do: nil, else: v
  end

  def get(confs, name, user \\ nil, forum \\ nil)

  def get(confs, name, user, forum) when user == nil and forum == nil,
    do: get_val(confs[:global], name) || @defaults[name]

  def get(confs, name, user, forum) when user == nil and forum != nil,
    do: get_val(confs[:forum], name) || get(confs, name)

  def get(confs, name, user, forum) when forum == nil and user != nil,
    do: get_val(confs[:user], name) || get(confs, name)

  def get(confs, name, _, _), do: get_val(confs[:user], name) || get_val(confs[:forum], name) || get(confs, name)

  def uconf(conn, name, type \\ :none)
  def uconf(conn, name, :int), do: to_int(uconf(conn, name))

  def uconf(%Cforum.Accounts.User{} = user, name, _) do
    settings = Cforum.Accounts.Settings.load_relevant_settings(nil, user)

    confs = %{
      global: List.first(settings),
      forum: nil,
      user: Enum.at(settings, 1)
    }

    get(confs, name, user, nil) || @defaults[name]
  end

  def uconf(%Plug.Conn{} = conn, name, _) do
    confs = map_from_conn(conn)
    get(confs, name, conn.assigns[:current_user], conn.assigns[:current_forum]) || @defaults[name]
  end

  def conf(%Cforum.Forums.Forum{} = forum, name) do
    settings = Cforum.Accounts.Settings.load_relevant_settings(forum, nil)

    confs = %{
      global: List.first(settings),
      forum: Enum.at(settings, 1),
      user: nil
    }

    get(confs, name, nil, forum) || @defaults[name]
  end

  def conf(%Plug.Conn{} = conn, name) do
    confs = map_from_conn(conn)
    get(confs, name, nil, conn.assigns[:current_forum]) || @defaults[name]
  end

  defp map_from_conn(conn) do
    %{
      global: conn.assigns[:global_config],
      forum: conn.assigns[:forum_config],
      user: conn.assigns[:user_config]
    }
  end
end
