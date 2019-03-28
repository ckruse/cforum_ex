defmodule Cforum.Repo.Migrations.DeleteLegacy do
  use Ecto.Migration

  def change do
    drop_if_exists(table(:ar_internal_metadata))
    drop(table(:counter_table))

    execute("DROP TRIGGER messages__count_delete_trigger ON messages")
    execute("DROP TRIGGER messages__count_insert_trigger ON messages")
    execute("DROP TRIGGER messages__count_truncate_trigger ON messages")
    execute("DROP TRIGGER messages__count_update_trigger ON messages")

    execute("DROP TRIGGER threads__count_delete_trigger ON threads")
    execute("DROP TRIGGER threads__count_insert_trigger ON threads")
    execute("DROP TRIGGER threads__count_truncate_trigger ON threads")
    execute("DROP TRIGGER threads__count_update_trigger ON threads")

    execute("DROP TRIGGER messages__count_insert_forum_trigger ON forums")
    execute("DROP TRIGGER threads__count_insert_forum_trigger ON forums")

    execute("DROP FUNCTION counter_table_get_count(v_table_name name, v_group_crit bigint)")
    execute("DROP FUNCTION count_messages_delete_trigger()")
    execute("DROP FUNCTION count_messages_insert_forum_trigger()")
    execute("DROP FUNCTION count_messages_insert_trigger()")
    execute("DROP FUNCTION count_messages_truncate_trigger()")
    execute("DROP FUNCTION count_messages_update_trigger()")
    execute("DROP FUNCTION count_threads_delete_trigger()")
    execute("DROP FUNCTION count_threads_insert_forum_trigger()")
    execute("DROP FUNCTION count_threads_insert_trigger()")
    execute("DROP FUNCTION count_threads_truncate_trigger()")
    execute("DROP FUNCTION count_threads_update_trigger()")
  end
end
