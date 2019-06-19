defmodule CforumWeb.LayoutView do
  use CforumWeb, :view

  alias Cforum.Search

  def page_title(conn, assigns) do
    try do
      apply(view_module(conn), :page_title, [action_name(conn), assigns]) <> " – SELFHTML Forum"
    rescue
      UndefinedFunctionError -> default_page_title(conn, assigns)
      FunctionClauseError -> default_page_title(conn, assigns)
    end
  end

  def default_page_title(_conn, _assigns) do
    "SELFHTML Forum"
  end

  def body_classes(conn, assigns) do
    try do
      {:safe, " class=\"#{apply(view_module(conn), :body_classes, [action_name(conn), assigns])}\""}
    rescue
      UndefinedFunctionError -> ""
      FunctionClauseError -> ""
    end
  end

  def body_id(conn, assigns) do
    try do
      {:safe, " id=\"#{apply(view_module(conn), :body_id, [action_name(conn), assigns])}\""}
    rescue
      UndefinedFunctionError -> ""
      FunctionClauseError -> ""
    end
  end

  def page_heading(conn, assigns) do
    try do
      [{:safe, "<h1>"} | [apply(view_module(conn), :page_heading, [action_name(conn), assigns]) | {:safe, "</h1>"}]]
    rescue
      UndefinedFunctionError -> ""
      FunctionClauseError -> ""
    end
  end

  def meta_refresh(conn) do
    path = VHelpers.controller_path(conn)
    action = Phoenix.Controller.action_name(conn)
    refresh = ConfigManager.uconf(conn, "autorefresh", :int)

    if path == "thread" and action == :index and refresh > 0 do
      [
        {:safe, "<meta http-equiv=\"refresh\" content=\""},
        Integer.to_string(refresh * 60),
        {:safe, "; URL="},
        Path.forum_url(conn, :index, conn.assigns[:current_forum]),
        {:safe, "\">"}
      ]
    else
      ""
    end
  end

  def own_css(conn) do
    css = ConfigManager.uconf(conn, "own_css")

    if Helpers.blank?(css),
      do: "",
      else: [{:safe, "<style>\n"}, {:safe, css}, {:safe, "\n</style>"}]
  end

  def own_css_file(conn) do
    css = ConfigManager.uconf(conn, "own_css_file")

    if Helpers.blank?(css) do
      ""
    else
      [
        {:safe, "<link href=\""},
        css,
        {:safe, "\" rel=\"stylesheet\" media=\"all\" title=\"SELFHTML Forum Stylesheet\">"}
      ]
    end
  end

  def own_js(conn) do
    js = ConfigManager.uconf(conn, "own_js")

    if Helpers.blank?(js),
      do: "",
      else: [{:safe, "<script>\n"}, {:safe, js}, {:safe, "\n</script>"}]
  end

  def own_js_file(conn) do
    js = ConfigManager.uconf(conn, "own_js_file")

    if Helpers.blank?(js),
      do: "",
      else: [{:safe, "<script src=\""}, js, {:safe, "\"></script>"}]
  end

  def css_ressource(conn) do
    css = ConfigManager.uconf(conn, "css_ressource")

    if Helpers.blank?(css) do
      ""
    else
      [
        {:safe, "<link href=\""},
        css,
        {:safe, "\" rel=\"stylesheet\" media=\"all\" title=\"SELFHTML Forum Stylesheet\">"}
      ]
    end
  end

  def show?(conn, :archive) do
    Enum.member?(
      [CforumWeb.ThreadController, CforumWeb.MessageController, CforumWeb.ArchiveController],
      controller_module(conn)
    )
  end

  def show?(conn, link) when link in [:events, :badges], do: controller_module(conn) == CforumWeb.ForumController

  def show?(conn, :thread_feeds),
    do: Helpers.present?(conn.assigns[:thread]) && Helpers.present?(conn.assigns[:thread].thread_id)

  def show?(conn, :search), do: controller_module(conn) != CforumWeb.SearchController

  def show?(conn, :sort_links) do
    controller_module(conn) == CforumWeb.ThreadController && Helpers.blank?(conn.assigns[:current_user]) &&
      action_name(conn) not in [:new, :create, :edit, :update]
  end

  def show?(conn, :thread_nested) do
    Helpers.present?(conn.assigns[:message]) && Helpers.present?(conn.assigns[:thread]) &&
      Helpers.present?(conn.assigns[:read_mode]) &&
      Helpers.present?(conn.assigns[:message].message_id)
  end

  @view_all_enabled_controllers [
    CforumWeb.ThreadController,
    CforumWeb.MessageController,
    CforumWeb.Messages.VersionController,
    CforumWeb.ArchiveController
  ]

  def show?(conn, :view_all) do
    Abilities.access_forum?(conn, :moderate) && Enum.member?(@view_all_enabled_controllers, controller_module(conn))
  end

  def show?(conn, :mark_all_read) do
    Helpers.present?(conn.assigns[:threads]) && Helpers.present?(conn.assigns[:current_user]) &&
      controller_module(conn) == CforumWeb.ThreadController
  end

  def sort_link(conn, params),
    do: (conn.assigns[:original_path] || conn.request_path) <> Path.encode_query_string(params)

  def search_changeset(conn) do
    visible_sections = Search.list_visible_search_sections(conn.assigns.visible_forums, "forum")
    Search.search_changeset(visible_sections, %{sections: Enum.map(visible_sections, & &1.search_section_id)})
  end

  def sections(form), do: Ecto.Changeset.get_field(form.source, :sections, [])

  def numeric_infos(conn, %{current_user: user} = assigns) when not is_nil(user) do
    str =
      ""
      |> unread_notifications(ConfigManager.uconf(conn, "show_unread_notifications_in_title"), assigns)
      |> unread_pms(ConfigManager.uconf(conn, "show_unread_pms_in_title"), assigns)
      |> new_messages(ConfigManager.uconf(conn, "show_new_messages_since_last_visit_in_title"), assigns)
      |> String.trim("/")

    if Helpers.present?(str), do: "(#{str}) ", else: ""
  end

  def numeric_infos(_, _), do: ""

  defp unread_notifications(str, "no", _), do: str
  defp unread_notifications(str, "yes", assigns), do: "#{str}#{assigns[:unread_notifications]}"
  defp unread_pms(str, "no", _), do: str
  defp unread_pms(str, "yes", assigns), do: "#{str}/#{assigns[:unread_mails]}"
  defp new_messages(str, "no", _), do: str
  defp new_messages(str, "yes", assigns), do: "#{str}/#{assigns[:unread_messages]}"

  def view_all_link(conn) do
    opts = if conn.assigns[:view_all], do: [], else: [view_all: "yes"]

    path =
      cond do
        controller_module(conn) == CforumWeb.Messages.VersionController ->
          Path.message_version_path(conn, :index, conn.assigns[:thread], conn.assigns[:message], opts)

        Helpers.present?(conn.assigns[:message]) ->
          Path.message_path(conn, :show, conn.assigns[:thread], conn.assigns[:message], opts)

        true ->
          Path.forum_path(conn, :index, conn.assigns[:current_forum], opts)
      end

    if conn.assigns[:view_all],
      do: link(gettext("normal view"), to: path),
      else: link(gettext("administrative view"), to: path)
  end

  def chat_nick_name(conn) do
    nick =
      if conn.assigns[:current_user],
        do: conn.assigns[:current_user].username,
        else: "Guest_" <> Integer.to_string(Enum.random(1..9999))

    Path.encode_query_string(%{"nick" => nick})
  end

  def forum_name(nil), do: gettext("all forums")
  def forum_name(forum), do: forum.name

  def user_id(conn) do
    if conn.assigns[:current_user],
      do: {:safe, " data-user-id=\"#{conn.assigns.current_user.user_id}\""},
      else: ""
  end

  def current_controller(conn) do
    controller_module(conn) |> Atom.to_string() |> String.replace(~r/Elixir\.Cforum(Web)?\./, "")
  end
end
