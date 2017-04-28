defmodule Cforum.Web.Router do
  use Cforum.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug Guardian.Plug.VerifySession # looks in the session for the token
    plug Guardian.Plug.VerifyRememberMe
    plug Guardian.Plug.LoadResource
    plug Cforum.Plug.CurrentUser
    plug Cforum.Plug.CurrentForum
    plug Cforum.Plug.VisibleForums
    plug Cforum.Plug.LoadSettings
    plug Cforum.Plug.SetViewAll
  end

  pipeline :require_login do
    plug Guardian.Plug.EnsureAuthenticated, handler: Cforum.GuardianErrorHandler
  end

  pipeline :require_admin do
    plug Cforum.Plug.EnsureAdmin
  end

  pipeline :forum_access do
    plug Cforum.Plug.CheckForumAccess
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  scope "/", Cforum.Web do
    pipe_through :browser

    get "/login", Users.SessionController, :new
    post "/login", Users.SessionController, :create
    delete "/logout", Users.SessionController, :delete

    get "/registrations/new", Users.RegistrationController, :new
    post "/registrations", Users.RegistrationController, :create
    get "/registrations/confirm", Users.RegistrationController, :confirm

    get "/", ForumController, :index
    get "/help", PageController, :help

    get "/users/:id/messages", Users.UserController, :show_messages
    get "/users/:id/scores", Users.UserController, :show_scores
    get "/users/:id/votes", Users.UserController, :show_votes
    get "/users/:id/delete", Users.UserController, :confirm_delete

    resources "/users", Users.UserController
    resources "/badges", BadgeController

    scope "/:curr_forum" do
      pipe_through [:browser, :forum_access]

      get "/", ThreadController, :index
      resources "/tags", TagController
    end
  end

  scope "/", Cforum.Web do
    pipe_through [:browser, :require_login]
    resources "/notifications", NotificationController
    resources "/mails", MailController
  end

  scope "/admin", Cforum.Web.Admin, as: :admin do
    pipe_through [:browser, :require_login, :require_admin]
    resources "/forums", ForumController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Cforum do
  #   pipe_through :api
  # end
end
