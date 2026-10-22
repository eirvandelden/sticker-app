# Represents a child's sticker card toward a reward.
class StickerCard < ApplicationRecord
  belongs_to :child_profile
  has_many :stickers, dependent: :destroy

  before_validation :assign_sticker_goal, on: :create

  validates :sticker_goal, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :only_complete_cards_can_be_rewarded
  before_save :mark_completion_time
  after_save :create_new_card_if_just_completed
  after_save :broadcast_completion
  after_save :broadcast_reward_given
  after_save :broadcast_goal_change

  # Counts the positive stickers on the card.
  # TODO: refactor away
  # @rbs () -> Integer
  def positive_count
    stickers.positive.count
  end

  # Counts the penalties on the card.
  # @rbs () -> Integer
  def negative_count
    stickers.negative.count
  end

  # Returns the positive stickers needed to finish the card, raised by each penalty.
  # @rbs () -> Integer
  def required_stickers
    sticker_goal + negative_count
  end

  # Returns the goal as text, with the penalties added when there are any.
  # @rbs () -> String
  def progress_total_label
    return sticker_goal.to_s if negative_count.zero?

    "#{sticker_goal}+#{negative_count}"
  end

  # Tells whether the card has enough positive stickers.
  # @rbs () -> bool
  def completed?
    positive_count >= required_stickers
  end

  # Tells whether the card is complete and its reward is not yet given.
  # @rbs () -> bool
  def rewardable?
    completed? && !reward_given?
  end

  # Gives the card its own reward goal instead of the child's goal.
  # @rbs (String? new_goal) -> void
  def override_goal!(new_goal)
    update!(goal: new_goal, goal_overridden: true)
  end

  # Completes the card and starts the next one when it has enough stickers.
  # @rbs () -> void
  def check_and_create_next_card_if_completed
    return unless completed?
    return if child_profile.sticker_cards.where("created_at > ?", created_at).any?

    complete_now
  end

  private

  # Copies the child's sticker goal and reward goal onto a new card.
  # @rbs () -> void
  def assign_sticker_goal
    self.sticker_goal = child_profile.sticker_goal
    self.goal = child_profile.goal
  end

  # Validates that only a completed card has its reward given.
  # @rbs () -> void
  def only_complete_cards_can_be_rewarded
    if reward_given? && !completed?
      errors.add(:reward_given, "can't be set unless the card is completed")
    end
  end

  # Stamps the time at which the card first became complete.
  # @rbs () -> void
  def mark_completion_time
    if completed? && completed_at.nil?
      self.completed_at = Time.zone.now
    end
  end

  # Creates the next card when this one has just been completed and has no successor.
  # TODO: split into 2
  # @rbs () -> void
  def create_new_card_if_just_completed
    if saved_change_to_updated_at? &&
       completed? &&
       child_profile.sticker_cards.where("created_at > ?", created_at).none?
      child_profile.sticker_cards.create!
    end
  end

  # Refreshes the cards and flags completion when the card becomes complete.
  # @rbs () -> void
  def broadcast_completion
    return unless saved_change_to_completed_at? && completed?

    child_profile.broadcast_card_refresh
    child_profile.broadcast_completion_flag(card_id: id)
  end

  # Refreshes the cards when the reward is marked as given.
  # @rbs () -> void
  def broadcast_reward_given
    return unless saved_change_to_reward_given? && reward_given?

    child_profile.broadcast_card_refresh
  end

  # Refreshes the cards when the reward goal changes.
  # @rbs () -> void
  def broadcast_goal_change
    return unless saved_change_to_goal?

    child_profile.broadcast_card_refresh
  end

  # Stamps the completion time, or creates the next card if the time is already set.
  # @rbs () -> void
  def complete_now
    return child_profile.sticker_cards.create! if completed_at?

    update!(completed_at: Time.current)
  end
end
