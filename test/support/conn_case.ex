defmodule Cforum.Web.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias Cforum.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import Cforum.Web.Router.Helpers
      import Cforum.Web.Gettext
      import Cforum.Factory

      # The default endpoint for testing
      @endpoint Cforum.Web.Endpoint


      # We need a way to get into the connection to login a user
      # We need to use the bypass_through to fire the plugs in the router
      # and get the session fetched.
      def login(%Cforum.Accounts.User{} = user), do: login(build_conn(), user, :token, [])
      def login(%Cforum.Accounts.User{} = user, token), do: login(build_conn(), user, token, [])
      def login(%Cforum.Accounts.User{} = user, token, opts), do: login(build_conn(), user, token, opts)

      def login(%Plug.Conn{} = conn, user), do: login(conn, user, :token, [])
      def login(%Plug.Conn{} = conn, user, token), do: login(conn, user, token, [])
      def login(%Plug.Conn{} = conn, user, token, opts) do
        conn
        |> bypass_through(Cforum.Router, [:browser])
        |> get("/")
        |> Guardian.Plug.sign_in(user, token, opts)
        |> send_resp(200, "Flush the session yo")
        |> recycle()
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Cforum.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Cforum.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
