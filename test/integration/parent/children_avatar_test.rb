require "test_helper"

class Parent::ChildrenAvatarTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent)
    @admin  = users(:admin)
    @child  = child_profiles(:one)
  end

  test "parent can reach child settings page with avatar form" do
    sign_in_as @parent
    get edit_parent_child_path(@child)

    assert_response :success
    assert_select "h1", text: I18n.t("parent.child_profile.edit.title")
    assert_select "form[action='#{parent_child_avatar_path(@child)}'][method='post']" do
      assert_select "input[name='_method'][type='hidden'][value='patch']"
      assert_select "input[name='user[avatar]'][type='file'][required]"
    end
  end

  test "parent can upload child avatar" do
    sign_in_as @parent
    avatar = fixture_file_upload("avatar.png", "image/png")
    patch parent_child_avatar_path(@child), params: { user: { avatar: avatar } }

    assert_redirected_to edit_parent_child_path(@child)
    assert_equal "Avatar updated successfully", flash[:notice]
    assert_predicate @child.user.reload.avatar, :attached?
  end

  test "parent sees avatar validation errors" do
    sign_in_as @parent
    avatar = fixture_file_upload("avatar.txt", "text/plain")
    patch parent_child_avatar_path(@child), params: { user: { avatar: avatar } }

    assert_response :unprocessable_entity
    assert_select "[role=alert]", text: /PNG, JPEG, GIF, or WebP/
  end

  test "admin can also upload child avatar" do
    sign_in_as @admin
    avatar = fixture_file_upload("avatar.png", "image/png")
    patch parent_child_avatar_path(@child), params: { user: { avatar: avatar } }

    assert_redirected_to edit_parent_child_path(@child)
    assert_predicate @child.user.reload.avatar, :attached?
  end

  test "child cannot reach parent child settings page" do
    sign_in_as users(:user)
    get edit_parent_child_path(@child)

    assert_redirected_to root_path
  end

  test "child cannot update another child's avatar" do
    other_child = child_profiles(:two)
    sign_in_as users(:user)
    avatar = fixture_file_upload("avatar.png", "image/png")
    assert_no_changes -> { other_child.user.reload.avatar.attached? } do
      patch parent_child_avatar_path(other_child), params: { user: { avatar: avatar } }
    end

    assert_redirected_to root_path
  end
end
