defmodule CforumWeb.Router do
  use CforumWeb, :router

  # email preview
  if Mix.env() == :dev, do: forward("/sent_emails", Bamboo.EmailPreviewPlug)

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)

    plug(CforumWeb.Plug.CurrentUser)
    plug(CforumWeb.Plug.RememberMe)
    plug(CforumWeb.Plug.VisibleForums)
    # plug(CforumWeb.Plug.ShortcutPlug)
    plug(CforumWeb.Plug.LoadSettings)
    plug(CforumWeb.Plug.LoadUserInfoData)
    plug(CforumWeb.Plug.SetViewAll)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(CforumWeb.Plug.CurrentUser)
  end

  scope "/api", CforumWeb.Api, as: :api do
    pipe_through(:api)

    scope "/v1", V1 do
      get("/users", UserController, :index)
      post("/users", UserController, :index)
      get("/users/:id", UserController, :show)
    end
  end

  scope "/", CforumWeb do
    pipe_through(:browser)

    scope "/admin", Admin, as: :admin do
      resources("/users", UserController, except: [:show])
      resources("/forums", ForumController, except: [:show])
      resources("/groups", GroupController, except: [:show])
      resources("/badges", BadgeController, except: [:show])
      resources("/redirections", RedirectionController, except: [:show])
      resources("/events", EventController, except: [:show])

      get("/audit", AuditController, :index)

      get("/settings", SettingController, :edit, as: :setting)
      put("/settings", SettingController, :update, as: :setting)
    end

    resources "/notifications", NotificationController, only: [:index, :show, :delete] do
      put("/unread", NotificationController, :update_unread, as: :unread)
    end

    resources("/mails", MailController, except: [:edit, :update])
    post("/mails/:id/unread", MailController, :update_unread, as: :mail)

    resources("/events", EventController, only: [:index, :show]) do
      resources("/attendees", Events.AttendeeController, except: [:index, :show])
    end

    get("/invisible", Threads.InvisibleController, :index)
    get("/subscriptions", Messages.SubscriptionController, :index)
    get("/interesting", Messages.InterestingController, :index)

    get("/moderation/open", ModerationController, :index_open)
    resources("/moderation", ModerationController, except: [:new, :create, :delete])

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

    resources("/badges", BadgeController, only: [:index, :show])
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

    scope "/all" do
      get("/", ThreadController, :index, as: nil)

      get("/feeds/atom", ThreadController, :index_atom, as: nil)
      get("/feeds/rss", ThreadController, :index_rss, as: nil)

      get("/unanswered", ThreadController, :index_unanswered, as: nil)
      get("/new", ThreadController, :new, as: nil)
      post("/new", ThreadController, :create, as: nil)

      get("/stats", ForumController, :stats, as: nil)

      resources("/tags", TagController, as: nil) do
        get("/merge", TagController, :edit_merge, as: nil)
        post("/merge", TagController, :merge, as: nil)

        resources("/synonyms", Tags.SynonymController, only: [:edit, :update, :new, :create, :delete], as: nil)
      end

      get("/archive", ArchiveController, :years, as: nil)
      get("/:year", ArchiveController, :months, as: nil)
      get("/:year/:month", ArchiveController, :threads, as: nil)

      get("/feeds/atom/:id", ThreadController, :show_atom, as: nil)
      get("/feeds/rss/:id", ThreadController, :show_rss, as: nil)

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

      post("/:year/:month/:day/:slug/:mid/upvote", Messages.VoteController, :upvote, as: nil)
      post("/:year/:month/:day/:slug/:mid/downvote", Messages.VoteController, :downvote, as: nil)

      post("/:year/:month/:day/:slug/:mid/accept", Messages.AcceptController, :accept, as: nil)
      post("/:year/:month/:day/:slug/:mid/unaccept", Messages.AcceptController, :unaccept, as: nil)

      get("/:year/:month/:day/:slug/:mid/flag", Messages.FlagController, :new, as: nil)
      post("/:year/:month/:day/:slug/:mid/flag", Messages.FlagController, :create, as: nil)

      get("/:year/:month/:day/:slug/:mid/retag", Messages.RetagController, :edit, as: nil)
      post("/:year/:month/:day/:slug/:mid/retag", Messages.RetagController, :update, as: nil)
    end

    get("/m:id", RedirectorController, :redirect_to_message)
  end
end
