defmodule CforumWeb do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use CforumWeb, :controller
      use CforumWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Schema

      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      @timestamps_opts [type: Timex.Ecto.DateTime, autogenerate: {Timex.Ecto.DateTime, :autogenerate, []}]
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: CforumWeb

      alias Cforum.Repo
      import Ecto
      import Ecto.Query

      import CforumWeb.Router.Helpers
      import CforumWeb.Gettext
      import CforumWeb.Views.Helpers
      import CforumWeb.Paginator
      import CforumWeb.Sortable
      import Cforum.Helpers
      import Cforum.ConfigManager

      import CforumWeb.Views.Helpers.Path

      plug(CforumWeb.Plug.LoadResource)
      plug(CforumWeb.Plug.AuthorizeAccess)
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/cforum_web/templates", namespace: CforumWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, get_flash: 2, view_module: 1, action_name: 1, controller_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import CforumWeb.Router.Helpers
      import CforumWeb.ErrorHelpers
      import CforumWeb.Gettext
      import CforumWeb.Views.Helpers
      import CforumWeb.Views.Helpers.Button
      import CforumWeb.Views.Helpers.Links
      import CforumWeb.Views.Helpers.Path
      import CforumWeb.Views.Helpers.RelativeTime
      import CforumWeb.Paginator
      import CforumWeb.Sortable
      import Cforum.Abilities
      import Cforum.Abilities.Helpers
      import Cforum.Helpers
      import Cforum.ConfigManager

      import Number.Delimit
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Cforum.Repo
      import Ecto
      import Ecto.Query
      import CforumWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
