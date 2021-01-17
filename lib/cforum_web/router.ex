defmodule CforumWeb.Router do
  use CforumWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)

    plug(CforumWeb.Plug.SecurityHeaders)
    plug(CforumWeb.Plug.RedirectionsPlug)
    plug(CforumWeb.Plug.CurrentUser)
    plug(CforumWeb.Plug.UpdateLastVisit)
    plug(CforumWeb.Plug.RememberMe)
    plug(CforumWeb.Plug.VisibleForums)
    plug(CforumWeb.Plug.LoadSettings)
    plug(CforumWeb.Plug.LoadUserInfoData)
    plug(CforumWeb.Plug.SetViewAll)
    plug(CforumWeb.Plug.SetShowReadThreads)
    plug(CforumWeb.Plug.LoadMotd)
  end

  pipeline :blog do
    plug :put_layout, {CforumWeb.LayoutView, "blog.html"}
    plug(CforumWeb.Plug.Blog)
  end

  pipeline :admins do
    plug(CforumWeb.Plug.EnsureAdmin)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(CforumWeb.Plug.SecurityHeaders)
    plug(CforumWeb.Plug.CurrentUser)
    plug(CforumWeb.Plug.VisibleForums)
    plug(CforumWeb.Plug.LoadSettings)
    plug(CforumWeb.Plug.SetViewAll)
    plug(CforumWeb.Plug.SetShowReadThreads)
  end

  scope "/api", CforumWeb.Api, as: :api do
    pipe_through(:api)

    scope "/v1", V1 do
      get("/users", UserController, :index)
      post("/users", UserController, :index)
      get("/users/:id", UserController, :show)
      get("/users/:id/activity", UserController, :activity)
      get("/tags", TagController, :index)
      get("/badges", BadgeController, :index)
      get("/event/:id", EventController, :show)

      get("/messages/quote", MessageController, :message_quote)

      post("/threads/hide", Threads.InvisibleController, :hide)
      post("/threads/unhide", Threads.InvisibleController, :unhide)
      post("/threads/open", Threads.OpenCloseController, :open)
      post("/threads/close", Threads.OpenCloseController, :close)

      post("/threads/sticky", Threads.AdminController, :sticky, as: nil)
      post("/threads/unsticky", Threads.AdminController, :unsticky, as: nil)
      post("/threads/no-archive", Threads.AdminController, :no_archive, as: nil)
      post("/threads/do-archive", Threads.AdminController, :archive, as: nil)

      post("/messages/mark-read", Messages.MarkReadController, :mark_read)
      post("/messages/mark-unread", Messages.MarkReadController, :mark_unread)
      post("/messages/interesting", Messages.InterestingController, :interesting)
      post("/messages/boring", Messages.InterestingController, :boring)
      post("/messages/subscribe", Messages.SubscriptionController, :subscribe)
      post("/messages/unsubscribe", Messages.SubscriptionController, :unsubscribe)

      post("/messages/delete", Messages.AdminController, :delete)
      post("/messages/restore", Messages.AdminController, :restore)
      post("/messages/no-answer", Messages.AdminController, :no_answer)
      post("/messages/answer", Messages.AdminController, :answer)

      post("/messages/upvote", Messages.VoteController, :upvote)
      post("/messages/downvote", Messages.VoteController, :downvote)
      post("/messages/accept", Messages.AcceptController, :accept)
      post("/messages/unaccept", Messages.AcceptController, :unaccept)

      post("/cites/vote", Cite.VoteController, :vote)

      post("/images", ImageController, :create)
    end
  end

  scope "/", host: "blog." do
    pipe_through([:browser, :blog])

    scope "/", CforumWeb.Blog do
      get "/", IndexController, :index, as: :blog
      get "/feed", IndexController, :old_rss, as: :blog
      get "/feed/rss", IndexController, :index_rss, as: :blog
      get "/feed/atom", IndexController, :index_atom, as: :blog

      get "/:year/:month/:day/:slug", ArticleController, :show, as: nil
      get "/new", ArticleController, :new
      post "/new", ArticleController, :create

      get "/:year/:month/:day/:slug/:mid/edit", CommentController, :edit, as: nil
      post "/:year/:month/:day/:slug/:mid/edit", CommentController, :update, as: nil

      get "/:year/:month/:day/:slug/:mid/new", CommentController, :new, as: nil
      post "/:year/:month/:day/:slug/:mid/new", CommentController, :create, as: nil

      get "/tags/:tag", TagController, :show
    end
  end

  scope "/", CforumWeb do
    pipe_through(:browser)

    scope "/admin", Admin, as: :admin do
      pipe_through(:admins)

      live_dashboard "/dashboard", metrics: CforumWeb.Telemetry, ecto_repos: [Cforum.Repo]

      resources("/users", UserController, except: [:show])
      resources("/forums", ForumController, except: [:show])
      resources("/groups", GroupController, except: [:show])
      resources("/badges", BadgeController, except: [:show])
      resources("/redirections", RedirectionController, except: [:show])
      resources("/events", EventController, except: [:show])
      resources("/search_sections", SearchSectionController, except: [:show])

      get "/advent-calendars", AdventCalendarController, :index_years
      get "/advent-calendars/new", AdventCalendarController, :new
      post "/advent-calendars", AdventCalendarController, :create

      scope "/advent-calendars/:year" do
        resources("/", AdventCalendarController, except: [:show, :new, :create])
      end

      get("/audit", AuditController, :index)

      get("/settings", SettingController, :edit, as: :setting)
      put("/settings", SettingController, :update, as: :setting)
    end

    post("/notifications/batch", NotificationController, :batch_action)

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

    get("/search", SearchController, :show)

    get("/advent", AdventController, :index)
    get("/advent/:year", AdventController, :show)

    scope "/users", Users do
      get("/deletion-started", UserController, :deletion_started)
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

    resources("/images", ImageController, only: [:index, :show, :delete])

    #
    # backward compatibility and redirection routes
    #
    get("/archiv", RedirectorController, :redirect_to_archive)
    get("/archiv/:year", RedirectorController, :redirect_to_year)
    get("/archiv/:year/t:tid", RedirectorController, :redirect_to_thread)
    get("/archiv/:year/:month", RedirectorController, :redirect_to_month)
    get("/archiv/:year/:month/t:tid", RedirectorController, :redirect_to_thread)

    resources("/tags", TagController, as: nil) do
      get("/merge", TagController, :edit_merge, as: nil)
      post("/merge", TagController, :merge, as: nil)

      resources("/synonyms", Tags.SynonymController, only: [:edit, :update, :new, :create, :delete], as: nil)
    end

    scope "/all" do
      get("/", ThreadController, :index, as: nil)

      get("/feeds/atom", ThreadController, :index_atom, as: nil)
      get("/feeds/rss", ThreadController, :index_rss, as: nil)

      get("/unanswered", ThreadController, :index_unanswered, as: nil)
      get("/new", ThreadController, :new, as: nil)
      post("/new", ThreadController, :create, as: nil)

      get("/stats", ForumController, :stats, as: nil)

      post("/mark-all-read", Messages.MarkReadController, :mark_all_read)

      get("/archive", ArchiveController, :years, as: nil)
      get("/:year", ArchiveController, :months, as: nil)
      get("/:year/:month", ArchiveController, :threads, as: nil)

      get("/feeds/atom/:id", ThreadController, :show_atom, as: nil)
      get("/feeds/rss/:id", ThreadController, :show_rss, as: nil)

      get("/:year/:month/:day/:slug", ThreadController, :show, as: nil)

      post("/:year/:month/:day/:slug/mark-read", Messages.MarkReadController, :mark_read, as: nil)

      post("/:year/:month/:day/:slug/hide", Threads.InvisibleController, :hide, as: nil)
      post("/:year/:month/:day/:slug/unhide", Threads.InvisibleController, :unhide, as: nil)

      post("/:year/:month/:day/:slug/open", Threads.OpenCloseController, :open, as: nil)
      post("/:year/:month/:day/:slug/close", Threads.OpenCloseController, :close, as: nil)

      post("/:year/:month/:day/:slug/sticky", Threads.AdminController, :sticky, as: nil)
      post("/:year/:month/:day/:slug/unsticky", Threads.AdminController, :unsticky, as: nil)

      post("/:year/:month/:day/:slug/no-archive", Threads.AdminController, :no_archive, as: nil)
      post("/:year/:month/:day/:slug/do-archive", Threads.AdminController, :archive, as: nil)

      get("/:year/:month/:day/:slug/move", Threads.AdminController, :move, as: nil)
      put("/:year/:month/:day/:slug/move", Threads.AdminController, :do_move, as: nil)

      get("/:year/:month/:day/:slug/split", Threads.AdminController, :split, as: nil)
      put("/:year/:month/:day/:slug/split", Threads.AdminController, :do_split, as: nil)

      get("/:year/:month/:day/:slug/:mid", MessageController, :show, as: nil)
      get("/:year/:month/:day/:slug/:mid/new", MessageController, :new, as: nil)
      post("/:year/:month/:day/:slug/:mid/new", MessageController, :create, as: nil)
      get("/:year/:month/:day/:slug/:mid/edit", MessageController, :edit, as: nil)
      put("/:year/:month/:day/:slug/:mid/edit", MessageController, :update, as: nil)
      post("/:year/:month/:day/:slug/:mid/unread", Messages.MarkReadController, :mark_unread, as: nil)

      get("/:year/:month/:day/:slug/:mid/versions", Messages.VersionController, :show, as: nil)
      delete("/:year/:month/:day/:slug/:mid/versions/:id", Messages.VersionController, :delete, as: nil)

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
