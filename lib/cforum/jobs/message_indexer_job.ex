defmodule Cforum.Jobs.MessageIndexerJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  alias Cforum.Repo

  alias Cforum.MarkdownRenderer
  alias Cforum.Forums
  alias Cforum.Threads
  alias Cforum.Messages
  alias Cforum.Messages.MessageHelpers

  alias Cforum.Search

  alias Cforum.ConfigManager

  alias CforumWeb.Views.ViewHelpers.Path

  def enqueue(thread, message) do
    %{"thread_id" => thread.thread_id, "message_id" => message.message_id}
    |> Cforum.Jobs.MessageIndexerJob.new()
    |> Oban.insert!()
  end

  def enqueue(ids) do
    %{"message_ids" => ids}
    |> Cforum.Jobs.MessageIndexerJob.new()
    |> Oban.insert!()
  end

  @impl Oban.Worker

  def perform(%{"message_id" => mid, "thread_id" => tid}, _) do
    thread = Threads.get_thread!(tid)
    message = Messages.get_message!(mid)
    index_message(thread, message)
  end

  def perform(%{"message_ids" => ids}, _) do
    Enum.each(ids, fn id ->
      message = Messages.get_message(id)
      thread = Threads.get_thread!(message.thread_id)
      index_message(thread, message)
    end)
  end

  def index_message(thread, message) do
    doc = Search.get_document_by_reference_id(message.message_id)

    plain = MarkdownRenderer.to_plain(message)
    forum = Forums.get_forum!(message.forum_id)
    base_relevance = ConfigManager.conf(forum, "search_forum_relevance", :float)
    msg = Repo.preload(message, [:tags])

    section =
      forum.forum_id
      |> Search.get_section_by_forum_id()
      |> maybe_create_section(forum)

    update_document(section, doc, thread, msg, plain, base_relevance)
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

  def message_relevance(base_relevance, message) do
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
end
