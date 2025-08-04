class Sticker < ApplicationRecord
  EMOJI_POOL = %w[⭐ 🌈 🐿️ 💎 🐶 🦄 🧸 🍭 🎈 🎨 🚀 🧁
🍀 🐼]

  belongs_to :sticker_card
  belongs_to :giver, class_name: "User", optional: true

  enum :kind, { positive: 0, negative: 1 }

  before_validation :assign_random_emoji, if: -> { positive? && emoji.blank? }

  private

  def assign_random_emoji
    self.emoji = EMOJI_POOL.sample
  end
end
