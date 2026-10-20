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

  test "user list offers a red Delete… opener and a dialog with a DELETE form" do
    sign_in_as(@admin)
    get admin_users_path

    assert_response :success
    assert_select "[data-controller=dialog]", count: User.where.not(id: @admin.id).count
    assert_select "[data-controller=dialog] button[type=button].button-danger[data-action='dialog#open']",
                  text: I18n.t("admin.users.index.delete_ellipsis")
    assert_select "[data-controller=dialog] dialog[data-dialog-target=dialog] footer form[method=dialog]"
    assert_select "dialog footer form input[name=_method][value=delete]"
    assert_select "[data-turbo-confirm]", count: 0
    assert_select "dialog[data-dialog-target=dialog] form[action=?]", admin_user_path(@admin), count: 0
  end

  test "user form ends in an action row with Cancel before Save" do
    sign_in_as(@admin)

    [ new_admin_user_path, edit_admin_user_path(@user) ].each do |path|
      get path

      assert_response :success
      assert_select "form > footer:last-child" do
        assert_select "a[role=button].button-secondary"
        assert_select "a[role=button] ~ input[type=submit], a[role=button] ~ button[type=submit]"
      end
    end
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
          name: "Created User",
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

  test "admin user form localizes locale options" do
    sign_in_as(users(:dutch_admin))
    get edit_admin_user_path(@user)

    assert_response :success
    assert_select "option", text: I18n.t("locales.en", locale: :nl)
    assert_select "option", text: I18n.t("locales.nl", locale: :nl)
    assert_select "option", text: I18n.t("locales.it", locale: :nl)
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
