defmodule CforumWeb.Admin.SettingView do
  use CforumWeb, :view

  def page_title(_, _), do: gettext("settings")
  def page_heading(action, assigns), do: page_title(action, assigns)
  def body_id(:edit, _), do: "admin-settings-edit"
  def body_id(:update), do: "admin-settings-update"
  def body_classes(:edit, _), do: "admin settings edit"
  def body_classes(:update, _), do: "admin settings update"

  def conf_val_or_default(conn, name) do
    if blank?(conn.assigns[:forum]),
      do: Cforum.ConfigManager.defaults()[Atom.to_string(name)],
      else: conf(conn, name)
  end

  def default_value(conn, key) do
    origin = if global_conf?(conn, key), do: gettext("global config"), else: gettext("global default")
    gettext("default value (%{val}, %{origin})", val: humanized(conf_val_or_default(conn, key)), origin: origin)
  end

  def humanized(val) do
    case val do
      "yes" -> gettext("„yes“")
      "no" -> gettext("„no“")
      "nested-view" -> gettext("nested view")
      "thread-view" -> gettext("thread view")
      "newest-first" -> gettext("newest first")
      "ascending" -> gettext("ascending")
      "descending" -> gettext("descending")
      "" -> gettext("empty value")
      nil -> gettext("empty value")
      _ -> val
    end
  end

  def global_conf?(conn, key) do
    cond do
      blank?(conn.assigns[:forum]) ->
        false

      blank?(conn.assigns[:global_config]) ->
        false

      true ->
        Map.has_key?(conn.assigns[:global_config].options, key)
    end
  end

  def default_checkbox(form, settings, key) do
    tag(
      :input,
      name: input_name(form, key),
      value: "_DEFAULT_",
      type: "checkbox",
      checked: blank?(settings.options[Atom.to_string(key)])
    )
  end
end
