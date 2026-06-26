require "test_helper"

class Admin::UsersNameAvatarTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @user  = users(:user)
  end

  test "admin can update a user's name" do
    sign_in_as @admin
    patch admin_user_path(@user), params: { user: { name: "New Name" } }

    assert_redirected_to admin_user_path(@user)
    assert_equal "New Name", @user.reload.name
  end

  test "admin can update a user's avatar" do
    sign_in_as @admin
    avatar = fixture_file_upload("avatar.png", "image/png")
    patch admin_user_path(@user), params: { user: { avatar: avatar } }

    assert_redirected_to admin_user_path(@user)
    assert_predicate @user.reload.avatar, :attached?
  end

  test "admin cannot set a blank name" do
    sign_in_as @admin
    patch admin_user_path(@user), params: { user: { name: "" } }

    assert_response :unprocessable_entity
  end
end
