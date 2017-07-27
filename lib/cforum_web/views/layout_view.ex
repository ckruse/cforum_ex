defmodule CforumWeb.LayoutView do
  use CforumWeb, :view

  def page_title(conn, assigns) do
    try do
      apply(view_module(conn), :page_title, [action_name(conn), assigns]) <> " — SELFHTML Forum"
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
      {:safe, " class=\"" <> apply(view_module(conn), :body_classes, [action_name(conn), assigns]) <> "\""}
    rescue
      UndefinedFunctionError -> ""
      FunctionClauseError -> ""
    end
  end

  def body_id(conn, assigns) do
    try do
      {:safe, " id=\"" <> apply(view_module(conn), :body_id, [action_name(conn), assigns]) <> "\""}
    rescue
      UndefinedFunctionError -> ""
      FunctionClauseError -> ""
    end
  end

  def page_heading(conn, assigns) do
    try do
      "<h1>" <> apply(view_module(conn), :page_heading, [action_name(conn), assigns]) <> "</h1>"
    rescue
      UndefinedFunctionError -> ""
      FunctionClauseError -> ""
    end
  end

  def rss_url(conn) do
    case conn.assigns[:current_forum] do
      nil ->
        thread_url(conn, :index, "all") <> ".rss"
      forum ->
        thread_url(conn, :index, forum.slug) <> ".rss"
    end
  end

  def atom_url(conn) do
    case conn.assigns[:current_forum] do
      nil ->
        thread_url(conn, :index, "all") <> ".atom"
      forum ->
        thread_url(conn, :index, forum.slug) <> ".atom"
    end
  end
end
