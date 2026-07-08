require "application_system_test_case"

class PreferencesSystemTest < ApplicationSystemTestCase
  test "saved color scheme updates root theme data" do
    parent = users(:parent)

    sign_in parent

    open_preferences
    select "Dark", from: "user_color_scheme"

    assert_equal "system", page.evaluate_script("document.documentElement.dataset.colorScheme")

    assert_field "user_color_scheme", with: "dark"
    page.execute_script("document.querySelector('form').requestSubmit()")
    assert_text I18n.t("flash.preferences.updated", locale: :en)

    assert_equal "dark", page.evaluate_script("document.documentElement.dataset.colorScheme")
    assert_equal "solunized-dark", page.evaluate_script("document.documentElement.dataset.theme")
  end

  test "unsaved color scheme is discarded on browser back" do
    parent = users(:parent)

    sign_in parent

    open_preferences
    select "Dark", from: "user_color_scheme"
    go_back

    assert_equal "system", parent.reload.color_scheme
    assert_selector 'html[data-color-scheme="system"]', visible: :all
  end

  test "saved body theme variables replace root theme variables" do
    parent = users(:parent)
    parent.update!(color_scheme: :light)

    sign_in parent

    open_preferences

    html_background = page.evaluate_script(
      "getComputedStyle(document.documentElement).getPropertyValue('--color-bg-0')"
    )
    body_background = page.evaluate_script(
      "getComputedStyle(document.body).getPropertyValue('--color-bg-0')"
    )
    assert_equal html_background, body_background
  end

  test "system color scheme follows browser appearance changes" do
    parent = users(:parent)

    emulate_color_scheme "dark"
    sign_in parent

    open_preferences
    assert_selector 'html[data-theme="solunized-dark"]', visible: :all

    emulate_color_scheme "light"
    assert_selector 'html[data-theme="solunized-light"]', visible: :all
  ensure
    emulate_color_scheme "no-preference"
  end

  private
    def sign_in(user)
      visit session_transfer_path(user.transfer_id)
      assert_current_path parent_children_path
    end

    def open_preferences
      visit edit_preferences_path
      assert_current_path edit_preferences_path
      assert_selector "select#user_color_scheme"
    end

    def emulate_color_scheme(value)
      page.driver.browser.execute_cdp(
        "Emulation.setEmulatedMedia",
        features: [
          {
            name: "prefers-color-scheme",
            value: value
          }
        ]
      )
    end
end
