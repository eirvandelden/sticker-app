require "test_helper"

class StickerTest < ActiveSupport::TestCase
  test "random emoji is assigned if none given" do
    card = create_card
    sticker = card.stickers.create!(kind: :positive)
    assert sticker.emoji.present?
  end

  test "emoji is preserved if explicitly set" do
    card = create_card
    sticker = card.stickers.create!(kind: :positive, emoji: "🐿️")
    assert_equal "🐿️", sticker.emoji
  end

  test "sticker has giver" do
    parent = User.create!(email: "mom@example.com", password: "password", role: :parent)
    card = create_card
    sticker = card.stickers.create!(kind: :positive, giver: parent)
    assert_equal parent, sticker.giver
  end

  private

  def create_card
    child = User.create!(email: "emoji_child_#{SecureRandom.hex(4)}@example.com", password: "password", role: :child)
    profile = ChildProfile.create!(user: child, sticker_goal: 1)
    profile.sticker_cards.create!
  end
end
