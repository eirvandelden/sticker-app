require "application_system_test_case"

class AdminUserDeletionTest < ApplicationSystemTestCase
  setup do
    @admin = users(:admin)
    @user = users(:user)
    sign_in_admin
  end

  teardown do
    Capybara.reset_sessions!
  end

  test "admin deletes a user through the confirmation dialog" do
    visit admin_users_path

    within_user_row(@user) { click_button I18n.t("admin.users.index.delete_ellipsis") }

    within("dialog[open]") do
      assert_text I18n.t("admin.users.index.confirm_delete")
      click_button I18n.t("admin.users.index.delete")
    end

    assert_current_path admin_users_path, wait: 10
    assert_not User.exists?(@user.id)
  end

  test "cancel closes the confirmation dialog and keeps the user" do
    visit admin_users_path

    within_user_row(@user) { click_button I18n.t("admin.users.index.delete_ellipsis") }

    within("dialog[open]") { click_button I18n.t("admin.users.index.cancel") }

    assert_no_selector "dialog[open]"
    assert_current_path admin_users_path
    assert User.exists?(@user.id)
  end

  private

  def sign_in_admin
    visit new_session_path
    fill_in "Email address", with: @admin.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    assert_no_current_path new_session_path, wait: 10
  end

  def within_user_row(user, &block)
    within(:xpath, "//tr[td[normalize-space()='#{user.email}']]", &block)
  end
end
