defmodule CforumWeb.MessageView do
  use CforumWeb, :view

  alias Cforum.Forums.Thread
  alias Cforum.Forums.Message

  def first_class(classes, %{first: true}), do: [classes | ["first"]]
  def first_class(classes, _), do: classes

  def deleted_class(classes, %Message{deleted: true}), do: [classes | ["deleted"]]
  def deleted_class(classes, _), do: classes

  def classes_from_message(classes, %Message{attribs: %{classes: msg_classes}}), do: [classes | [msg_classes]]
  def classes_from_message(classes, _), do: classes

  def accepted_class(classes, %Thread{accepted: []}, _), do: classes

  def accepted_class(classes, thread, message) do
    classes = if thread.message.message_id == message.message_id, do: [classes | ["has-accepted-answer"]], else: classes
    if Message.accepted?(message), do: [classes | ["accepted-answer"]], else: classes
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

  def message_tree(conn, thread, parent, messages, opts \\ [show_icons: true]) do
    parts =
      Enum.map(messages, fn msg ->
        # TODO classes
        subtree = if blank?(msg.messages), do: "", else: message_tree(conn, thread, msg, msg.messages, opts)

        [
          {:safe, "<li>"}
          | [
              render(
                CforumWeb.MessageView,
                "header.html",
                Keyword.merge([conn: conn, thread: thread, parent: parent, message: msg], opts)
              )
              | [subtree | {:safe, "</li>"}]
            ]
        ]
      end)

    [{:safe, "<ol>"} | [parts | {:safe, "</ol>"}]]
  end

  # TODO day_changed_key(message))
  def message_date_format(conn, true), do: date_format(conn, "date_format_index")
  def message_date_format(conn, false), do: date_format(conn, "date_format_post")

  def page_title(:show, assigns) do
    msg = assigns[:message]

    msg.subject <>
      " " <>
      gettext("by") <>
      " " <> msg.author <> ", " <> Timex.format!(msg.created_at, message_date_format(assigns[:conn], false), :strftime)
  end

  def body_id(:show, assigns), do: "message-#{assigns[:read_mode]}"

  def body_classes(:show, assigns) do
    classes = "messages #{assigns[:read_mode]}-view forum-#{forum_slug(assigns[:current_forum])}"
    if assigns[:thread].archived, do: ["archived " | classes], else: classes
  end

  defp forum_slug(nil), do: "all"
  defp forum_slug(forum), do: forum.slug

  defp positive_score_class(score) do
    cond do
      score >= 0 && score <= 3 ->
        "positive-score"

      score == 4 ->
        "positiver-score"

      true ->
        "best-score"
    end
  end

  defp negative_score_class(score) do
    cond do
      score <= 0 && score >= -3 ->
        "negative-score"

      score == -4 ->
        "negativer-score"

      true ->
        "negative-bad-score"
    end
  end

  def score_class(classes, message) do
    score = Message.score(message)

    cond do
      score == 0 ->
        classes

      score > 0 ->
        [positive_score_class(score) | classes]

      score < 0 ->
        [negative_score_class(score) | classes]
    end
  end

  defp class_if_true(classes, true, class), do: [class | classes]
  defp class_if_true(classes, _, _class), do: classes

  def message_classes(conn, message, thread, active, read_mode \\ :thread) do
    is_folded =
      uconf(conn, "fold_read_nested") == "yes" && read_mode == :nested && !active && !thread.archived &&
        Enum.member?(message.attribs[:classes], "visited")

    []
    |> class_if_true(active, "active")
    |> class_if_true(message.attribs[:is_interesting], "interesting")
    |> class_if_true(Enum.member?(thread.accepted, message), "accepted")
    |> class_if_true(is_folded, "folded")
    |> score_class(message)
    |> Enum.join(" ")
  end

  def message_id(msg, opts) do
    if opts[:noid], do: "", else: {:safe, "id=\"#{opts[:id_prefix]}m#{msg.message_id}\""}
  end
end
