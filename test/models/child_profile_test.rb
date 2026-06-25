require "test_helper"

class ChildProfileTest < ActiveSupport::TestCase
  test "creating a child profile auto-creates an initial sticker card" do
    # Use a parent user so the User after_create callback does NOT fire,
    # letting us test the ChildProfile callback in isolation.
    user = User.create!(email: "testparent@example.com", password: "password", role: :parent)
    profile = ChildProfile.create!(user: user)
    assert profile.sticker_cards.any?, "Expected at least one sticker_card to be created"
  end

  test "active sticker card provisions one for legacy profiles" do
    user = User.create!(email: "legacyprofile@example.com", password: "password", role: :parent)
    profile = ChildProfile.create!(user: user)
    profile.sticker_cards.destroy_all

    assert_difference -> { profile.sticker_cards.count }, +1 do
      assert profile.active_sticker_card.persisted?
    end
  end

  test "sticker goal is required" do
    profile = child_profiles(:one)
    profile.sticker_goal = nil

    assert_not profile.valid?
    assert_includes profile.errors[:sticker_goal], "can't be blank"
  end

  test "lowering sticker goal runs card completion workflow" do
    user = User.create!(email: "goal-change@example.com", password: "password", role: :child)
    profile = user.child_profile
    profile.update!(sticker_goal: 3)
    card = profile.active_sticker_card
    2.times { card.stickers.create!(kind: :positive) }

    assert_difference -> { profile.sticker_cards.count }, +1 do
      profile.update!(sticker_goal: 2)
    end

    assert_not_nil card.reload.completed_at
  end
end
