require "test_helper"

class Parent::ChildrenNameTest < ActionDispatch::IntegrationTest
  setup do
    @parent     = users(:parent)
    @admin      = users(:admin)
    @child      = child_profiles(:one)
    @child_user = @child.user
  end

  test "parent can reach child edit page" do
    sign_in_as @parent
    get edit_parent_child_path(@child)

    assert_response :success
    assert_select "form"
  end

  test "parent can update child name" do
    sign_in_as @parent
    patch parent_child_path(@child), params: { user: { name: "Updated Name" } }

    assert_redirected_to parent_children_path
    assert_equal "Updated Name", @child_user.reload.name
  end

  test "parent cannot set blank child name" do
    sign_in_as @parent
    patch parent_child_path(@child), params: { user: { name: "" } }

    assert_response :unprocessable_entity
  end

  test "admin can also update child name" do
    sign_in_as @admin
    patch parent_child_path(@child), params: { user: { name: "Admin Set Name" } }

    assert_redirected_to parent_children_path
    assert_equal "Admin Set Name", @child_user.reload.name
  end

  test "child cannot reach parent edit page" do
    sign_in_as users(:user)
    get edit_parent_child_path(@child)

    assert_redirected_to root_path
  end
end
