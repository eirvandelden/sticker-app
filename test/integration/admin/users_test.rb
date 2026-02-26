require "test_helper"

class Admin::UsersTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @user = users(:user)
  end

  test "admin can list users" do
    sign_in_as(@admin)
    get admin_users_path

    assert_response :success
    assert_select "td", text: @user.email
  end

  test "admin can view a user" do
    sign_in_as(@admin)
    get admin_user_path(@user)

    assert_response :success
    assert_select "dd", text: @user.email
  end

  test "admin can reach new user form" do
    sign_in_as(@admin)
    get new_admin_user_path

    assert_response :success
    assert_select "form"
  end

  test "admin can create a user" do
    sign_in_as(@admin)

    assert_difference("User.count", 1) do
      post admin_users_path, params: {
        user: {
          email: "created@example.com",
          role: "parent",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    created_user = User.find_by!(email: "created@example.com")
    assert_redirected_to admin_user_path(created_user)
  end

  test "admin can edit a user" do
    sign_in_as(@admin)
    get edit_admin_user_path(@user)

    assert_response :success
    assert_select "form"
  end

  test "admin can update a user" do
    sign_in_as(@admin)
    patch admin_user_path(@user), params: { user: { role: "admin" } }

    assert_redirected_to admin_user_path(@user)
    assert_equal "admin", @user.reload.role
  end

  test "admin cannot delete themselves" do
    sign_in_as(@admin)

    assert_no_difference("User.count") do
      delete admin_user_path(@admin)
    end

    assert_redirected_to admin_users_path
  end

  test "non-admin user is redirected for all actions" do
    sign_in_as(@user)

    get admin_users_path
    assert_redirected_to root_path
  end
end
