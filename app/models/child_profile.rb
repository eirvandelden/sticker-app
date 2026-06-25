class ChildProfile < ApplicationRecord
  belongs_to :user
  has_many :sticker_cards, dependent: :destroy

  after_create :provision_initial_sticker_card

  validates :sticker_goal, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def active_sticker_card
    sticker_cards.order(created_at: :desc).first || provision_initial_sticker_card
  end

  def rewardable_sticker_card
    sticker_cards.where.not(completed_at: nil).where(reward_given: [ nil, false ]).order(completed_at: :asc).first
  end

  private

  def provision_initial_sticker_card
    sticker_cards.create!
  end
end
