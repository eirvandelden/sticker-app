require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "parent logs in via the login form and is redirected to children dashboard" do
    visit new_session_path
    fill_in t("sessions.email"), with: users(:parent).email
    fill_in t("sessions.password"), with: "password"
    click_button t("sessions.login_button")
    assert_current_path parent_children_path
  end

  test "login form rejects wrong password" do
    visit new_session_path
    fill_in t("sessions.email"), with: users(:parent).email
    fill_in t("sessions.password"), with: "wrong"
    click_button t("sessions.login_button")
    assert_current_path session_path
  end
end
