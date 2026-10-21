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

  test "user list confirms Delete through Turbo on every other row" do
    sign_in_as(@admin)
    get admin_users_path

    assert_response :success
    assert_select "[data-controller=dialog]", count: 0
    assert_select "button[data-turbo-confirm]", count: User.where.not(id: @admin.id).count
    assert_select "form[action=?]", admin_user_path(@user) do
      assert_select "input[name=_method][value=delete]"
      assert_select "button.button-danger[data-turbo-confirm]", text: I18n.t("admin.users.index.delete")
    end
    assert_select "form[action=?]", admin_user_path(@admin), count: 0
  end

  test "parent layout renders one shared confirm dialog" do
    sign_in_as(@admin)
    get admin_users_path

    assert_select "dialog#confirm-dialog[aria-labelledby=confirm-dialog-message]", count: 1 do
      assert_select "p#confirm-dialog-message"
      assert_select "footer button#confirm-dialog-cancel[type=button]"
      assert_select "footer button#confirm-dialog-accept.button-danger[type=button]"
    end
  end

  test "child layout renders one shared confirm dialog" do
    sign_in_as(@user)
    get child_dashboard_path

    assert_response :success
    assert_select "dialog#confirm-dialog", count: 1
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

  test "users table is a labelled stacking table" do
    sign_in_as users(:admin)

    get admin_users_path

    assert_select "main > header > h1#admin_users_heading"
    assert_select "table[data-stack][role=table][aria-labelledby=admin_users_heading]", count: 1
    assert_select "table > thead[role=rowgroup] > tr[role=row] > th[role=columnheader]", count: 5
    assert_select "table > tbody[role=rowgroup] > tr[role=row] > td[role=cell][data-label]", minimum: 5
    assert_select "td[role=cell]:not([data-label])", count: 0
    assert_select "td time[datetime]", minimum: 1
  end
end
