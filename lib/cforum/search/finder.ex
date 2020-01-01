defmodule Cforum.Search.Finder do
  import Ecto.Query, warn: false

  alias Cforum.Helpers
  alias Cforum.Repo

  alias Cforum.Search.Document
  alias Cforum.Search.Query

  alias Cforum.Users.User

  @spec count_interesting_messages_results(%User{}, Ecto.Changeset.t()) :: integer()
  def count_interesting_messages_results(current_user, changeset) do
    search_dict = Application.get_env(:cforum, :search_dict, "english")
    query = Query.parse(Ecto.Changeset.get_field(changeset, :term))
    sections = Ecto.Changeset.get_field(changeset, :sections)

    {_, conditions, _, args, args_cnt} =
      {[], [], "", [], 0}
      |> maybe_add_search(query.all, search_dict, "ts_document")
      |> maybe_add_search(query.title, search_dict, "ts_title")
      |> maybe_add_search(query.content, search_dict, "ts_content")
      |> maybe_add_search(query.author, "simple", "ts_author")
      |> maybe_add_search(query.tags, nil, :tags)
      |> add_sections(sections)

    conditions =
      conditions
      |> Enum.map(&"(#{&1})")
      |> Enum.join(" AND ")

    subquery = """
    SELECT COUNT(*) FROM search_documents
      INNER JOIN interesting_messages im ON im.message_id = search_documents.reference_id
        AND im.user_id = $#{args_cnt + 1}
      WHERE #{conditions}
    """

    rslt = Repo.query!(subquery, args ++ [current_user.user_id])
    rslt.rows |> List.first() |> List.first()
  end

  @spec search_interesting_messages(%User{}, Ecto.Changeset.t(), keyword() | map()) :: [%Document{}]
  def search_interesting_messages(current_user, changeset, paging \\ [offset: 0, quantity: 50]) do
    search_dict = Application.get_env(:cforum, :search_dict, "english")
    query = Query.parse(Ecto.Changeset.get_field(changeset, :term))
    sections = Ecto.Changeset.get_field(changeset, :sections)

    {_, conditions, ordering, args, args_cnt} =
      {[], [], "", [], 0}
      |> maybe_add_search(query.all, search_dict, "ts_document")
      |> maybe_add_search(query.title, search_dict, "ts_title")
      |> maybe_add_search(query.content, search_dict, "ts_content")
      |> maybe_add_search(query.author, "simple", "ts_author")
      |> maybe_add_search(query.tags, nil, :tags)
      |> add_sections(sections)
      |> add_result_order("date", query, search_dict, false)

    conditions =
      conditions
      |> Enum.map(&"(#{&1})")
      |> Enum.join(" AND ")

    subquery = """
    SELECT reference_id FROM search_documents
      INNER JOIN interesting_messages im ON im.message_id = search_documents.reference_id
        AND im.user_id = $#{args_cnt + 1}
      WHERE #{conditions}
      ORDER BY #{ordering}
      LIMIT #{paging[:quantity]} OFFSET #{paging[:offset]}
    """

    result = Repo.query!(subquery, args ++ [current_user.user_id])

    message_ids = Enum.map(result.rows, &List.first/1)
    Cforum.Messages.list_messages(message_ids)
  end

  @spec count_subscribed_messages_results(%User{}, Ecto.Changeset.t()) :: integer()
  def count_subscribed_messages_results(current_user, changeset) do
    search_dict = Application.get_env(:cforum, :search_dict, "english")
    query = Query.parse(Ecto.Changeset.get_field(changeset, :term))
    sections = Ecto.Changeset.get_field(changeset, :sections)

    {_, conditions, _, args, args_cnt} =
      {[], [], "", [], 0}
      |> maybe_add_search(query.all, search_dict, "ts_document")
      |> maybe_add_search(query.title, search_dict, "ts_title")
      |> maybe_add_search(query.content, search_dict, "ts_content")
      |> maybe_add_search(query.author, "simple", "ts_author")
      |> maybe_add_search(query.tags, nil, :tags)
      |> add_sections(sections)

    conditions =
      conditions
      |> Enum.map(&"(#{&1})")
      |> Enum.join(" AND ")

    subquery = """
    SELECT COUNT(*) FROM search_documents
      INNER JOIN subscriptions sm ON sm.message_id = search_documents.reference_id
        AND sm.user_id = $#{args_cnt + 1}
      WHERE #{conditions}
    """

    rslt = Repo.query!(subquery, args ++ [current_user.user_id])
    rslt.rows |> List.first() |> List.first()
  end

  @spec search_subscribed_messages(%User{}, Ecto.Changeset.t(), keyword() | map()) :: [%Document{}]
  def search_subscribed_messages(current_user, changeset, paging \\ [offset: 0, quantity: 50]) do
    search_dict = Application.get_env(:cforum, :search_dict, "english")
    query = Query.parse(Ecto.Changeset.get_field(changeset, :term))
    sections = Ecto.Changeset.get_field(changeset, :sections)

    {_, conditions, ordering, args, args_cnt} =
      {[], [], "", [], 0}
      |> maybe_add_search(query.all, search_dict, "ts_document")
      |> maybe_add_search(query.title, search_dict, "ts_title")
      |> maybe_add_search(query.content, search_dict, "ts_content")
      |> maybe_add_search(query.author, "simple", "ts_author")
      |> maybe_add_search(query.tags, nil, :tags)
      |> add_sections(sections)
      |> add_result_order("date", query, search_dict, false)

    conditions =
      conditions
      |> Enum.map(&"(#{&1})")
      |> Enum.join(" AND ")

    subquery = """
    SELECT reference_id FROM search_documents
      INNER JOIN subscriptions sm ON sm.message_id = search_documents.reference_id
        AND sm.user_id = $#{args_cnt + 1}
      WHERE #{conditions}
      ORDER BY #{ordering}
      LIMIT #{paging[:quantity]} OFFSET #{paging[:offset]}
    """

    result = Repo.query!(subquery, args ++ [current_user.user_id])

    message_ids = Enum.map(result.rows, &List.first/1)
    Cforum.Messages.list_messages(message_ids)
  end

  @spec count_results(Ecto.Changeset.t()) :: integer()
  def count_results(changeset) do
    search_dict = Application.get_env(:cforum, :search_dict, "english")
    query = Query.parse(Ecto.Changeset.get_field(changeset, :term))
    sections = Ecto.Changeset.get_field(changeset, :sections)
    start_date = date_from_changeset(changeset, :start_date)
    end_date = date_from_changeset(changeset, :end_date, &Timex.end_of_day/1)

    {_, conditions, _, args, _} =
      {[], [], "", [], 0}
      |> maybe_add_search(query.all, search_dict, "ts_document")
      |> maybe_add_search(query.title, search_dict, "ts_title")
      |> maybe_add_search(query.content, search_dict, "ts_content")
      |> maybe_add_search(query.author, "simple", "ts_author")
      |> maybe_add_search(query.tags, nil, :tags)
      |> add_start_date(start_date)
      |> add_end_date(end_date)
      |> add_sections(sections)

    conditions =
      conditions
      |> Enum.map(&"(#{&1})")
      |> Enum.join(" AND ")

    rslt = Repo.query!("SELECT COUNT(*) FROM search_documents WHERE #{conditions}", args)
    rslt.rows |> List.first() |> List.first()
  end

  @spec search(Ecto.Changeset.t(), keyword() | map()) :: [%Document{}]
  def search(changeset, paging \\ [offset: 0, quantity: 50]) do
    search_dict = Application.get_env(:cforum, :search_dict, "english")
    query = Query.parse(Ecto.Changeset.get_field(changeset, :term))
    sections = Ecto.Changeset.get_field(changeset, :sections)
    start_date = date_from_changeset(changeset, :start_date)
    end_date = date_from_changeset(changeset, :end_date, &Timex.end_of_day/1)
    order = Ecto.Changeset.get_field(changeset, :order)

    {_, sub_conditions, ordering, sub_args, args_cnt} =
      {[], [], "", [], 0}
      |> maybe_add_search(query.all, search_dict, "ts_document")
      |> maybe_add_search(query.title, search_dict, "ts_title")
      |> maybe_add_search(query.content, search_dict, "ts_content")
      |> maybe_add_search(query.author, "simple", "ts_author")
      |> maybe_add_search(query.tags, nil, :tags)
      |> add_start_date(start_date)
      |> add_end_date(end_date)
      |> add_sections(sections)
      |> add_result_order(order, query, search_dict, false)

    sub_conditions =
      sub_conditions
      |> Enum.map(&"(#{&1})")
      |> Enum.join(" AND ")

    subquery = """
    SELECT search_document_id FROM search_documents WHERE #{sub_conditions}
      ORDER BY #{ordering}
      LIMIT #{paging[:quantity]} OFFSET #{paging[:offset]}
    """

    {selects, _, ordering, args, _} =
      {[], [], "", [], args_cnt}
      |> add_rank(query, search_dict)
      |> maybe_add_title(query.all, search_dict, :all)
      |> maybe_add_title(query.title, search_dict, :title)
      |> maybe_add_title(query.content, search_dict, :content)
      |> maybe_add_title(query.author, "simple", :author)
      |> add_result_order(order, query, search_dict, true)

    query = """
    SELECT *, #{Enum.join(selects, ", ")}
    FROM search_documents
    WHERE search_document_id IN (#{subquery})
    ORDER BY #{ordering}
    """

    query
    |> Repo.execute_and_load(
      sub_args ++ args,
      Document,
      &%{
        &2
        | rank: &1["rank"],
          headline_all: &1["headline_all"],
          headline_title: &1["headline_title"],
          headline_content: &1["headline_content"],
          headline_author: &1["headline_author"]
      }
    )
    |> Repo.preload([:search_section, :user])
  end

  defp add_result_order({selects, conditions, _, args, cnt}, "date", _, _, _),
    do: {selects, conditions, "document_created DESC, search_document_id DESC", args, cnt}

  defp add_result_order({selects, conditions, _, args, cnt}, _, _, _, true),
    do: {selects, conditions, "rank DESC, search_document_id DESC", args, cnt}

  defp add_result_order({selects, conditions, _, args, cnt}, _, query, dict, _) do
    {orders, _, _, inner_args, cnt} = add_rank({[], [], "", [], cnt}, query, dict, false)
    order = List.first(orders) <> ", search_document_id DESC"
    {selects, conditions, order, args ++ inner_args, cnt}
  end

  defp add_sections({selects, conditions, order, args, args_cnt}, sections),
    do: {selects, conditions ++ ["search_section_id = ANY($#{args_cnt + 1})"], order, args ++ [sections], args_cnt + 1}

  defp add_start_date({selects, conditions, order, args, args_cnt}, nil),
    do: {selects, conditions, order, args, args_cnt}

  defp add_start_date({selects, conditions, order, args, args_cnt}, start_date),
    do: {selects, conditions ++ ["document_created >= $#{args_cnt + 1}"], order, args ++ [start_date], args_cnt + 1}

  defp add_end_date({selects, conditions, order, args, args_cnt}, nil),
    do: {selects, conditions, order, args, args_cnt}

  defp add_end_date({selects, conditions, order, args, args_cnt}, end_date),
    do: {selects, conditions ++ ["document_created <= $#{args_cnt + 1}"], order, args ++ [end_date], args_cnt + 1}

  defp maybe_add_search(q, %{include: [], exclude: []}, _, _), do: q

  defp maybe_add_search({selects, conditions, order, args, args_cnt}, %{include: includes, exclude: excludes}, _, :tags) do
    includes = Enum.map(includes, &String.downcase/1)
    excludes = Enum.map(excludes, &String.downcase/1)

    {selects, conditions ++ ["tags @> $#{args_cnt + 1}", "NOT tags && $#{args_cnt + 2}"], order,
     args ++ [includes, excludes], args_cnt + 2}
  end

  defp maybe_add_search({selects, conditions, order, args, cnt}, %{include: includes, exclude: excludes}, dict, field) do
    expression = to_tsquery(includes, excludes)
    {selects, conditions ++ ["#{field} @@ to_tsquery('#{dict}', $#{cnt + 1})"], order, args ++ [expression], cnt + 1}
  end

  defp maybe_add_title(q, %{include: [], exclude: []}, _, _), do: q

  @title_config "MaxFragments=3"

  defp maybe_add_title({selects, conditions, order, args, cnt}, %{include: includes, exclude: excludes}, dict, :all) do
    expression = to_tsquery(includes, excludes)

    {selects ++
       [
         "ts_headline('#{dict}', author || ' ' || title || ' ' || content, to_tsquery('#{dict}', $#{cnt + 1}), '#{
           @title_config
         }') AS headline_all"
       ], conditions, order, args ++ [expression], cnt + 1}
  end

  defp maybe_add_title({selects, conditions, order, args, cnt}, %{include: includes, exclude: excludes}, dict, field) do
    name = "headline_#{field}"
    expression = to_tsquery(includes, excludes)

    {selects ++ ["ts_headline('#{dict}', #{field}, to_tsquery('#{dict}', $#{cnt + 1}), '#{@title_config}') AS #{name}"],
     conditions, order, args ++ [expression], cnt + 1}
  end

  defp add_rank({selects, conditions, order, args, args_cnt}, query, dict, aliased \\ true) do
    {rank_str, inner_args, inner_args_cnt} =
      {"relevance", [], args_cnt}
      |> maybe_add_rank(query.all, dict, "ts_document")
      |> maybe_add_rank(query.title, dict, "ts_title")
      |> maybe_add_rank(query.author, "simple", "ts_author")

    sel_alias = if aliased, do: " AS rank", else: ""

    {selects ++ [rank_str <> sel_alias], conditions, order, args ++ inner_args, inner_args_cnt}
  end

  defp maybe_add_rank(s, %{include: [], exclude: []}, _, _), do: s

  defp maybe_add_rank({s, args, cnt}, %{include: includes, exclude: excludes}, dict, field) do
    expression = to_tsquery(includes, excludes)
    {s <> " + ts_rank_cd(#{field}, to_tsquery('#{dict}', $#{cnt + 1}), 32)", args ++ [expression], cnt + 1}
  end

  @spec to_tsquery([String.t()], [String.t()]) :: String.t()
  defp to_tsquery(includes, excludes) do
    includes =
      includes
      |> Enum.map(&ts_term/1)
      |> Enum.filter(&Helpers.present?/1)

    excludes =
      excludes
      |> Enum.map(fn term -> ts_term(term, "!") end)
      |> Enum.filter(&Cforum.Helpers.present?/1)

    Enum.join(includes ++ excludes, " & ")
  end

  @spec date_from_changeset(Ecto.Changeset.t(), atom(), (DateTime.t() -> DateTime.t())) :: DateTime.t() | nil
  defp date_from_changeset(changeset, name, rounding \\ &Timex.beginning_of_day/1) do
    case Ecto.Changeset.get_field(changeset, name) do
      nil ->
        nil

      "" ->
        nil

      value ->
        value
        |> Timex.to_datetime()
        |> rounding.()
    end
  end

  @spec ts_term(String.t(), String.t()) :: String.t()
  defp ts_term(term, prefix \\ "") do
    prefix <>
      if String.last(term) == "*" && term != "*",
        do: db_quote(String.slice(term, 0..-2)) <> ":*",
        else: db_quote(term)
  end

  @spec db_quote(String.t()) :: String.t()
  defp db_quote(term) do
    s =
      term
      |> String.replace("'", "''")
      |> String.replace("\\", "\\\\")

    "'#{s}'"
  end
end
