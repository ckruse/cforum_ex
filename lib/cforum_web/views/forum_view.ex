defmodule CforumWeb.ForumView do
  use CforumWeb, :view

  def page_title(:index, _), do: gettext("forums")

  def page_title(:stats, %{current_forum: forum}) when not is_nil(forum),
    do: gettext("forum statistics for forum „%{forum}“", forum: forum.name)

  def page_title(:stats, _), do: gettext("forum statistics for all forums")

  def page_heading(:stats, assigns), do: page_title(:stats, assigns)

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

  def additional_js(:stats, assigns), do: static_path(assigns[:conn], "/js/stats.js")

  def stats_json(stats) do
    {:safe,
     stats
     |> Enum.map(fn {mon, threads, messages} ->
       %{mon: Timex.lformat!(mon, "%FT%T%:z", "en", :strftime), threads: threads, messages: messages}
     end)
     |> Poison.encode!()}
  end

  def user_json(users) do
    {:safe,
     users
     |> Enum.map(fn {mon, users} ->
       %{mon: Timex.lformat!(mon, "%FT%T%:z", "en", :strftime), cnt: users}
     end)
     |> Poison.encode!()}
  end
end
