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

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(CforumWeb.Plug.CurrentUser)
  end

  scope "/", CforumWeb do
    pipe_through(:browser)

    scope "/admin", Admin, as: :admin do
      resources("/users", UserController, except: [:show])
      resources("/forums", ForumController, except: [:show])
      resources("/groups", GroupController, except: [:show])
      resources("/badges", BadgeController, except: [:show])
      resources("/redirections", RedirectionController, except: [:show])

      get("/settings", SettingController, :edit, as: :setting)
      put("/settings", SettingController, :update, as: :setting)
    end

    resources "/notifications", NotificationController, only: [:index, :show, :delete] do
      put("/unread", NotificationController, :update_unread, as: :unread)
    end

    resources("/mails", MailController, except: [:edit, :update])
    post("/mails/:id/unread", MailController, :update_unread, as: :mail)

    get("/invisible", Threads.InvisibleController, :index)
    get("/subscriptions", Messages.SubscriptionController, :index)
    get("/interesting", Messages.InterestingController, :index)

    scope "/users", Users do
      get("/password", PasswordController, :new)
      post("/password", PasswordController, :create)
      get("/password/reset", PasswordController, :edit_reset)
      post("/password/reset", PasswordController, :update_reset)

      get("/:id/messages", UserController, :show_messages)
      get("/:id/scores", UserController, :show_scores)
      get("/:id/votes", UserController, :show_votes)
      get("/:id/delete", UserController, :confirm_delete)

      resources "/", UserController, except: [:new, :create] do
        get("/password", PasswordController, :edit)
        put("/password", PasswordController, :update)
      end
    end

    get("/login", Users.SessionController, :new)
    post("/login", Users.SessionController, :create)
    delete("/logout", Users.SessionController, :delete)

    get("/registrations/new", Users.RegistrationController, :new)
    post("/registrations", Users.RegistrationController, :create)
    get("/registrations/confirm", Users.RegistrationController, :confirm)

    get("/", ForumController, :index, as: :root)
    get("/help", PageController, :help)

    resources("/badges", BadgeController)
    get("/cites/voting", CiteController, :index_voting, as: :cite)
    post("/cites/:id/vote", Cite.VoteController, :vote, as: :cite)
    resources("/cites", CiteController)

    #
    # backward compatibility and redirection routes
    #
    get("/archiv", RedirectorController, :redirect_to_archive)
    get("/archiv/:year", RedirectorController, :redirect_to_year)
    get("/archiv/:year/t:tid", RedirectorController, :redirect_to_thread)
    get("/archiv/:year/:month", RedirectorController, :redirect_to_month)
    get("/archiv/:year/:month/t:tid", RedirectorController, :redirect_to_thread)
    get("/m:id", RedirectorController, :redirect_to_message)

    scope "/:curr_forum" do
      get("/", ThreadController, :index, as: nil)
      get("/new", ThreadController, :new, as: nil)
      post("/new", ThreadController, :create, as: nil)
      resources("/tags", TagController)

      get("/archive", ArchiveController, :years, as: nil)
      get("/:year", ArchiveController, :months, as: nil)
      get("/:year/:month", ArchiveController, :threads, as: nil)

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
  scope "/api", CforumWeb.Api do
    pipe_through(:api)

    scope "/v1", V1 do
      get("/users", UserController, :index)
      post("/users", UserController, :index)
      get("/users/:id", UserController, :show)
    end
  end
end
