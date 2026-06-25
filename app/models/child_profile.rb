class ChildProfile < ApplicationRecord
  belongs_to :user
  has_many :sticker_cards, dependent: :destroy

  after_create :provision_initial_sticker_card
  after_update :complete_active_card, if: :saved_change_to_sticker_goal?

  validates :sticker_goal, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def active_sticker_card
    sticker_cards.order(created_at: :desc).first || provision_initial_sticker_card
  end

  def rewardable_sticker_card
    sticker_cards.where.not(completed_at: nil).where(reward_given: [ nil, false ]).order(completed_at: :asc).first
  end

  private

  def complete_active_card
    active_sticker_card.check_and_create_next_card_if_completed
  end

  def provision_initial_sticker_card
    sticker_cards.create!
  end
end
