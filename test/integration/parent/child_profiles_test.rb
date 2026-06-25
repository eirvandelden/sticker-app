require "test_helper"

class Parent::ChildProfilesTest < ActionDispatch::IntegrationTest
  setup do
    @parent  = users(:parent)
    @admin   = users(:admin)
    @child   = users(:user)
    @profile = child_profiles(:one)
  end

  test "parent can view edit page" do
    sign_in_as @parent
    get edit_parent_child_child_profile_path(@profile)
    assert_response :success
  end

  test "parent can update sticker_goal" do
    sign_in_as @parent
    patch parent_child_child_profile_path(@profile),
          params: { child_profile: { sticker_goal: 5 } }
    assert_redirected_to parent_children_path
    assert_equal 5, @profile.reload.sticker_goal
  end

  test "invalid sticker_goal is rejected" do
    sign_in_as @parent
    patch parent_child_child_profile_path(@profile),
          params: { child_profile: { sticker_goal: 0 } }
    assert_response :unprocessable_entity
  end

  test "child cannot access edit page" do
    sign_in_as @child
    get edit_parent_child_child_profile_path(@profile)
    assert_redirected_to root_path
  end

  test "admin can update sticker_goal" do
    sign_in_as @admin
    patch parent_child_child_profile_path(@profile),
          params: { child_profile: { sticker_goal: 7 } }
    assert_redirected_to parent_children_path
    assert_equal 7, @profile.reload.sticker_goal
  end
end
