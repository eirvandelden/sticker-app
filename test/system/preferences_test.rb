require "application_system_test_case"

class PreferencesSystemTest < ApplicationSystemTestCase
  test "saved color scheme updates root theme data" do
    parent = users(:parent)

    visit new_session_path
    fill_in "Email", with: parent.email
    fill_in "Password", with: "password"
    click_button "Login"

    click_link "Preferences"
    select "Dark", from: "user_color_scheme"
    click_button "Save Preferences"

    assert_equal "dark", page.evaluate_script("document.documentElement.dataset.colorScheme")
    assert_equal "solunized-dark", page.evaluate_script("document.documentElement.dataset.theme")
  end
end
