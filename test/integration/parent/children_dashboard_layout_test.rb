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

  test "dashboard shows mark rewarded only in the row of a child with a card ready to reward" do
    ready_child = child_profiles(:two)
    child_without_ready_card = child_profiles(:one)
    sign_in_as @parent

    get parent_children_path

    assert_response :success
    assert_select "##{dom_id(ready_child, :dashboard_row)} form[action=?]", parent_child_reward_path(ready_child)
    assert_select "form[action=?]", parent_child_reward_path(child_without_ready_card), count: 0
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
