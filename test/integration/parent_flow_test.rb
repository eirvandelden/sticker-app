require "test_helper"

class ParentFlowTest < ActionDispatch::IntegrationTest
  def setup
    @parent = User.create!(email: "parent@example.com", password: "password", role: :parent)
    @child = User.create!(email: "kid@example.com", password: "password", role: :child)
    @profile = ChildProfile.create!(user: @child, sticker_goal: 2)
    @card = @profile.sticker_cards.create!
  end

  test "parent can log in and give a sticker" do
    log_in_as(@parent)
    assert_difference -> { @card.stickers.positive.count }, +1 do
      post parent_child_sticker_path(@profile)
    end
    assert_redirected_to parent_children_path
  end

  test "parent can add a penalty" do
    log_in_as(@parent)
    assert_difference -> { @card.stickers.negative.count }, +1 do
      post parent_child_penalty_path(@profile)
    end
    assert_redirected_to parent_children_path
  end

  test "parent can reward only completed card" do
    log_in_as(@parent)
    2.times { @card.stickers.create!(kind: :positive) }
    post parent_child_reward_path(@profile)
    assert_redirected_to parent_children_path
    assert @card.reload.reward_given?
  end

  test "parent cannot reward incomplete card" do
    log_in_as(@parent)
    post parent_child_reward_path(@profile)
    assert_redirected_to parent_children_path
    assert_not @card.reload.reward_given?
  end

  test "child cannot access parent routes" do
    log_in_as(@child)
    post parent_child_sticker_path(@profile)
    assert_redirected_to root_path
    follow_redirect!
    assert_match "Parent access required", response.body
  end

  private

  def log_in_as(user)
    post session_path, params: { email: user.email, password: "password" }
    follow_redirect!
  end
end
