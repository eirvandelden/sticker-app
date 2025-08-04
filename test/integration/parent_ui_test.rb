require "test_helper"

class ParentUiTest < ActionDispatch::IntegrationTest
  def setup
    @parent = User.create!(email: "parent@example.com", password: "password", role: :parent)
    @child = User.create!(email: "kid@example.com", password: "password", role: :child)
    @profile = ChildProfile.create!(user: @child, sticker_goal: 2)
    @profile.sticker_cards.create!
  end

  test "parent logs in and sees sticker and penalty buttons" do
    log_in_as(@parent)
    assert_response :success
    assert_select "form[action=?]", parent_child_sticker_path(@profile)
    assert_select "form[action=?]", parent_child_penalty_path(@profile)
  end

  private

  def log_in_as(user)
    post session_path, params: { email: user.email, password: "password" }
    follow_redirect!
  end
end
