class ChildProfile < ApplicationRecord
  belongs_to :user
  has_many :sticker_cards, dependent: :destroy

  def active_sticker_card
    sticker_cards.order(created_at: :desc).first
  end

  def rewardable_sticker_card
    sticker_cards.where.not(completed_at: nil).where(reward_given: [ nil, false ]).order(completed_at: :asc).first
  end
end
