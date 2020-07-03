defmodule CforumWeb.ForumView do
  use CforumWeb, :view

  alias Cforum.Abilities
  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def page_title(:index, _), do: gettext("forums")

  def page_title(:stats, %{current_forum: forum}) when not is_nil(forum),
    do: gettext("forum statistics for forum „%{forum}“", forum: forum.name)

  def page_title(:stats, _), do: gettext("forum statistics for all forums")

  def page_heading(:index, _), do: nil
  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _), do: "forums-index"
  def body_id(:stats, _), do: "forums-stats"

  def body_classes(:index, _), do: "forums index"
  def body_classes(:stats, _), do: "forums stats"

  def day_name_last_week() do
    Timex.now()
    |> Timex.subtract(Timex.Duration.from_days(7))
    |> Timex.format!("%A", :strftime)
  end

  def state_heading(:today), do: gettext("state today")
  def state_heading(:last_week), do: gettext("state %{day} last week", day: day_name_last_week())
  def state_heading(:week), do: gettext("state of the last seven days")
  def state_heading(:month), do: gettext("state of the last 30 days")
  def state_heading(:year), do: gettext("state of the last 360 days")

  def stats_json(stats) do
    {:safe,
     stats
     |> Enum.map(fn {mon, threads, messages} ->
       %{mon: Timex.lformat!(mon, "%FT%T%:z", "en", :strftime), threads: threads, messages: messages}
     end)
     |> Jason.encode!()}
  end

  def user_json(users) do
    {:safe,
     users
     |> Enum.map(fn {mon, users} ->
       %{mon: Timex.lformat!(mon, "%FT%T%:z", "en", :strftime), cnt: users}
     end)
     |> Jason.encode!()}
  end

  def posting_date(conn, message) do
    if Timex.diff(Timex.now(), message.created_at, :days) < 1,
      do: Timex.format!(ViewHelpers.local_date(message.created_at), "%H:%M", :strftime),
      else: ViewHelpers.format_date(conn, message.created_at, "date_format_index")
  end

  def non_hidden_forums(forums),
    do: Enum.filter(forums, & &1.visible)
end
