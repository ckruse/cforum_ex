defmodule Cforum.ConfigManagerTest do
  use Cforum.DataCase

  alias Cforum.ConfigManager

  describe "get w/o existing configs" do
    test "get/4 returns the value from the user config" do
      user = insert(:user)
      settings = insert(:setting, options: %{"pagination" => 10}, user: user)
      assert ConfigManager.get(%{user: settings}, "pagination", user, nil) == 10

      forum = insert(:forum)
      f_settings = insert(:setting, options: %{"pagination" => 20}, forum: forum)
      assert ConfigManager.get(%{user: settings, forum: f_settings}, "pagination", user, forum) == 10

      g_settings = insert(:setting, options: %{"pagination" => 40})

      assert ConfigManager.get(%{user: settings, forum: f_settings, global: g_settings}, "pagination", user, forum) ==
               10
    end

    test "get/4 returns the value from the forum config" do
      forum = insert(:forum)
      settings = insert(:setting, options: %{"pagination" => 20}, forum: forum)
      assert ConfigManager.get(%{forum: settings}, "pagination", nil, forum) == 20

      g_settings = insert(:setting, options: %{"pagination" => 40})
      assert ConfigManager.get(%{forum: settings, global: g_settings}, "pagination", nil, forum) == 20
    end

    test "get/4 returns the value from the global config" do
      settings = insert(:setting, options: %{"pagination" => 30})
      assert ConfigManager.get(%{global: settings}, "pagination") == 30
    end

    test "get/4 returns the value from the default config if there is no config" do
      assert ConfigManager.get(%{}, "pagination") == ConfigManager.defaults()["pagination"]
    end
  end

  describe "get w/ existing configs" do
    setup [:setup_configs]

    test "get/4 returns the value from the user config if it is in the user config", %{
      user: user,
      forum: forum,
      settings: settings
    } do
      assert ConfigManager.get(settings, "pagination", user, forum) == 10
    end

    test "get/4 returns the value from the forum config if it is in the forum config", %{
      user: user,
      forum: forum,
      settings: settings
    } do
      assert ConfigManager.get(settings, "pagination_users", user, forum) == 20
    end

    test "get/4 returns the value from the global config if it is in the global config", %{
      user: user,
      forum: forum,
      settings: settings
    } do
      assert ConfigManager.get(settings, "pagination_search", user, forum) == 20
    end

    test "get/4 returns the value from the default config", %{user: user, forum: forum, settings: settings} do
      assert ConfigManager.get(settings, "sort_threads", user, forum) == "newest-first"
    end
  end

  describe "uconf w/ user" do
    setup [:setup_configs]

    test "uconf/3 returns a value from the user config", %{user: user} do
      assert ConfigManager.uconf(user, "pagination") == 10
    end

    test "uconf/3 does not return a value from the forum config", %{user: user} do
      assert ConfigManager.uconf(user, "pagination_users") == 30
    end

    test "uconf/3 returns a value from the global config", %{user: user} do
      assert ConfigManager.uconf(user, "pagination_search") == 20
    end
  end

  describe "uconf w/ conn" do
    setup [:setup_configs]

    test "uconf/3 returns a value from the user config", %{conn: conn} do
      assert ConfigManager.uconf(conn, "pagination") == 10
    end

    test "uconf/3 returns a value from the forum config", %{conn: conn} do
      assert ConfigManager.uconf(conn, "pagination_users") == 20
    end

    test "uconf/3 returns a value from the global config", %{conn: conn} do
      assert ConfigManager.uconf(conn, "pagination_search") == 20
    end
  end

  defp setup_configs(_) do
    user = insert(:user)
    forum = insert(:forum)

    user_settings = insert(:setting, options: %{"pagination" => 10}, user: user)
    forum_settings = insert(:setting, options: %{"pagination" => 20, "pagination_users" => 20}, forum: forum)

    global_settings =
      insert(:setting, options: %{"pagination" => 30, "pagination_users" => 30, "pagination_search" => 20})

    conn =
      %Plug.Conn{}
      |> Plug.Conn.assign(:global_config, global_settings)
      |> Plug.Conn.assign(:forum_config, forum_settings)
      |> Plug.Conn.assign(:user_config, user_settings)
      |> Plug.Conn.assign(:current_user, user)
      |> Plug.Conn.assign(:current_forum, forum)

    {:ok,
     user: user,
     forum: forum,
     conn: conn,
     settings: %{user: user_settings, forum: forum_settings, global: global_settings}}
  end
end
