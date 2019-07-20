defmodule CforumWeb.TagView do
  use CforumWeb, :view

  def page_title(:index, _),
    do: gettext("tags list")

  def page_title(:show, assigns),
    do: gettext("tag “%{tag}”", tag: assigns[:tag].tag_name)

  def page_title(action, assigns) when action in [:edit, :update],
    do: gettext("edit tag “%{tag}”", tag: assigns[:tag].tag_name)

  def page_title(action, _) when action in [:new, :create], do: gettext("create new tag")

  def page_title(action, assigns) when action in [:edit_merge, :merge],
    do: gettext("merge tag %{tag}", tag: assigns[:tag].tag_name)

  def page_heading(action, assigns), do: page_title(action, assigns)

  def body_id(:index, _), do: "tag-index"
  def body_id(:show, _), do: "tag-show"
  def body_id(:new, _), do: "tag-new"
  def body_id(:create, _), do: "tag-create"
  def body_id(:edit, _), do: "tag-edit"
  def body_id(:update, _), do: "tag-update"
  def body_id(:edit_merge, _), do: "tag-edit-merge"
  def body_id(:merge, _), do: "tag-merge"

  def body_classes(:index, _), do: "tag index"
  def body_classes(:show, assigns), do: "tag show #{assigns[:tag].slug}"
  def body_classes(:new, _), do: "tag new"
  def body_classes(:create, _), do: "tag create"
  def body_classes(:edit, assigns), do: "tag edit #{assigns[:tag].slug}"
  def body_classes(:update, assigns), do: "tag update #{assigns[:tag].slug}"
  def body_classes(:edit_merge, assigns), do: "tag edit-merge #{assigns[:tag].slug}"
  def body_classes(:merge, assigns), do: "tag merge #{assigns[:tag].slug}"

  @f_max 4
  @f_min 1

  def font_size(count, min_cnt, max_cnt) do
    divisor = if @f_max - @f_min == 0, do: 1, else: @f_max - @f_min
    constant = :math.log(max_cnt - (min_cnt - 1)) / divisor

    if constant == 0 do
      0
    else
      cnt = count - (min_cnt - 1)
      cnt = if cnt < 0, do: 0, else: cnt
      Float.round(:math.log(cnt) / constant + @f_min, 5)
    end
  end
end
