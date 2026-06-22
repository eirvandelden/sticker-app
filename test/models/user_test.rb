require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "creating a child user auto-creates a child profile" do
    user = User.create!(email: "newchild@example.com", password: "password", role: :child)
    assert user.child_profile.present?, "Expected child_profile to be created automatically"
  end

  test "creating a child user auto-creates an initial sticker card" do
    user = User.create!(email: "newchild2@example.com", password: "password", role: :child)
    assert user.child_profile.sticker_cards.any?, "Expected at least one sticker_card to be created"
  end

  test "creating a parent user does not create a child profile" do
    user = User.create!(email: "newparent@example.com", password: "password", role: :parent)
    assert_nil user.child_profile
  end
end
