defmodule CforumWeb.MessageView do
  use CforumWeb, :view
  use Cforum.Constants

  alias Cforum.Threads.Thread
  alias Cforum.Messages.Message
  alias Cforum.Subscriptions
  alias Cforum.Messages.MessageHelpers

  alias CforumWeb.VotingAreaView

  alias Cforum.Abilities
  alias Cforum.ConfigManager
  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path
  alias CforumWeb.ErrorHelpers

  def first_class(classes, %{first: true}), do: ["first" | classes]
  def first_class(classes, _), do: classes

  def deleted_class(classes, %Message{deleted: true}), do: ["deleted" | classes]
  def deleted_class(classes, _), do: classes

  def classes_from_message(classes, %Message{attribs: %{classes: msg_classes}}), do: [classes | msg_classes]
  def classes_from_message(classes, _), do: classes

  def accepted_class(classes, %Thread{accepted: []}, _), do: classes

  def accepted_class(classes, thread, message) do
    classes = if thread.message.message_id == message.message_id, do: ["has-accepted-answer" | classes], else: classes
    if MessageHelpers.accepted?(message), do: ["accepted-answer" | classes], else: classes
  end

  def header_classes(thread, message, active_message, assigns) do
    []
    |> first_class(assigns)
    |> deleted_class(message)
    |> classes_from_message(message)
    |> accepted_class(thread, message)
    |> Helpers.add_if(active_message && active_message.message_id == message.message_id, "active")
    |> Enum.join(" ")
  end

  defp maybe_put_parent_subscribed(opts, nil), do: opts

  defp maybe_put_parent_subscribed(opts, parent) do
    if parent.attribs[:is_subscribed] do
      Keyword.put(opts, :parent_subscribed, true)
    else
      opts
    end
  end

  def message_tree(conn, thread, parent, messages, opts \\ [show_icons: true]) do
    new_opts =
      opts
      |> Keyword.put(:parent, parent)
      |> maybe_put_parent_subscribed(parent)

    parts =
      Enum.map(messages, fn msg ->
        # TODO classes
        subtree = if Helpers.blank?(msg.messages), do: "", else: message_tree(conn, thread, msg, msg.messages, new_opts)

        [
          {:safe, "<li class=\"cf-message-answers\">"}
          | [
              header(conn, thread, msg, new_opts)
              | [subtree | {:safe, "</li>"}]
            ]
        ]
      end)

    [{:safe, "<ol>"} | [parts | {:safe, "</ol>"}]]
  end

  # TODO day_changed_key(message))
  def message_date_format(true), do: "date_format_index"
  def message_date_format(false), do: "date_format_post"

  def page_title(:show, %{message: msg, conn: conn}) do
    msg.subject <>
      " " <>
      gettext("by") <>
      " " <> msg.author <> ", " <> ViewHelpers.format_date(conn, msg.created_at, message_date_format(false))
  end

  def page_title(action, assigns) when action in [:new, :create],
    do: gettext("new answer to %{name}", name: assigns[:parent].author)

  def page_title(action, %{message: msg}) when action in [:edit, :update],
    do: gettext("edit message “%{subject}” by %{author}", subject: msg.subject, author: msg.author)

  def page_heading(:show, _assigns), do: nil
  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:show, assigns), do: "message-#{assigns[:read_mode]}"
  def body_id(action, _), do: "messages-#{action}"

  def body_classes(:show, assigns) do
    classes = "messages #{assigns[:read_mode]}-view forum-#{Path.forum_slug(assigns[:current_forum])} show"

    if assigns[:thread].archived,
      do: ["archived " | classes],
      else: classes
  end

  def body_classes(action, assigns) do
    classes = "messages forum-#{Path.forum_slug(assigns[:current_forum])} #{action}"

    if assigns[:thread].archived,
      do: ["archived " | classes],
      else: classes
  end

  defp positive_score_class(score) when score >= 0 and score <= 3, do: "positive-score"
  defp positive_score_class(score) when score == 4, do: "positiver-score"
  defp positive_score_class(score) when score > 4, do: "best-score"

  defp negative_score_class(score) when score <= 0 and score >= -3, do: "negative-score"
  defp negative_score_class(score) when score == -4, do: "negativer-score"
  defp negative_score_class(score) when score < -4, do: "negative-bad-score"

  def score_class(classes, %Message{} = message), do: score_class(classes, MessageHelpers.score(message))
  def score_class(classes, score) when score == 0, do: classes
  def score_class(classes, score) when score > 0, do: [positive_score_class(score) | classes]
  def score_class(classes, score) when score < 0, do: [negative_score_class(score) | classes]

  def message_classes(conn, message, thread, active, read_mode \\ :thread) do
    is_folded =
      ConfigManager.uconf(conn, "fold_read_nested") == "yes" && read_mode == :nested && !active && !thread.archived &&
        message.attribs[:is_read]

    []
    |> Helpers.add_if(active, "active")
    |> Helpers.add_if(message.attribs[:is_interesting], "interesting")
    |> Helpers.add_if(Enum.member?(thread.accepted, message), "accepted")
    |> Helpers.add_if(is_folded, "folded")
    |> Helpers.add_if(thread.archived, "archived")
    |> Helpers.add_if(thread.forum.type == "blog" && is_nil(message.parent_id), "cf-weblog-article")
    |> score_class(message)
    |> Enum.join(" ")
  end

  def message_id(msg, opts) do
    if opts[:id],
      do: [{:safe, "id=\""}, opts[:id_prefix] || "", {:safe, "m#{msg.message_id}\""}],
      else: ""
  end

  def header(conn, thread, message, opts \\ []) do
    opts =
      Keyword.merge(
        [
          id: true,
          id_prefix: nil,
          show_icons: false,
          hide_repeating_subjects: true,
          hide_repeating_tags: true,
          author_link_to_message: true,
          tree: true,
          tags: true,
          show_votes: false,
          thread_icons: true,
          rm: nil,
          index: true,
          message_path_helper: &Path.message_path/5
        ],
        opts
      )

    render("header.html", conn: conn, thread: thread, message: message, opts: opts)
  end

  def subject_changed?(_, nil), do: true
  def subject_changed?(msg, parent), do: parent.subject != msg.subject

  def tags_changed?(_, nil), do: true
  def tags_changed?(msg, parent), do: parent.tags != msg.tags

  def show_subject?(true, _, _), do: false

  def show_subject?(parent, message, opts),
    do: (opts[:hide_repeating_subjects] && subject_changed?(message, parent)) || !opts[:hide_repeating_subjects]

  def show_tags?(nil, message, opts), do: !Helpers.blank?(message.tags) && opts[:tags]

  def show_tags?(parent, message, opts),
    do: !Helpers.blank?(message.tags) && opts[:tags] && (!opts[:hide_repeating_tags] || tags_changed?(message, parent))

  def show?(:mail_to_author, cuser, muser) when is_nil(cuser) or is_nil(muser), do: false
  def show?(:mail_to_author, cuser, muser), do: cuser.user_id != muser.user_id

  def original_poster_class(thread, message) do
    if message.message_id != thread.message.message_id && message.user_id == thread.message.user_id,
      do: "original-poster",
      else: ""
  end

  def cite_links(conn, message) do
    message.cites
    |> Enum.map(fn cite ->
      {:safe, link} = link("##{cite.cite_id}", to: Path.cite_path(conn, :show, cite))
      link
    end)
    |> Enum.join(", ")
  end

  defp tags_from_changeset(changeset) do
    case Ecto.Changeset.get_change(changeset, :tags) do
      nil ->
        changeset
        |> Ecto.Changeset.get_field(:tags, [])
        |> Enum.map(&Ecto.Changeset.change(&1))

      changes ->
        changes
    end
  end

  defp tags_and_index_from_changeset(changeset), do: changeset |> tags_from_changeset() |> Enum.with_index()

  defp no_tag_inputs_left(conn, changeset) do
    cnt = length(tags_from_changeset(changeset))
    max = ConfigManager.conf(conn, "max_tags_per_message", :int)

    if cnt >= max,
      do: [],
      else: (cnt + 1)..max
  end

  def author_homepage_rel(message) do
    if Abilities.badge?(message.user_id, @badge_seo_profi) &&
         ConfigManager.uconf(message.user, "norelnofollow") == "yes",
       do: nil,
       else: "rel=\"nofollow\""
  end

  def problematic_site_link(conn, url) do
    if Cforum.ConfigManager.uconf(conn, "target_blank_for_posting_links") == "yes",
      do: link(gettext("problematic site"), to: url, rel: "nofollow noopener noreferrer", target: "_blank"),
      else: link(gettext("problematic site"), to: url, rel: "nofollow noopener noreferrer")
  end

  def l10n_reason("off-topic"), do: gettext("Message is off topic.")

  def l10n_reason("not-constructive"),
    do: gettext("message is unconstructive or provocative and contributes to a deterioration of sentiment")

  def l10n_reason("illegal"), do: gettext("message is illegal")
  def l10n_reason("duplicate"), do: gettext("message is a duplicate of another message")
  def l10n_reason("spam"), do: gettext("message is spam")
  def l10n_reason(custom) when not is_nil(custom) and custom != "", do: custom
  def l10n_reason(_), do: ""

  def show_author?(conn) do
    (Helpers.blank?(conn.assigns[:current_user]) || Abilities.access_forum?(conn, :moderate)) &&
      Helpers.blank?(conn.cookies[:cforum_author])
  end

  def message_assigns(assigns, overwrites \\ %{}) do
    assigns
    |> Map.merge(overwrites)
    |> Map.put_new(:controls, true)
    |> Map.put_new(:enhanced_controls, true)
    |> Map.put_new(:first, false)
    |> Map.put_new(:do_parent, false)
    |> Map.put_new(:message_path_helper, &Path.message_path/5)
  end
end
