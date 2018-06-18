defmodule Cforum.ModerationQueueEntryFactory do
  defmacro __using__(_opts) do
    quote do
      alias Cforum.Forums.ModerationQueueEntry

      def moderation_queue_entry_factory do
        %ModerationQueueEntry{
          cleared: false,
          reported: 1,
          reason: "off-topic"
        }
      end

      def closed_moderation_queue_entry_factory do
        %ModerationQueueEntry{
          cleared: true,
          reported: 1,
          reason: "off-topic",
          closer_name: sequence("Closer "),
          closer_id: build(:user),
          resolution: "delete",
          reason: "Delete this shit!"
        }
      end
    end
  end
end
