class StickerCard < ApplicationRecord
  belongs_to :child_profile
  has_many :stickers, dependent: :destroy

  validate :only_complete_cards_can_be_rewarded
  after_save :create_new_card_if_just_completed

  # TODO: refactor away
  def positive_count
    stickers.positive.count
  end

  def negative_count
    stickers.negative.count
  end

  def required_stickers
    child_profile.sticker_goal + negative_count
  end

  def completed?
    positive_count >= required_stickers
  end

  private

  def only_complete_cards_can_be_rewarded
    if reward_given? && !completed?
      errors.add(:reward_given, "can't be set unless the card is completed")
    end
  end

  # TODO: split into 2
  def create_new_card_if_just_completed
    if saved_change_to_updated_at? &&
       completed? &&
       child_profile.sticker_cards.where("created_at > ?", created_at).none?
      child_profile.sticker_cards.create!
    end
  end
end
