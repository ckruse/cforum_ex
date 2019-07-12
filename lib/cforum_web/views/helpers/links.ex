defmodule CforumWeb.Views.Helpers.Links do
  @moduledoc """
  Provides button link helpers
  """

  use Phoenix.HTML

  def add_link_flag(conn, flag, value) do
    new_flags =
      (conn.assigns[:_link_flags] || [])
      |> Keyword.put(flag, value)

    Plug.Conn.assign(conn, :_link_flags, new_flags)
  end

  def del_link_flag(conn, flag) do
    new_flags =
      (conn.assigns[:_link_flags] || [])
      |> Keyword.delete(flag)

    Plug.Conn.assign(conn, :_link_flags, new_flags)
  end

  def default_link(opts, do: contents) do
    link(Keyword.update(opts, :class, "cf-btn", &(&1 <> " cf-btn")), do: contents)
  end

  def default_link(text, opts) do
    link(text, Keyword.update(opts, :class, "cf-btn", &(&1 <> " cf-btn")))
  end

  def default_index_link(opts, do: contents) do
    link(Keyword.update(opts, :class, "cf-index-btn", &(&1 <> " cf-index-btn")), do: contents)
  end

  def default_index_link(text, opts) do
    link(text, Keyword.update(opts, :class, "cf-index-btn", &(&1 <> " cf-index-btn")))
  end

  def primary_link(opts, do: contents) do
    link(Keyword.update(opts, :class, "cf-primary-btn", &(&1 <> " cf-primary-btn")), do: contents)
  end

  def primary_link(text, opts) do
    link(text, Keyword.update(opts, :class, "cf-primary-btn", &(&1 <> " cf-primary-btn")))
  end

  def primary_index_link(opts, do: contents) do
    link(Keyword.update(opts, :class, "cf-primary-index-btn", &(&1 <> " cf-primary-index-btn")), do: contents)
  end

  def primary_index_link(text, opts) do
    link(text, Keyword.update(opts, :class, "cf-primary-index-btn", &(&1 <> " cf-primary-index-btn")))
  end

  def destructive_link(opts, do: contents) do
    link(Keyword.update(opts, :class, "cf-destructive-btn", &(&1 <> " cf-destructive-btn")), do: contents)
  end

  def destructive_link(text, opts) do
    link(text, Keyword.update(opts, :class, "cf-destructive-btn", &(&1 <> " cf-destructive-btn")))
  end

  def destructive_index_link(opts, do: contents) do
    link(Keyword.update(opts, :class, "cf-destructive-index-btn", &(&1 <> " cf-destructive-index-btn")), do: contents)
  end

  def destructive_index_link(text, opts) do
    link(text, Keyword.update(opts, :class, "cf-destructive-index-btn", &(&1 <> " cf-destructive-index-btn")))
  end
end
