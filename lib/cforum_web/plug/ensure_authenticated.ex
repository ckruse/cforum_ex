# -*- coding: utf-8 -*-

defmodule CforumWeb.Plug.EnsureAuthenticated do
  def init(opts), do: opts

  def call(conn, _) do
    if conn.assigns[:current_user] == nil do
      CforumWeb.ErrorHandler.unauthenticated(conn, conn.params)
    else
      conn
    end
  end
end

# eof
