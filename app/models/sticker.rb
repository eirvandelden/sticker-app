class Sticker < ApplicationRecord
  EMOJI_POOL = %w[⭐ 🌈 🐿️ 💎 🐶 🦄 🧸 🍭 🎈 🎨 🚀 🧁
🍀 🐼]

  belongs_to :sticker_card, touch: true
  belongs_to :giver, class_name: "User", optional: true

  enum :kind, { positive: 0, negative: 1 }

  before_validation :assign_random_emoji, if: -> { positive? && emoji.blank? }
  after_create :check_card_completion
  after_create_commit :broadcast_sticker_added

  private

  def assign_random_emoji
    self.emoji = EMOJI_POOL.sample
  end

  def check_card_completion
    sticker_card.check_and_create_next_card_if_completed
  end

  def broadcast_sticker_added
    ChildProfileChannel.broadcast_to(
      sticker_card.child_profile,
      { action: "sticker_added", sticker_id: id, emoji: emoji, kind: kind }
    )
  end
end
