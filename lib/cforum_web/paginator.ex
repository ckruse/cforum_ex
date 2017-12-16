defmodule CforumWeb.Paginator do
  defstruct [:per_page, :page, :params, :all_entries_count, :pages_count, :distance]

  import CforumWeb.Gettext
  alias CforumWeb.Paginator

  use Phoenix.HTML

  def paginate(data_count, opts \\ []) do
    config = Application.get_env(:cforum, :paginator)

    per_page = opts[:per_page] || config[:per_page] || 50
    distance = opts[:distance] || config[:distance] || 3
    page = parse_page(opts[:page])

    %Paginator{
      params: [quantity: per_page, offset: (page - 1) * per_page],
      per_page: per_page,
      page: page,
      all_entries_count: data_count,
      pages_count: pages_count(data_count, per_page),
      distance: distance
    }
  end

  def parse_page(nil), do: 1
  def parse_page(x) when is_bitstring(x), do: parse_page(String.to_integer(x))
  def parse_page(x) when x < 1, do: 1
  def parse_page(x), do: x

  defp pages_count(all_entries_count, per_page) do
    (all_entries_count / per_page) |> Float.ceil() |> round
  end

  def pagination(conn, page, path_helper, opts \\ [])
  def pagination(_conn, %Paginator{pages_count: 1}, _, _), do: ""

  def pagination(conn, page, path_helper, opts) do
    content_tag :nav, class: "cf-pages" do
      content_tag(:h3, gettext("pages"), class: "visually-hidden")

      content_tag :ul do
        [first_tag(path_helper, conn, page, opts), previous_tag(path_helper, conn, page, opts)] ++
          pages_list(conn, page, path_helper, opts) ++
          [next_tag(path_helper, conn, page, opts), last_tag(path_helper, conn, page, opts)]
      end
    end
  end

  defp maybe_disabled(true, opts), do: Keyword.put(opts, :"aria-disabled", "true")
  defp maybe_disabled(_, opts), do: opts

  defp first_tag(path_helper, conn, page, opts) do
    classes = if page.page == 1, do: "first disabled", else: "first"
    label = opts[:first] || gettext("first page")

    content_tag :li, maybe_disabled(page.page == 1, class: classes) do
      page(label, path_helper, conn, 1, opts)
    end
  end

  defp previous_tag(path_helper, conn, page, opts) do
    classes = if page.page == 1, do: "prev disabled", else: "prev"
    p_num = if page.page - 1 < 1, do: 1, else: page.page - 1
    label = opts[:prev] || gettext("previous page")

    content_tag :li, maybe_disabled(page.page - 1 < 1, class: classes) do
      page(label, path_helper, conn, p_num, opts)
    end
  end

  defp next_tag(path_helper, conn, page, opts) do
    classes = if page.page == page.pages_count, do: "next disabled", else: "next"
    p_num = if page.page + 1 > page.pages_count, do: page.pages_count, else: page.page + 1
    label = opts[:next] || gettext("next page")

    content_tag :li, maybe_disabled(page.page + 1 > page.pages_count, class: classes) do
      page(label, path_helper, conn, p_num, opts)
    end
  end

  defp last_tag(path_helper, conn, page, opts) do
    classes = if page.page == page.pages_count, do: "last disabled", else: "last"
    label = opts[:last] || gettext("last page")

    content_tag :li, maybe_disabled(page.page == page.pages_count, class: classes) do
      page(label, path_helper, conn, page.pages_count, opts)
    end
  end

  defp pages_list(conn, page, path_helper, opts) do
    start =
      case page.page - page.distance do
        x when x <= 1 -> []
        _ -> [add_ellipsis()]
      end

    pcount = page.pages_count

    ending =
      case page.page + page.distance do
        x when x >= pcount -> []
        _ -> [add_ellipsis()]
      end

    start ++
      Enum.map(Enum.to_list(pages_list_start(page)..pages_list_end(page)), fn pno ->
        classes = if pno == page.page, do: "active", else: nil

        content_tag :li, class: classes do
          page(Integer.to_string(pno), path_helper, conn, pno, opts)
        end
      end) ++ ending
  end

  defp add_ellipsis() do
    content_tag :li do
      content_tag(:span, "…")
    end
  end

  defp pages_list_start(%Paginator{page: page, distance: distance}) do
    case page - distance do
      x when x < 1 -> 1
      x -> x
    end
  end

  defp pages_list_end(%Paginator{page: page, distance: distance, pages_count: pages_count}) do
    case page + distance do
      x when x > pages_count -> pages_count
      x -> x
    end
  end

  defp page(text, path_helper, conn, page_number, opts) do
    page_param = opts[:page_param] || :p
    params_with_page = Keyword.merge(opts[:url_params] || [], [{page_param, page_number}])
    args = opts[:path_args] || [conn, :index]

    to = apply(path_helper, args ++ [params_with_page])

    if to do
      link(text, to: to)
    else
      content_tag(:a, text)
    end
  end
end
