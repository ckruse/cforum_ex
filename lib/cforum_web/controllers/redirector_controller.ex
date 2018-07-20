defmodule CforumWeb.RedirectorController do
  use CforumWeb, :controller

  alias Cforum.Forums.{Threads, Messages}

  def redirect_to_archive(conn, _params) do
    redirect(conn, to: archive_path(conn, :years, conn.assigns[:current_forum] || "all"))
  end

  def redirect_to_year(conn, %{"year" => year}) do
    if year =~ ~r/^\d+(_\d+)?$/ do
      year =
        year
        |> String.replace(~r/_\d+$/, "")
        |> String.to_integer()

      redirect(conn, to: archive_path(conn, :months, conn.assigns[:current_forum], {{year, 1, 1}, {12, 0, 0}}))
    else
      conn
      |> put_status(:not_found)
      |> render(CforumWeb.ErrorView, "404.html", error: "Year is invalid")
    end
  end

  def redirect_to_thread(conn, %{"year" => year, "tid" => tid}) do
    threads = Threads.get_threads_by_tid!(conn.assigns[:current_user], tid)

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

    if blank?(t),
      do: render(conn, "redirect_archive_thread.html", threads: threads),
      else: redirect(conn, to: message_path(conn, :show, t, t.message))
  end

  def redirect_to_month(conn, %{"year" => year, "month" => month}) do
    if year =~ ~r/^\d+(_\d+)?$/ && month =~ ~r/^\d+$/ && String.to_integer(month) in 1..12 do
      year = String.replace(year, ~r/_\d+$/, "")
      {:ok, date} = NaiveDateTime.new(String.to_integer(year), String.to_integer(month), 1, 12, 0, 0)

      redirect(conn, to: archive_path(conn, :threads, conn.assigns[:current_forum], date))
    else
      conn
      |> put_status(:not_found)
      |> render(CforumWeb.ErrorView, "404.html", error: "Year or month is invalid")
    end
  end

  def redirect_to_message(conn, %{"id" => _mid}) do
    case Regex.named_captures(~r{^/m(?<mid>\d+)}, conn.request_path) do
      %{"mid" => id} ->
        message = Messages.get_message!(id)

        thread =
          Threads.get_thread!(
            conn.assigns.current_forum,
            conn.assigns.visible_forums,
            conn.assigns.current_user,
            message.thread_id
          )

        redirect(conn, to: message_path(conn, :show, thread, message))

      _ ->
        raise(Phoenix.ActionClauseError, message: "no suitable action found")
    end
  end

  def allowed?(_, _, _), do: true
end
