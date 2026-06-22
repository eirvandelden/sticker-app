require "test_helper"

class ChildProfileTest < ActiveSupport::TestCase
  test "creating a child profile auto-creates an initial sticker card" do
    # Use a parent user so the User after_create callback does NOT fire,
    # letting us test the ChildProfile callback in isolation.
    user = User.create!(email: "testparent@example.com", password: "password", role: :parent)
    profile = ChildProfile.create!(user: user)
    assert profile.sticker_cards.any?, "Expected at least one sticker_card to be created"
  end
end
