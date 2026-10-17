# Represents a child and the sticker goal, sticker cards and allowances that belong to them.
class ChildProfile < ApplicationRecord
  belongs_to :user
  has_many :sticker_cards, dependent: :destroy
  has_many :allowances, dependent: :destroy

  after_create :provision_initial_sticker_card
  after_update :sync_active_card_sticker_goal
  after_update :sync_active_card_goal

  validates :sticker_goal, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Returns the newest sticker card, creating one if none exists.
  # @rbs () -> StickerCard
  def active_sticker_card
    sticker_cards.order(created_at: :desc).first || provision_initial_sticker_card
  end

  # Returns the oldest completed card whose reward is not yet given.
  # @rbs () -> StickerCard?
  def rewardable_sticker_card
    # Ordered by created_at, not completed_at: a card only completes after the one
    # before it, so creation order already matches completion order — and unlike
    # completed_at, created_at can't read stale off an already-loaded card.
    sticker_cards.select(&:rewardable?).min_by(&:created_at)
  end

  # Counts the completed cards whose reward is not yet given.
  # @rbs () -> Integer
  def rewardable_sticker_cards_count
    sticker_cards.count(&:rewardable?)
  end

  # Returns the card to show on the dashboard.
  # @rbs () -> StickerCard
  def display_sticker_card
    active_sticker_card
  end

  # Returns the pocket money (zakgeld) allowance, if any.
  # @rbs () -> Allowance?
  def zakgeld
    allowances.detect { |allowance| allowance.kind == "zakgeld" }
  end

  # Returns the clothing money allowance, if any.
  # @rbs () -> Allowance?
  def kleedgeld
    allowances.detect { |allowance| allowance.kind == "kleedgeld" }
  end

  # Replaces the child's card and the parent's card and progress views over Action Cable.
  # @rbs () -> void
  def broadcast_card_refresh
    broadcast_replace_to(
      self,
      target: ActionView::RecordIdentifier.dom_id(self, :card),
      partial: "child/dashboard/card",
      locals: { child_profile: self }
    )
    broadcast_replace_to(
      self,
      target: ActionView::RecordIdentifier.dom_id(self, :parent_card),
      partial: "parent/children/child_card",
      locals: { child: self }
    )
    broadcast_replace_to(
      self,
      target: ActionView::RecordIdentifier.dom_id(self, :dashboard_progress),
      partial: "parent/children/dashboard_progress",
      locals: { child: self }
    )
  end

  # Replaces the completion flag on the child's dashboard over Action Cable.
  # @rbs (card_id: Integer) -> void
  def broadcast_completion_flag(card_id:)
    broadcast_replace_to(
      self,
      target: ActionView::RecordIdentifier.dom_id(self, :completion_flag),
      partial: "child/dashboard/completion_flag",
      locals: { child_profile: self, card_id: card_id }
    )
  end

  private

  # Creates the first sticker card for a new profile.
  # @rbs () -> StickerCard
  def provision_initial_sticker_card
    sticker_cards.create!
  end

  # Copies a changed sticker goal onto the active card.
  # @rbs () -> void
  def sync_active_card_sticker_goal
    return unless saved_change_to_sticker_goal?

    active_sticker_card.update!(sticker_goal: sticker_goal)
  end

  # Copies a changed reward goal onto the active card unless the card has its own goal.
  # @rbs () -> void
  def sync_active_card_goal
    return unless saved_change_to_goal?

    card = active_sticker_card
    card.update!(goal: goal) unless card.goal_overridden?
  end
end
