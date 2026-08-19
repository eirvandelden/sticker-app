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
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    visit new_session_path
    fill_in "Email", with: users(:parent).email
    fill_in "Password", with: "wrong"
    click_button "Sign in"
    assert_current_path new_session_path
    begin
      assert_text I18n.t("appkit.sessions.rejection")
    rescue Minitest::Assertion
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
      puts "=== DIAGNOSTIC elapsed=#{elapsed.round(2)}s url=#{page.current_url}"
      puts "=== DIAGNOSTIC body ==="
      puts page.html
      raise
    end
  end
end
