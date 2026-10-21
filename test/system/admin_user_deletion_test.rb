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

    within_user_row(@user) { click_button I18n.t("admin.users.index.delete") }

    within("dialog[open]") do
      assert_text I18n.t("admin.users.index.confirm_delete")
      click_button I18n.t("shared.confirm_dialog.accept")
    end

    assert_no_text @user.email
    assert_not User.exists?(@user.id)
  end

  test "cancel and escape keep the user, then a second confirm still deletes" do
    visit admin_users_path

    within_user_row(@user) { click_button I18n.t("admin.users.index.delete") }
    within("dialog[open]") { click_button I18n.t("shared.confirm_dialog.cancel") }

    assert_no_selector "dialog[open]"
    assert_current_path admin_users_path
    assert User.exists?(@user.id)

    within_user_row(@user) { click_button I18n.t("admin.users.index.delete") }

    assert_selector "dialog[open]"
    find("body").send_keys(:escape)

    assert_no_selector "dialog[open]"
    assert User.exists?(@user.id)

    within_user_row(@user) { click_button I18n.t("admin.users.index.delete") }
    within("dialog[open]") { click_button I18n.t("shared.confirm_dialog.accept") }

    assert_no_text @user.email
    assert_not User.exists?(@user.id)
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
