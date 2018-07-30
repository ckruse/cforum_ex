defmodule CforumWeb.MessageView do
  use CforumWeb, :view

  alias Cforum.Forums.{Messages, Thread, Message}
  alias Cforum.Forums.{CloseVotes, CloseVote}
  alias Cforum.Forums.Votes
  alias CforumWeb.Messages.OpenCloseVoteView

  def first_class(classes, %{first: true}), do: ["first" | classes]
  def first_class(classes, _), do: classes

  def deleted_class(classes, %Message{deleted: true}), do: ["deleted" | classes]
  def deleted_class(classes, _), do: classes

  def classes_from_message(classes, %Message{attribs: %{classes: msg_classes}}), do: [classes | msg_classes]
  def classes_from_message(classes, _), do: classes

  def accepted_class(classes, %Thread{accepted: []}, _), do: classes

  def accepted_class(classes, thread, message) do
    classes = if thread.message.message_id == message.message_id, do: ["has-accepted-answer" | classes], else: classes
    if Messages.accepted?(message), do: ["accepted-answer" | classes], else: classes
  end

  # TODO
  def close_vote_class(classes, _), do: classes
  def open_vote_class(classes, _), do: classes

  def header_classes(thread, message, assigns) do
    []
    |> first_class(assigns)
    |> deleted_class(message)
    |> classes_from_message(message)
    |> accepted_class(thread, message)
    |> close_vote_class(message)
    |> open_vote_class(message)
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
        subtree = if blank?(msg.messages), do: "", else: message_tree(conn, thread, msg, msg.messages, new_opts)

        [
          {:safe, "<li>"}
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

  def page_title(:show, assigns) do
    msg = assigns[:message]

    msg.subject <>
      " " <>
      gettext("by") <>
      " " <> msg.author <> ", " <> format_date(assigns[:conn], msg.created_at, message_date_format(false))
  end

  def page_title(action, assigns) when action in [:new, :create],
    do: gettext("new answer to %{name}", name: assigns[:parent].author)

  def page_heading(action, assigns) when action in [:new, :create], do: page_title(action, assigns)

  def body_id(:show, assigns), do: "message-#{assigns[:read_mode]}"

  def body_classes(:show, assigns) do
    classes = "messages #{assigns[:read_mode]}-view forum-#{forum_slug(assigns[:current_forum])}"
    if assigns[:thread].archived, do: ["archived " | classes], else: classes
  end

  defp positive_score_class(score) when score >= 0 and score <= 3, do: "positive-score"
  defp positive_score_class(score) when score == 4, do: "positiver-score"
  defp positive_score_class(score) when score > 4, do: "best-score"

  defp negative_score_class(score) when score <= 0 and score >= -3, do: "negative-score"
  defp negative_score_class(score) when score == -4, do: "negativer-score"
  defp negative_score_class(score) when score < -4, do: "negative-bad-score"

  def score_class(classes, %Message{} = message), do: score_class(classes, Messages.score(message))
  def score_class(classes, score) when score == 0, do: classes
  def score_class(classes, score) when score > 0, do: [positive_score_class(score) | classes]
  def score_class(classes, score) when score < 0, do: [negative_score_class(score) | classes]

  def message_classes(conn, message, thread, active, read_mode \\ :thread) do
    is_folded =
      uconf(conn, "fold_read_nested") == "yes" && read_mode == :nested && !active && !thread.archived &&
        Enum.member?(message.attribs[:classes], "visited")

    []
    |> add_if(active, "active")
    |> add_if(message.attribs[:is_interesting], "interesting")
    |> add_if(Enum.member?(thread.accepted, message), "accepted")
    |> add_if(is_folded, "folded")
    |> score_class(message)
    |> Enum.join(" ")
  end

  def message_id(msg, opts) do
    if opts[:noid], do: "", else: {:safe, "id=\"#{opts[:id_prefix]}m#{msg.message_id}\""}
  end

  def header(conn, thread, message, opts \\ []) do
    opts =
      Keyword.merge(
        [
          noid: false,
          id_prefix: nil,
          show_icons: false,
          hide_repeating_subjects: true,
          hide_repeating_tags: true,
          author_link_to_message: true,
          tree: true,
          tags: true,
          show_votes: false
        ],
        opts
      )

    render("header.html", conn: conn, thread: thread, message: message, opts: opts)
  end

  def std_args(conn, args \\ %{}) do
    local_args =
      %{
        p: conn.params["p"],
        page: conn.params["page"],
        r: controller_path(conn),
        f: forum_slug(conn.assigns[:current_forum])
      }
      |> Enum.filter(fn {_k, v} -> !blank?(v) end)
      |> Enum.into(%{})

    Map.merge(local_args, args)
  end

  def std_args_as_hidden_inputs(conn, args \\ %{}) do
    conn
    |> std_args(args)
    |> Enum.map(fn {k, v} ->
      [{:safe, "<input type=\"hidden\" name=\""}, to_string(k), {:safe, "\" value=\""}, v, {:safe, "\">"}]
    end)
  end

  def subject_changed?(_, nil), do: true
  def subject_changed?(msg, parent), do: parent.subject != msg.subject

  def tags_changed?(_, nil), do: true
  def tags_changed?(msg, parent), do: parent.tags != msg.tags

  def show_subject?(true, _, _), do: false

  def show_subject?(parent, message, opts),
    do: (opts[:hide_repeating_subjects] && subject_changed?(message, parent)) || !opts[:hide_repeating_subjects]

  def show_tags?(nil, message, opts), do: !blank?(message.tags) && opts[:tags]

  def show_tags?(parent, message, opts),
    do: !blank?(message.tags) && opts[:tags] && (!opts[:hide_repeating_tags] || tags_changed?(message, parent))

  def show?(:mail_to_author, cuser, muser) when is_nil(cuser) or is_nil(muser), do: false
  def show?(:mail_to_author, cuser, muser), do: cuser.user_id != muser.user_id

  def original_poster_class(thread, message) do
    if message.message_id != thread.message.message_id && message.user_id == thread.message.user_id,
      do: "original-poster",
      else: ""
  end

  def author_name(conn, thread, message, opts) do
    cond do
      opts[:author_link_to_message] ->
        link(message.author, to: message_path(conn, :show, thread, message), aria: [hidden: "true"])

      !blank?(message.user_id) ->
        link(message.author, to: user_path(conn, :show, message.user_id))

      true ->
        message.author
    end
  end

  def cite_links(conn, message) do
    message.cites
    |> Enum.map(fn cite ->
      {:safe, link} = link("##{cite.cite_id}", to: cite_path(conn, :show, cite))
      link
    end)
    |> Enum.join(", ")
  end

  def new_mail_params(conn, message) do
    %{
      priv_message: %{
        recipient_id: message.user_id,
        subject:
          gettext(
            "regarding your message %{subject} from %{time}",
            subject: message.subject,
            time: format_date(conn, message.created_at, "date_format_post")
          )
      }
    }
  end

  def active_upvoting_button?(message, user) do
    if Votes.upvoted?(message, user), do: " active"
  end

  def active_downvoting_button?(message, user) do
    if Votes.downvoted?(message, user), do: " active"
  end
end
