defmodule CforumWeb.AuditingViewL10n do
  import CforumWeb.Gettext
  alias Cforum.System.Auditing

  # user actions
  def l10n_audit_act(%Auditing{relation: "users", act: "create"}), do: gettext("auditing: create user")
  def l10n_audit_act(%Auditing{relation: "users", act: "update"}), do: gettext("auditing: update user")
  def l10n_audit_act(%Auditing{relation: "users", act: "destroy"}), do: gettext("auditing: destroy user")
  def l10n_audit_act(%Auditing{relation: "users", act: "autodestroy"}), do: gettext("auditing: autodestroy user")
  def l10n_audit_act(%Auditing{relation: "users", act: "confirm"}), do: gettext("auditing: confirm user")
  def l10n_audit_act(%Auditing{relation: "users", act: "badge-gained"}), do: gettext("auditing: user gained badge")

  def l10n_audit_act(%Auditing{relation: "scores", act: "accepted-score"}), do: gettext("auditing: accepted score")

  def l10n_audit_act(%Auditing{relation: "scores", act: "accepted-no-unscore"}),
    do: gettext("auditing: accepted unscore")

  def l10n_audit_act(%Auditing{relation: "messages", act: "accepted-no-unscore"}),
    do: gettext("auditing: accepted unscore")

  def l10n_audit_act(%Auditing{relation: "tags", act: "create"}), do: gettext("auditing: tags: create")
  def l10n_audit_act(%Auditing{relation: "tags", act: "update"}), do: gettext("auditing: tags: update")
  def l10n_audit_act(%Auditing{relation: "tags", act: "destroy"}), do: gettext("auditing: tags: destroy")
  def l10n_audit_act(%Auditing{relation: "tags", act: "merge"}), do: gettext("auditing: tags: merge")

  def l10n_audit_act(%Auditing{relation: "tag_synonyms", act: "create"}), do: gettext("auditing: tag_synonyms: create")

  def l10n_audit_act(%Auditing{relation: "tag_synonyms", act: "destroy"}),
    do: gettext("auditing: tag_synonyms: destroy")

  def l10n_audit_act(%Auditing{relation: "close_votes", act: "create"}), do: gettext("auditing: close_votes: create")

  def l10n_audit_act(%Auditing{relation: "close_votes", act: "finished"}),
    do: gettext("auditing: close_votes: finished")

  def l10n_audit_act(%Auditing{relation: "close_votes_voters", act: "vote"}),
    do: gettext("auditing: close_votes_voters: vote")

  def l10n_audit_act(%Auditing{relation: "close_votes_voters", act: "unvote"}),
    do: gettext("auditing: close_votes_voters: unvote")

  def l10n_audit_act(%Auditing{relation: "media", act: "create"}), do: gettext("auditing: media: create")
  def l10n_audit_act(%Auditing{relation: "media", act: "destroy"}), do: gettext("auditing: media: destroy")

  def l10n_audit_act(%Auditing{relation: "cites", act: "create"}), do: gettext("auditing: cites: create")
  def l10n_audit_act(%Auditing{relation: "cites", act: "update"}), do: gettext("auditing: cites: update")
  def l10n_audit_act(%Auditing{relation: "cites", act: "destroy"}), do: gettext("auditing: cites: destroy")
  def l10n_audit_act(%Auditing{relation: "cites", act: "archive"}), do: gettext("auditing: cites: archive")
  def l10n_audit_act(%Auditing{relation: "cites", act: "archive-del"}), do: gettext("auditing: cites: archive-del")

  def l10n_audit_act(%Auditing{relation: "events", act: "create"}), do: gettext("auditing: events: create")
  def l10n_audit_act(%Auditing{relation: "events", act: "update"}), do: gettext("auditing: events: update")
  def l10n_audit_act(%Auditing{relation: "events", act: "destroy"}), do: gettext("auditing: events: destroy")

  def l10n_audit_act(%Auditing{relation: "attendees", act: "create"}), do: gettext("auditing: attendees: create")
  def l10n_audit_act(%Auditing{relation: "attendees", act: "update"}), do: gettext("auditing: attendees: update")
  def l10n_audit_act(%Auditing{relation: "attendees", act: "destroy"}), do: gettext("auditing: attendees: destroy")

  def l10n_audit_act(%Auditing{relation: "settings", act: "create"}), do: gettext("auditing: settings: create")
  def l10n_audit_act(%Auditing{relation: "settings", act: "update"}), do: gettext("auditing: settings: update")
  def l10n_audit_act(%Auditing{relation: "settings", act: "destroy"}), do: gettext("auditing: settings: destroy")

  def l10n_audit_act(%Auditing{relation: "forums", act: "create"}), do: gettext("auditing: forums: create")
  def l10n_audit_act(%Auditing{relation: "forums", act: "update"}), do: gettext("auditing: forums: update")
  def l10n_audit_act(%Auditing{relation: "forums", act: "destroy"}), do: gettext("auditing: forums: destroy")

  def l10n_audit_act(%Auditing{relation: "groups", act: "create"}), do: gettext("auditing: groups: create")
  def l10n_audit_act(%Auditing{relation: "groups", act: "update"}), do: gettext("auditing: groups: update")
  def l10n_audit_act(%Auditing{relation: "groups", act: "destroy"}), do: gettext("auditing: groups: destroy")

  def l10n_audit_act(%Auditing{relation: "badges", act: "create"}), do: gettext("auditing: badges: create")
  def l10n_audit_act(%Auditing{relation: "badges", act: "update"}), do: gettext("auditing: badges: update")
  def l10n_audit_act(%Auditing{relation: "badges", act: "destroy"}), do: gettext("auditing: badges: destroy")

  def l10n_audit_act(%Auditing{relation: "badges_users", act: "badge-gained"}),
    do: gettext("auditing: badges_users: gain")

  def l10n_audit_act(%Auditing{relation: "redirections", act: "create"}), do: gettext("auditing: redirections: create")
  def l10n_audit_act(%Auditing{relation: "redirections", act: "update"}), do: gettext("auditing: redirections: update")

  def l10n_audit_act(%Auditing{relation: "redirections", act: "destroy"}),
    do: gettext("auditing: redirections: destroy")

  def l10n_audit_act(%Auditing{relation: "threads", act: "create"}), do: gettext("auditing: threads: create")
  def l10n_audit_act(%Auditing{relation: "threads", act: "destroy"}), do: gettext("auditing: threads: destroy")
  def l10n_audit_act(%Auditing{relation: "threads", act: "archive"}), do: gettext("auditing: threads: archive")
  def l10n_audit_act(%Auditing{relation: "threads", act: "move"}), do: gettext("auditing: threads: move")
  def l10n_audit_act(%Auditing{relation: "threads", act: "sticky"}), do: gettext("auditing: threads: sticky")
  def l10n_audit_act(%Auditing{relation: "threads", act: "unsticky"}), do: gettext("auditing: threads: unsticky")

  def l10n_audit_act(%Auditing{relation: "threads", act: "no-archive-yes"}),
    do: gettext("auditing: threads: no-archive-yes")

  def l10n_audit_act(%Auditing{relation: "threads", act: "no-archive-no"}),
    do: gettext("auditing: threads: no-archive-no")

  def l10n_audit_act(%Auditing{relation: "threads", act: "split"}), do: gettext("auditing: threads: split")

  # message actions
  def l10n_audit_act(%Auditing{relation: "messages", act: "create"}), do: gettext("auditing: messages: create")
  def l10n_audit_act(%Auditing{relation: "messages", act: "update"}), do: gettext("auditing: messages: update")
  def l10n_audit_act(%Auditing{relation: "messages", act: "retag"}), do: gettext("auditing: messages: retag")
  def l10n_audit_act(%Auditing{relation: "messages", act: "delete"}), do: gettext("auditing: messages: delete")
  def l10n_audit_act(%Auditing{relation: "messages", act: "destroy"}), do: gettext("auditing: messages: delete")
  def l10n_audit_act(%Auditing{relation: "messages", act: "restore"}), do: gettext("auditing: messages: restore")
  def l10n_audit_act(%Auditing{relation: "messages", act: "move"}), do: gettext("auditing: messages: move")
  def l10n_audit_act(%Auditing{relation: "messages", act: "unflagged"}), do: gettext("auditing: messages: unflagged")

  def l10n_audit_act(%Auditing{relation: "messages", act: "del_versions"}),
    do: gettext("auditing: messages: del_versions")

  def l10n_audit_act(%Auditing{relation: "messages", act: "accepted-yes"}),
    do: gettext("auditing: messages: accepted-yes")

  def l10n_audit_act(%Auditing{relation: "messages", act: "accepted-no"}),
    do: gettext("auditing: messages: accepted-no")

  def l10n_audit_act(%Auditing{relation: "messages", act: "flagged-off-topic"}),
    do: gettext("auditing: messages: flagged-off-topic")

  def l10n_audit_act(%Auditing{relation: "messages", act: "flagged-not-constructive"}),
    do: gettext("auditing: messages: flagged-not-constructive")

  def l10n_audit_act(%Auditing{relation: "messages", act: "flagged-duplicate"}),
    do: gettext("auditing: messages: flagged-duplicate")

  def l10n_audit_act(%Auditing{relation: "messages", act: "flagged-spam"}),
    do: gettext("auditing: messages: flagged-spam")

  def l10n_audit_act(%Auditing{relation: "messages", act: "flagged-custom"}),
    do: gettext("auditing: messages: flagged-custom")

  def l10n_audit_act(%Auditing{relation: "messages", act: "no-answer-admin-yes"}),
    do: gettext("auditing: messages: no-answer-admin-yes")

  def l10n_audit_act(%Auditing{relation: "messages", act: "no-answer-admin-no"}),
    do: gettext("auditing: messages: no-answer-admin-no")

  def l10n_audit_act(%Auditing{relation: "messages", act: "no-answer"}),
    do: gettext("auditing: messages: no-answer")

  def l10n_audit_act(%Auditing{relation: "messages", act: "flag-no-answer"}),
    do: gettext("auditing: messages: no-answer")

  def l10n_audit_act(%Auditing{relation: "messages", act: "no-answer-no"}),
    do: gettext("auditing: messages: no-answer-no")

  def l10n_audit_act(%Auditing{relation: "messages", act: "unflag-no-answer"}),
    do: gettext("auditing: messages: unflag-no-answer")

  def l10n_audit_act(%Auditing{relation: "message_versions", act: "destroy"}),
    do: gettext("auditing: messages: versions: destroy")

  def l10n_audit_act(%Auditing{relation: "moderation_queue", act: "update"}),
    do: gettext("auditing: moderation_queue: update")

  def l10n_audit_act(log),
    do: raise("unknown entry for relation:#{log.relation}, action:#{log.act}")
end
