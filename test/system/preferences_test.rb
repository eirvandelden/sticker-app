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

  test "unsaved color scheme preview is discarded on browser back" do
    parent = users(:parent)

    visit new_session_path
    fill_in "Email", with: parent.email
    fill_in "Password", with: "password"
    click_button "Login"

    click_link "Preferences"
    select "Dark", from: "user_color_scheme"
    go_back

    assert_equal "system", parent.reload.color_scheme
    assert_selector 'html[data-color-scheme="system"]', visible: :all
  end

  test "preview replaces saved body theme variables" do
    parent = users(:parent)
    parent.update!(color_scheme: :light)

    visit new_session_path
    fill_in "Email", with: parent.email
    fill_in "Password", with: "password"
    click_button "Login"

    click_link "Preferences"
    select "Dark", from: "user_color_scheme"

    html_background = page.evaluate_script(
      "getComputedStyle(document.documentElement).getPropertyValue('--color-bg-0')"
    )
    body_background = page.evaluate_script(
      "getComputedStyle(document.body).getPropertyValue('--color-bg-0')"
    )
    assert_equal html_background, body_background
  end
end
