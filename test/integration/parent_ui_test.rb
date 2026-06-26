require "test_helper"

class ParentUiTest < ActionDispatch::IntegrationTest
  setup do
    @parent  = users(:parent)
    @profile = child_profiles(:one)
  end

  test "parent logs in and sees sticker and penalty buttons" do
    sign_in_as @parent
    get parent_children_path
    assert_response :success
    assert_select "form[action=?]", parent_child_sticker_path(child_id: @profile)
    assert_select "form[action=?]", parent_child_penalty_path(child_id: @profile)
  end

  test "parent sees reward button after completed card starts next card" do
    sign_in_as @parent
    get parent_children_path
    assert_response :success
    # profile_two has a completed_unrewarded card — reward button should appear
    assert_select "form[action=?]", parent_child_reward_path(child_id: child_profiles(:two))
  end

  test "parent dashboard shows a progress bar for each child card" do
    sign_in_as @parent
    get parent_children_path
    assert_response :success
    assert_select "article progress", minimum: 1
  end

  test "parent dashboard wraps sticker and penalty buttons in child-actions" do
    sign_in_as @parent
    get parent_children_path
    assert_response :success
    assert_select "div.child-actions" do
      assert_select "form", minimum: 2
    end
  end
end
