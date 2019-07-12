defmodule CforumWeb.Admin.SettingController do
  use CforumWeb, :controller

  alias Cforum.Accounts.{Settings, Setting}

  def edit(conn, _params) do
    settings = conn.assigns[:global_config] || %Setting{}
    changeset = Settings.change_setting(settings)
    render(conn, "edit.html", settings: settings, changeset: changeset)
  end

  def update(conn, %{"setting" => %{"options" => setting_params}}) do
    settings = conn.assigns[:global_config] || %Setting{}

    case Settings.update_options(conn.assigns.current_user, settings, setting_params) do
      {:ok, _settings} ->
        conn
        |> put_flash(:info, gettext("Settings updated successfully."))
        |> redirect(to: Path.admin_setting_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", settings: settings, changeset: changeset)
    end
  end

  def allowed?(conn, _, _), do: Abilities.admin?(conn)
end
