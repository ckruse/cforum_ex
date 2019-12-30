defmodule Cforum.Jobs.NewMessageBadgeDistributorJob do
  use Oban.Worker, queue: :background, max_attempts: 5

  import Ecto.Query, only: [from: 2]

  alias Cforum.Repo
  alias Cforum.Helpers
  alias Cforum.{Users, Badges}
  alias Cforum.Messages
  alias Cforum.Messages.Message
  alias Cforum.Messages.Votes

  @badges_no_messages [
    {100, "chisel"},
    {1000, "brush"},
    {2500, "quill"},
    {5000, "pen"},
    {7500, "printing_press"},
    {10_000, "typewriter"},
    {20_000, "matrix_printer"},
    {30_000, "inkjet_printer"},
    {40_000, "laser_printer"},
    {50_000, "1000_monkeys"}
  ]

  @impl Oban.Worker
  def perform(%{"message_id" => mid}, _) do
    message = Cforum.Messages.get_message!(mid)
    user = Users.get_user!(message.user_id)

    check_for_message_no_badges(user)

    if Helpers.present?(message.parent_id) do
      parent = Messages.get_message!(message.parent_id)
      check_for_teacher_badge(user, parent)
    end
  end

  defp check_for_message_no_badges(user) do
    no_messages =
      from(m in Message, where: m.user_id == ^user.user_id and m.deleted == false, select: count(m.message_id))
      |> Repo.one()

    @badges_no_messages
    |> Enum.filter(fn {required_messages, _badge_name} -> required_messages <= no_messages end)
    |> Enum.reject(fn {_required_messages, badge_name} -> Users.badge?(user, {:slug, badge_name}, false) end)
    |> Enum.each(fn {_required_messages, badge_name} -> Badges.grant_badge({:slug, badge_name}, user) end)
  end

  defp check_for_teacher_badge(_, %Message{upvotes: v}) when v < 1, do: nil

  defp check_for_teacher_badge(user, parent) do
    vote = Votes.get_vote(parent, user)

    if Helpers.blank?(vote) && parent.user_id != user.user_id && !Users.badge?(user, {:slug, "teacher"}),
      do: Badges.grant_badge({:slug, "teacher"}, user)
  end

  def enqueue(message) do
    if Helpers.present?(message.user_id) do
      %{"message_id" => message.message_id}
      |> Cforum.Jobs.NewMessageBadgeDistributorJob.new()
      |> Oban.insert!()
    end
  end
end
