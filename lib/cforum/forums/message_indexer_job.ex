defmodule Cforum.Forums.MessageIndexerJob do
  alias Cforum.MarkdownRenderer
  alias Cforum.Forums
  alias Cforum.Forums.{Messages, Message}
  alias Cforum.Forums.Thread

  alias Cforum.Search
  alias Cforum.Search.Section
  alias Cforum.Search.Document

  alias Cforum.ConfigManager

  alias CforumWeb.Views.Helpers.Path

  @spec index_message(%Thread{}, %Message{}) :: any()
  def index_message(%Thread{} = thread, %Message{} = msg) do
    Task.start(fn ->
      doc = Search.get_document_by_reference_id(msg.message_id)
      plain = MarkdownRenderer.to_plain(msg)
      forum = Forums.get_forum!(msg.forum_id)
      base_relevance = ConfigManager.conf(forum, "search_forum_relevance", :float)

      section =
        forum.forum_id
        |> Search.get_section_by_forum_id()
        |> maybe_create_section(forum)

      update_document(section, doc, thread, msg, plain, base_relevance)
    end)
  end

  @spec unindex_message_with_answers(%Message{}) :: any()
  def unindex_message_with_answers(%Message{} = msg) do
    Task.start(fn ->
      doc = Search.get_document_by_reference_id(msg.message_id)

      if !is_nil(doc),
        do: Search.delete_document(doc)

      Enum.each(msg.messages, &unindex_message_with_answers(&1))
    end)
  end

  def rescore_message(%Message{} = msg) do
    msg = Messages.get_message!(msg.message_id)
    doc = Search.get_document_by_reference_id(msg.message_id)

    if !is_nil(doc) do
      forum = Forums.get_forum!(msg.forum_id)
      base_relevance = ConfigManager.conf(forum, "search_forum_relevance", :float)
      Search.update_document(doc, %{relevance: message_relevance(base_relevance, msg)})
    end
  end

  @spec update_document(%Section{}, %Document{} | nil, %Thread{}, %Message{}, String.t(), float()) ::
          {:ok, %Document{}} | {:error, %Ecto.Changeset{}}
  defp update_document(section, nil, thread, msg, plaintext, base_relevance) do
    search_dict = Application.get_env(:cforum, :search_dict, "english")
    Search.create_document(doc_params(section, thread, msg, plaintext, search_dict, base_relevance))
  end

  defp update_document(section, doc, thread, msg, plaintext, base_relevance) do
    search_dict = Application.get_env(:cforum, :search_dict, "english")
    Search.update_document(doc, doc_params(section, thread, msg, plaintext, search_dict, base_relevance))
  end

  defp maybe_create_section(nil, forum),
    do: Search.create_section(%{name: forum.name, position: -1, forum_id: forum.forum_id, section_type: "forum"})

  defp maybe_create_section(section, _), do: section

  defp message_relevance(base_relevance, message) do
    accept_score =
      if Messages.accepted?(message),
        do: 0.5,
        else: 0.0

    base_relevance + Messages.score(message) / 10.0 + accept_score + String.to_float("0.0#{message.created_at.year}")
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
end
