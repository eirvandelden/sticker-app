require "test_helper"

class Parent::ChildrenAvatarTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent)
    @admin  = users(:admin)
    @child  = child_profiles(:one)
  end

  test "parent can reach child avatar edit page" do
    sign_in_as @parent
    get edit_parent_child_avatar_path(@child)

    assert_response :success
    assert_select "form"
  end

  test "parent can upload child avatar" do
    sign_in_as @parent
    avatar = fixture_file_upload("avatar.png", "image/png")
    patch parent_child_avatar_path(@child), params: { user: { avatar: avatar } }

    assert_redirected_to parent_children_path
    assert_predicate @child.user.reload.avatar, :attached?
  end

  test "admin can also upload child avatar" do
    sign_in_as @admin
    avatar = fixture_file_upload("avatar.png", "image/png")
    patch parent_child_avatar_path(@child), params: { user: { avatar: avatar } }

    assert_redirected_to parent_children_path
    assert_predicate @child.user.reload.avatar, :attached?
  end

  test "child cannot reach parent avatar page for another child" do
    sign_in_as users(:user)
    get edit_parent_child_avatar_path(@child)

    assert_redirected_to root_path
  end
end
