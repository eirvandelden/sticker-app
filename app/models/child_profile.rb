class ChildProfile < ApplicationRecord
  belongs_to :user
  has_many :sticker_cards, dependent: :destroy
  has_many :allowances, dependent: :destroy

  after_create :provision_initial_sticker_card
  after_update :sync_active_card_sticker_goal, if: :saved_change_to_sticker_goal?
  after_update :sync_active_card_goal, if: :saved_change_to_goal?

  validates :sticker_goal, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def active_sticker_card
    sticker_cards.order(created_at: :desc).first || provision_initial_sticker_card
  end

  def rewardable_sticker_card
    sticker_cards.rewardable.order(completed_at: :asc).first
  end

  # In-memory count against the preloaded association: cheap on parent/children#index,
  # which eager-loads sticker_cards, but only correct if the caller hasn't already
  # completed a card on this same child_profile earlier in the request.
  def rewardable_sticker_cards_count
    sticker_cards.count(&:rewardable?)
  end

  def display_sticker_card
    active_sticker_card
  end

  def zakgeld
    allowances.detect { |allowance| allowance.kind == "zakgeld" }
  end

  def kleedgeld
    allowances.detect { |allowance| allowance.kind == "kleedgeld" }
  end

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
  end

  def broadcast_completion_flag(card_id:)
    broadcast_replace_to(
      self,
      target: ActionView::RecordIdentifier.dom_id(self, :completion_flag),
      partial: "child/dashboard/completion_flag",
      locals: { child_profile: self, card_id: card_id }
    )
  end

  private

  def sync_active_card_sticker_goal
    active_sticker_card.update!(sticker_goal: sticker_goal)
  end

  def sync_active_card_goal
    card = active_sticker_card
    card.update!(goal: goal) unless card.goal_overridden?
  end

  def provision_initial_sticker_card
    sticker_cards.create!
  end
end
