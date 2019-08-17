defmodule Cforum.Messages.MessageIndexerJob do
  alias Cforum.MarkdownRenderer
  alias Cforum.Forums
  alias Cforum.Threads
  alias Cforum.Messages
  alias Cforum.Threads.Thread
  alias Cforum.Messages.Message
  alias Cforum.Messages.MessageHelpers

  alias Cforum.Search
  alias Cforum.Search.Document

  alias Cforum.ConfigManager

  alias CforumWeb.Views.ViewHelpers.Path

  @spec index_messages([non_neg_integer()]) :: any()
  def index_messages(message_ids) do
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      Enum.each(message_ids, &index_message/1)
    end)
  end

  @spec index_message(integer()) :: any()
  def index_message(message_id) do
    message = Messages.get_message(message_id)

    if is_nil(message) do
      with %Document{} = doc <- Search.get_document_by_reference_id(message_id) do
        Search.delete_document(doc)
      end
    else
      thread = Threads.get_thread!(message.thread_id)
      index_message(thread, message)
    end
  end

  @spec index_message(%Thread{}, %Message{}) :: any()
  def index_message(%Thread{} = thread, %Message{} = msg) do
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      doc = Search.get_document_by_reference_id(msg.message_id)
      plain = plain_content(msg)
      forum = Forums.get_forum!(msg.forum_id)
      base_relevance = ConfigManager.conf(forum, "search_forum_relevance", :float)
      msg = Cforum.Repo.preload(msg, [:tags])

      section =
        forum.forum_id
        |> Search.get_section_by_forum_id()
        |> maybe_create_section(forum)

      update_document(section, doc, thread, msg, plain, base_relevance)
    end)
  end

  @spec unindex_messages([%Message{} | non_neg_integer()]) :: any()
  def unindex_messages(messages) do
    Cforum.Helpers.AsyncHelper.run_async(fn ->
      messages
      |> Enum.map(fn
        %Message{} = msg -> msg.message_id
        id -> id
      end)
      |> Enum.each(&delete_document/1)
    end)
  end

  defp delete_document(id) do
    doc = Search.get_document_by_reference_id(id)

    if !is_nil(doc),
      do: Search.delete_document(doc)
  end

  @spec rescore_message(%Message{}) :: any()
  def rescore_message(%Message{} = msg) do
    msg = Messages.get_message!(msg.message_id)
    doc = Search.get_document_by_reference_id(msg.message_id)

    if !is_nil(doc) do
      forum = Forums.get_forum!(msg.forum_id)
      base_relevance = ConfigManager.conf(forum, "search_forum_relevance", :float)
      Search.update_document(doc, %{relevance: message_relevance(base_relevance, msg)})
    end
  end

  defp update_document(section, nil, thread, msg, plaintext, base_relevance) do
    search_dict = Application.get_env(:cforum, :search_dict, "english")
    Search.create_document(doc_params(section, thread, msg, plaintext, search_dict, base_relevance))
  end

  defp update_document(section, doc, thread, msg, plaintext, base_relevance) do
    search_dict = Application.get_env(:cforum, :search_dict, "english")
    Search.update_document(doc, doc_params(section, thread, msg, plaintext, search_dict, base_relevance))
  end

  defp maybe_create_section(nil, forum) do
    {:ok, section} =
      Search.create_section(%{name: forum.name, position: -1, forum_id: forum.forum_id, section_type: "forum"})

    section
  end

  defp maybe_create_section(section, _), do: section

  defp message_relevance(base_relevance, message) do
    accept_score =
      if MessageHelpers.accepted?(message),
        do: 0.5,
        else: 0.0

    base_relevance + MessageHelpers.score(message) / 10.0 + accept_score +
      String.to_float("0.0#{message.created_at.year}")
  end

  defp doc_params(section, thread, msg, plaintext, search_dict, base_relevance) do
    %{
      reference_id: msg.message_id,
      forum_id: msg.forum_id,
      search_section_id: section.search_section_id,
      author: msg.author,
      user_id: msg.user_id,
      title: msg.subject,
      content: plaintext,
      url: Path.message_url(CforumWeb.Endpoint, :show, thread, msg),
      relevance: message_relevance(base_relevance, msg),
      lang: search_dict,
      document_created: msg.created_at,
      tags: Enum.map(msg.tags, & &1.tag_name)
    }
  end

  defp plain_content(msg, tries \\ 0)
  defp plain_content(_msg, tries) when tries >= 5, do: raise({:error, :no_plaintext})

  defp plain_content(msg, tries) do
    MarkdownRenderer.to_plain(msg)
  rescue
    _ -> plain_content(msg, tries + 1)
  end
end
