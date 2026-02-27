require "test_helper"

class PreferencesTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
  end

  test "user can update locale to italian" do
    sign_in_as(@user)

    patch preferences_path, params: {
      user: {
        locale: "it"
      }
    }

    assert_redirected_to edit_preferences_path
    follow_redirect!
    assert_response :success
    assert_equal "it", @user.reload.locale
    assert_select 'html[lang="it"]'
    assert_select "h1", text: I18n.t("preferences.title", locale: :it)
  end

  test "user cannot set an unsupported locale" do
    sign_in_as(@user)

    patch preferences_path, params: {
      user: {
        locale: "fr"
      }
    }

    assert_response :unprocessable_entity
    assert_equal "en", @user.reload.locale
  end
end
