defmodule Cforum.ForumGroupPermissionFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Accounts.ForumGroupPermission

      def forum_group_permission_factory do
        %ForumGroupPermission{permission: "read",
                              forum: build(:forum),
                              group: build(:group)}
      end
    end # quote
  end # defmacro
end
