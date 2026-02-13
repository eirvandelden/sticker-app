require "test_helper"

class ChildFlowTest < ActionDispatch::IntegrationTest
  def setup
    @child = User.create!(email: "child@example.com", password: "password", role: :child)
    @profile = ChildProfile.create!(user: @child, sticker_goal: 3)
    @card = @profile.sticker_cards.create!
  end

  test "child logs in and sees current card with empty slots" do
    log_in_as(@child)
    assert_response :success
    assert_match "Your Sticker Card", response.body
    assert_match /You&#39;ve completed|You've completed/, response.body
    assert_match "⭐", response.body
  end

  private

  def log_in_as(user)
    post session_path, params: { email: user.email, password: "password" }
    follow_redirect!
  end
end
