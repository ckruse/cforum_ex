defmodule Cforum.AdventCalendarsTest do
  use Cforum.DataCase

  alias Cforum.AdventCalendars

  describe "advent_calendar_days" do
    alias Cforum.AdventCalendars.Day

    test "list_years/0 lists all years with a day" do
      insert(:advent_calendar_day, date: %Date{year: 2019, month: 12, day: 1})
      insert(:advent_calendar_day, date: %Date{year: 2018, month: 12, day: 1})
      assert AdventCalendars.list_years() == ["2018", "2019"]
    end

    test "list_advent_calendar_days/1 returns all advent_calendar_days" do
      day = insert(:advent_calendar_day)
      assert AdventCalendars.list_advent_calendar_days(day.date.year) == [day]
    end

    test "get_day!/1 returns the day with given id" do
      day = insert(:advent_calendar_day)
      assert AdventCalendars.get_day!(day.id) == day
    end

    test "get_day!/1 returns the day with given date" do
      day = insert(:advent_calendar_day)
      assert AdventCalendars.get_day!(day.date) == day
    end

    test "create_day/1 with valid data creates a day" do
      attrs = params_for(:advent_calendar_day)
      assert {:ok, %Day{} = day} = AdventCalendars.create_day(attrs)
      assert day.subject == attrs[:subject]
      assert day.link == attrs[:link]
      assert day.author == attrs[:author]
      assert day.content == attrs[:content]
      assert day.date == attrs[:date]
    end

    test "create_day/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AdventCalendars.create_day(%{})
    end

    test "update_day/2 with valid data updates the day" do
      day = insert(:advent_calendar_day)
      assert {:ok, %Day{} = new_day} = AdventCalendars.update_day(day, %{subject: "Rebellion's on my mind"})
      assert new_day.subject == "Rebellion's on my mind"
      assert new_day.author == day.author
      assert new_day.link == day.link
      assert new_day.content == day.content
      assert new_day.date == day.date
    end

    test "update_day/2 with invalid data returns error changeset" do
      day = insert(:advent_calendar_day)
      assert {:error, %Ecto.Changeset{}} = AdventCalendars.update_day(day, %{date: nil})
      assert day == AdventCalendars.get_day!(day.id)
    end

    test "delete_day/1 deletes the day" do
      day = insert(:advent_calendar_day)
      assert {:ok, %Day{}} = AdventCalendars.delete_day(day)
      assert_raise Ecto.NoResultsError, fn -> AdventCalendars.get_day!(day.id) end
    end

    test "change_day/1 returns a day changeset" do
      day = insert(:advent_calendar_day)
      assert %Ecto.Changeset{} = AdventCalendars.change_day(day)
    end
  end
end
