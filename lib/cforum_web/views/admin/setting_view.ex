defmodule CforumWeb.Admin.SettingView do
  use CforumWeb, :view

  alias Cforum.ConfigManager
  alias Cforum.Helpers

  alias CforumWeb.Views.ViewHelpers
  alias CforumWeb.Views.ViewHelpers.Path

  def page_title(_, _), do: gettext("settings")
  def page_heading(action, assigns), do: page_title(action, assigns)
  def body_id(:edit, _), do: "admin-settings-edit"
  def body_id(:update), do: "admin-settings-update"
  def body_classes(:edit, _), do: "admin settings edit"
  def body_classes(:update, _), do: "admin settings update"

  def conf_set?(nil, _), do: false
  def conf_set?(settings, key), do: !Helpers.blank?(settings.options[key])

  def conf_val_or_default(conn, name) do
    if Helpers.blank?(conn.assigns[:forum]),
      do: Cforum.ConfigManager.defaults()[Atom.to_string(name)],
      else: ConfigManager.conf(conn, Atom.to_string(name))
  end

  def default_value(conn, key) do
    origin = if global_conf?(conn, key), do: gettext("global config"), else: gettext("global default")
    gettext("default value (%{val}, %{origin})", val: humanized(conf_val_or_default(conn, key)), origin: origin)
  end

  def humanized("yes"), do: gettext("„yes“")
  def humanized("no"), do: gettext("„no“")
  def humanized("nested-view"), do: gettext("nested view")
  def humanized("thread-view"), do: gettext("thread view")
  def humanized("newest-first"), do: gettext("newest first")
  def humanized("ascending"), do: gettext("ascending")
  def humanized("descending"), do: gettext("descending")
  def humanized("close"), do: gettext("close subtree")
  def humanized("hide"), do: gettext("hide („delete“) subtree")
  def humanized(v) when v == "" or is_nil(v), do: gettext("empty value")
  def humanized(val), do: val

  def global_conf?(conn, key) do
    if Helpers.blank?(conn.assigns[:global_config]),
      do: false,
      else: Map.has_key?(conn.assigns[:global_config].options, Atom.to_string(key))
  end

  def default_checkbox(form, settings, key) do
    tag(
      :input,
      name: input_name(form, key),
      value: "_DEFAULT_",
      type: "checkbox",
      checked: !conf_set?(settings, Atom.to_string(key))
    )
  end
end
