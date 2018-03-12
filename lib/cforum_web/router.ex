defmodule CforumWeb.Router do
  use CforumWeb, :router

  # email preview
  if Mix.env() == :dev do
    forward("/sent_emails", Bamboo.EmailPreviewPlug)
  end

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)

    plug(CforumWeb.Plug.CurrentUser)
    plug(CforumWeb.Plug.RememberMe)
    plug(CforumWeb.Plug.CurrentForum)
    plug(CforumWeb.Plug.VisibleForums)
    plug(CforumWeb.Plug.LoadSettings)
    plug(CforumWeb.Plug.LoadUserInfoData)
    plug(CforumWeb.Plug.SetViewAll)
  end

  pipeline :require_login do
    plug(CforumWeb.Plug.EnsureAuthenticated)
  end

  pipeline :require_admin do
    plug(CforumWeb.Plug.EnsureAdmin)
  end

  pipeline :forum_access do
    plug(CforumWeb.Plug.CheckForumAccess)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(CforumWeb.Plug.CurrentUser)
  end

  scope "/", CforumWeb do
    pipe_through([:browser, :require_login])

    resources "/notifications", NotificationController, only: [:index, :show, :delete] do
      put("/unread", NotificationController, :update_unread, as: :unread)
    end

    resources("/mails", MailController, except: [:edit, :update])
    post("/mails/:id/unread", MailController, :update_unread, as: :mail)

    get("/invisible", Threads.InvisibleController, :index)
    get("/subscriptions", Messages.SubscriptionController, :index)
    get("/interesting", Messages.InterestingController, :index)
  end

  scope "/admin", CforumWeb.Admin, as: :admin do
    pipe_through([:browser, :require_login, :require_admin])
    resources("/forums", ForumController)
  end

  scope "/users", CforumWeb.Users do
    pipe_through(:browser)

    get("/users/password", PasswordController, :new)
    post("/users/password", PasswordController, :create)
    get("/users/password/reset", PasswordController, :edit_reset)
    post("/users/password/reset", PasswordController, :update_reset)

    get("/users/:id/messages", UserController, :show_messages)
    get("/users/:id/scores", UserController, :show_scores)
    get("/users/:id/votes", UserController, :show_votes)
    get("/users/:id/delete", UserController, :confirm_delete)

    resources "/", UserController, except: [:new, :create] do
      get("/password", PasswordController, :edit)
      put("/password", PasswordController, :update)
    end
  end

  scope "/", CforumWeb do
    pipe_through(:browser)

    get("/login", Users.SessionController, :new)
    post("/login", Users.SessionController, :create)
    delete("/logout", Users.SessionController, :delete)

    get("/registrations/new", Users.RegistrationController, :new)
    post("/registrations", Users.RegistrationController, :create)
    get("/registrations/confirm", Users.RegistrationController, :confirm)

    get("/", ForumController, :index, as: :root)
    get("/help", PageController, :help)

    resources("/badges", BadgeController)

    scope "/:curr_forum" do
      pipe_through([:forum_access])

      get("/", ThreadController, :index, as: nil)
      get("/new", ThreadController, :new, as: nil)
      post("/new", ThreadController, :create, as: nil)
      resources("/tags", TagController)

      post("/:year/:month/:day/:slug/mark-read", Messages.MarkReadController, :mark_read, as: nil)

      post("/:year/:month/:day/:slug/hide", Threads.InvisibleController, :hide, as: nil)
      post("/:year/:month/:day/:slug/unhide", Threads.InvisibleController, :unhide, as: nil)

      post("/:year/:month/:day/:slug/open", Threads.OpenCloseController, :open, as: nil)
      post("/:year/:month/:day/:slug/close", Threads.OpenCloseController, :close, as: nil)

      get("/:year/:month/:day/:slug/:mid", MessageController, :show, as: nil)
      get("/:year/:month/:day/:slug/:mid/new", MessageController, :new, as: nil)
      post("/:year/:month/:day/:slug/:mid/new", MessageController, :create, as: nil)

      post("/:year/:month/:day/:slug/:mid/subscribe", Messages.SubscriptionController, :subscribe, as: nil)
      post("/:year/:month/:day/:slug/:mid/unsubscribe", Messages.SubscriptionController, :unsubscribe, as: nil)
      post("/:year/:month/:day/:slug/:mid/interesting", Messages.InterestingController, :interesting, as: nil)
      post("/:year/:month/:day/:slug/:mid/boring", Messages.InterestingController, :boring, as: nil)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Cforum do
  #   pipe_through :api
  # end
end
