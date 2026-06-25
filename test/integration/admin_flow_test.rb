require "test_helper"

class AdminFlowTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
  end

  # Scenario 15: Admin views full user list
  test "admin views full user list" do
    sign_in_as @admin
    get admin_users_path
    assert_response :success
  end

  # Scenario 16: Admin creates a new parent user
  test "admin creates a new parent user" do
    sign_in_as @admin
    assert_difference "User.count", +1 do
      post admin_users_path, params: {
        user: {
          email: "newparent@example.com",
          password: "password",
          password_confirmation: "password",
          role: "parent"
        }
      }
    end
    new_user = User.find_by(email: "newparent@example.com")
    assert new_user.parent?
    assert_redirected_to admin_user_path(new_user)
  end

  # Scenario 17: Admin creates a new child user
  test "admin creates a new child user" do
    sign_in_as @admin
    assert_difference "User.count", +1 do
      post admin_users_path, params: {
        user: {
          email: "newchild@example.com",
          password: "password",
          password_confirmation: "password",
          role: "child"
        }
      }
    end
    new_user = User.find_by(email: "newchild@example.com")
    assert new_user.child?
    assert_redirected_to admin_user_path(new_user)
  end

  # Scenario 18: Admin destroys a user; that user can no longer log in.
  #
  # There is no deactivate route — `user_params` does not permit `active`.
  # Destroy is the only admin removal path. After deletion the user record is
  # gone, so `User.active.authenticate_by` returns nil → :unauthorized.
  test "admin layout nav renders a link to preferences" do
    sign_in_as @admin
    get admin_root_path
    assert_response :success
    assert_select "a[href='#{edit_preferences_path}']"
  end

  test "admin destroys a user and the user can no longer log in" do
    target = users(:user_two)
    target_email = target.email

    sign_in_as @admin
    assert_difference "User.count", -1 do
      delete admin_user_path(target)
    end
    assert_redirected_to admin_users_path
    assert_not User.exists?(target.id)

    delete session_path  # log out admin
    post session_path, params: { email_address: target_email, password: "password" }
    assert_redirected_to new_session_path
  end
end
