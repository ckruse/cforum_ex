# -*- coding: utf-8 -*-

defmodule CforumWeb.Plug.EnsureAuthenticated do
  @moduledoc """
  This plug is plugged in pipelines where only signed in users have access (e.g.
  the notifications area). It ensures that the user is signed in and shows a
  403 error page if user isn't signed in.
  """

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
