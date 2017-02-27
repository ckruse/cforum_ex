defmodule Cforum.Router do
  use Cforum.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug Guardian.Plug.VerifySession # looks in the session for the token
    plug Guardian.Plug.LoadResource
    plug Cforum.Plug.CurrentUser
    plug Cforum.Plug.VisibleForums
  end

  pipeline :require_login do
    plug Guardian.Plug.EnsureAuthenticated, handler: Cforum.GuardianErrorHandler
  end

  pipeline :require_admin do
    plug Cforum.Plug.EnsureAdmin
  end
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/", Cforum do
    pipe_through :browser # Use the default browser stack

  scope "/admin", Cforum.Admin, as: :admin do
    pipe_through [:browser, :require_login, :require_admin]
    resources "/forums", ForumController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Cforum do
  #   pipe_through :api
  # end
end
