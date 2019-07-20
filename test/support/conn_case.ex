defmodule CforumWeb.ConnCase do
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

      import Plug.Test
      import Cforum.TestHelpers
      import CforumWeb.Gettext
      import Cforum.Factory

      alias CforumWeb.Router.Helpers, as: Routes
      alias CforumWeb.Views.Helpers.Path

      # The default endpoint for testing
      @endpoint CforumWeb.Endpoint

      # We need a way to get into the connection to login a user
      # We need to use the bypass_through to fire the plugs in the router
      # and get the session fetched.
      def login(%Cforum.Accounts.User{} = user), do: login(build_conn(), user)

      def login(%Plug.Conn{} = conn, user) do
        conn
        |> init_test_session(user_id: user.user_id)
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Cforum.Repo)

    Cachex.clear!(:cforum)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Cforum.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
