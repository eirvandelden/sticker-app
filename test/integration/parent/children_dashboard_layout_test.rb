require "test_helper"

class Parent::ChildrenDashboardLayoutTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent)
  end

  test "dashboard shows each child's progress and give sticker/penalty actions, without goal or allowance controls" do
    child = child_profiles(:one)
    sign_in_as @parent

    get parent_children_path

    assert_response :success
    assert_select "progress"
    assert_select "form[action=?]", parent_child_card_goal_path(child), count: 0
    assert_select "a[href=?]", parent_child_path(child)
  end

  test "dashboard shows a gift badge when a child's sticker card is ready to reward, but no mark rewarded button" do
    child = child_profiles(:two)
    sign_in_as @parent

    get parent_children_path

    assert_response :success
    assert_select "##{dom_id(child, :reward_badge)}"
    assert_select "form[action=?]", parent_child_reward_path(child), count: 0
  end

  test "child page shows goal form, allowance status and history link" do
    child = child_profiles(:one)
    sign_in_as @parent

    get parent_child_path(child)

    assert_response :success
    assert_select "form[action=?]", parent_child_card_goal_path(child)
    assert_select "a[href=?]", parent_child_history_path(child)
  end

  test "child page shows mark rewarded button when their sticker card is ready to reward" do
    child = child_profiles(:two)
    sign_in_as @parent

    get parent_child_path(child)

    assert_response :success
    assert_select "form[action=?]", parent_child_reward_path(child)
  end
end
