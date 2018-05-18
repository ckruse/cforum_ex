defmodule CforumWeb.LayoutView do
  use CforumWeb, :view

  def page_title(conn, assigns) do
    # try do
    apply(view_module(conn), :page_title, [action_name(conn), assigns]) <> " — SELFHTML Forum"
    # rescue
    #   UndefinedFunctionError -> default_page_title(conn, assigns)
    #   FunctionClauseError -> default_page_title(conn, assigns)
    # end
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

  def additional_js(conn, assigns) do
    try do
      case apply(view_module(conn), :additional_js, [action_name(conn), assigns]) do
        nil ->
          ""

        path ->
          [{:safe, "<script src=\""}, path, {:safe, "\"></script>"}]
      end
    rescue
      UndefinedFunctionError -> ""
      FunctionClauseError -> ""
    end
  end

  def rss_url(conn) do
    case conn.assigns[:current_forum] do
      nil ->
        forum_url(conn, :index, "all") <> ".rss"

      forum ->
        forum_url(conn, :index, forum.slug) <> ".rss"
    end
  end

  def atom_url(conn) do
    case conn.assigns[:current_forum] do
      nil ->
        forum_url(conn, :index, "all") <> ".atom"

      forum ->
        forum_url(conn, :index, forum.slug) <> ".atom"
    end
  end

  def meta_refresh(conn) do
    path = Cforum.Helpers.controller_path(conn)
    action = Phoenix.Controller.action_name(conn)
    refresh = uconf(conn, "autorefresh", :int)

    if path == "thread" and action == :index and refresh > 0 do
      [
        {:safe, "<meta http-equiv=\"refresh\" content=\""},
        Integer.to_string(refresh * 60),
        {:safe, "; URL="},
        forum_url(conn, :index, conn.assigns[:current_forum]),
        {:safe, "\">"}
      ]
    else
      ""
    end
  end

  def own_css(conn) do
    css = uconf(conn, "own_css")

    if blank?(css),
      do: "",
      else: [{:safe, "<style>\n"}, {:safe, css}, {:safe, "\n</style>"}]
  end

  def own_css_file(conn) do
    css = uconf(conn, "own_css_file")

    if blank?(css) do
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
    js = uconf(conn, "own_js")

    if blank?(js),
      do: "",
      else: [{:safe, "<script>\n"}, {:safe, js}, {:safe, "\n</script>"}]
  end

  def own_js_file(conn) do
    js = uconf(conn, "own_js_file")

    if blank?(js),
      do: "",
      else: [{:safe, "<script src=\""}, js, {:safe, "\"></script>"}]
  end

  def css_ressource(conn) do
    css = uconf(conn, "css_ressource")

    if blank?(css) do
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
end
