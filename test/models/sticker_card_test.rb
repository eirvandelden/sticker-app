require "test_helper"

class StickerCardTest < ActiveSupport::TestCase
  test "card is not completed with fewer stickers than required" do
    child = create_child(goal: 3)
    card = child.sticker_cards.create!
    card.stickers.create!(kind: :positive)
    assert_not card.completed?
  end

  test "card is completed when positive stickers meet goal" do
    child = create_child(goal: 2)
    card = child.sticker_cards.create!
    2.times { card.stickers.create!(kind: :positive) }
    assert card.completed?
  end

  test "negative stickers increase requirement" do
    child = create_child(goal: 2)
    card = child.sticker_cards.create!
    card.stickers.create!(kind: :negative)
    2.times { card.stickers.create!(kind: :positive) }
    assert_not card.completed?
    card.stickers.create!(kind: :positive)
    assert card.completed?
  end

  test "new card is created automatically when goal is reached" do
    child = create_child(goal: 1)
    card = child.sticker_cards.create!

    card.stickers.create!(kind: :positive)

    assert_equal 2, child.sticker_cards.count
  end

  test "reward cannot be marked if card is incomplete" do
    child = create_child(goal: 3)
    card = child.sticker_cards.create!
    card.stickers.create!(kind: :positive)

    card.reward_given = true
    assert_not card.valid?
    assert_includes card.errors[:reward_given], "can't be set unless the card is completed"
  end

  private

  def create_child(goal:)
    user = User.create!(email: "test_child_#{SecureRandom.hex(4)}@example.com", password: "password", role: :child)
    ChildProfile.create!(user: user, sticker_goal: goal)
  end
end
