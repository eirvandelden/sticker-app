require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  test "parent logs in via the login form and is redirected to children dashboard" do
    visit new_session_path
    fill_in "Email", with: users(:parent).email
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_current_path parent_children_path
  end

  test "login form rejects wrong password" do
    visit new_session_path
    fill_in "Email", with: users(:parent).email
    fill_in "Password", with: "wrong"
    click_button "Sign in"
    assert_current_path new_session_path
    assert_text I18n.t("appkit.sessions.rejection")
  end
end
