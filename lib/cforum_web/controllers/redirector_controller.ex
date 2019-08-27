defmodule CforumWeb.RedirectorController do
  use CforumWeb, :controller

  alias Cforum.Threads
  alias Cforum.Messages
  alias Cforum.ConfigManager
  alias Cforum.Helpers

  def redirect_to_archive(conn, _params) do
    redirect(conn, to: Path.archive_path(conn, :years, conn.assigns[:current_forum]))
  end

  def redirect_to_year(conn, %{"year" => year}) do
    if year =~ ~r/^\d+(_\d+)?$/ do
      year =
        year
        |> String.replace(~r/_\d+$/, "")
        |> String.to_integer()

      redirect(conn, to: Path.archive_path(conn, :months, conn.assigns[:current_forum], {{year, 1, 1}, {12, 0, 0}}))
    else
      conn
      |> put_status(:not_found)
      |> put_view(CforumWeb.ErrorView)
      |> render("404.html", error: "Year is invalid")
    end
  end

  def redirect_to_thread(conn, %{"year" => year, "tid" => tid}) do
    if !Regex.match?(~r/^\d+$/, year) || !Regex.match?(~r/^\d+(?:\.html?)?$/, tid),
      do: raise(Cforum.Errors.NotFoundError, conn: conn)

    threads =
      tid
      |> String.replace_suffix(".htm", "")
      |> String.replace_suffix(".html", "")
      |> Threads.get_threads_by_tid!()
      |> Threads.build_message_trees(ConfigManager.uconf(conn, "sort_messages"))

    year =
      year
      |> String.replace(~r/_\d+$/, "")
      |> String.to_integer()

    t =
      if length(threads) == 1 do
        List.first(threads)
      else
        case Enum.filter(threads, &(&1.created_at.year == year)) do
          [] -> nil
          [thread] -> thread
          _ -> nil
        end
      end

    if Helpers.blank?(t),
      do: render(conn, "redirect_archive_thread.html", threads: threads),
      else: redirect(conn, to: Path.message_path(conn, :show, t, t.message))
  end

  def redirect_to_month(conn, %{"year" => year, "month" => month}) do
    if not valid_params?(year, month),
      do: raise(Cforum.Errors.NotFoundError, conn: conn)

    year = String.replace(year, ~r/_\d+$/, "")
    {:ok, date} = NaiveDateTime.new(String.to_integer(year), String.to_integer(month), 1, 12, 0, 0)

    redirect(conn, to: Path.archive_path(conn, :threads, conn.assigns[:current_forum], date))
  end

  def redirect_to_message(conn, %{"id" => _mid}) do
    case Regex.named_captures(~r{^/m(?<mid>\d+)}, conn.request_path) do
      %{"mid" => id} ->
        message = Messages.get_message!(id)

        thread =
          Threads.get_thread!(conn.assigns.current_forum, conn.assigns.visible_forums, message.thread_id)
          |> Threads.reject_deleted_threads(conn.assigns[:view_all])

        redirect(conn, to: Path.message_path(conn, :show, thread, message))

      _ ->
        raise(Cforum.Errors.NotFoundError, conn: conn)
    end
  end

  defp valid_params?(year, month) do
    Regex.match?(~r/^\d+(_\d+)?$/, year) && Regex.match?(~r/^\d+$/, month) && String.to_integer(month) in 1..12
  end

  def allowed?(_, _, _), do: true
end
