require "test_helper"

class PreferencesTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
    @parent = users(:parent)
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

  test "blank password does not change the user's password" do
    sign_in_as(@user)
    original_digest = @user.password_digest

    patch preferences_path, params: {
      user: {
        locale: "en",
        password: "",
        password_confirmation: ""
      }
    }

    assert_redirected_to edit_preferences_path
    assert_equal original_digest, @user.reload.password_digest
  end

  test "non-blank password updates the user's password" do
    sign_in_as(@user)

    patch preferences_path, params: {
      user: {
        locale: "en",
        password: "new-secure-pass",
        password_confirmation: "new-secure-pass"
      }
    }

    assert_redirected_to edit_preferences_path
    assert @user.reload.authenticate("new-secure-pass"), "Expected password to be updated"
  end

  test "child can access preferences edit page" do
    sign_in_as(@user)
    get edit_preferences_path
    assert_response :success
  end

  test "child can update locale via preferences" do
    sign_in_as(@user)

    patch preferences_path, params: { user: { locale: "nl" } }

    assert_redirected_to edit_preferences_path
    assert_equal "nl", @user.reload.locale
  end

  class ParentPreferencesTest < ActionDispatch::IntegrationTest
    setup do
      @parent = users(:parent)
    end

    test "parent can access preferences edit page" do
      sign_in_as(@parent)
      get edit_preferences_path
      assert_response :success
      assert_select "h1", text: I18n.t("preferences.title")
    end

    test "parent can update locale via preferences" do
      sign_in_as(@parent)

      patch preferences_path, params: { user: { locale: "nl" } }

      assert_redirected_to edit_preferences_path
      assert_equal "nl", @parent.reload.locale
    end

    test "parent can update color scheme" do
      sign_in_as(@parent)

      patch preferences_path, params: {
        user: {
          color_scheme: "dark"
        }
      }

      assert_redirected_to edit_preferences_path
      assert_equal "dark", @parent.reload.color_scheme
    end
  end

  class AdminPreferencesTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:admin)
    end

    test "admin can access preferences edit page" do
      sign_in_as(@admin)
      get edit_preferences_path
      assert_response :success
    end

    test "admin can update locale via preferences" do
      sign_in_as(@admin)

      patch preferences_path, params: { user: { locale: "it" } }

      assert_redirected_to edit_preferences_path
      assert_equal "it", @admin.reload.locale
    end
  end
end

class AdminUserLocaleTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @target = users(:user)
  end

  test "admin can update a user's locale" do
    sign_in_as(@admin)

    patch admin_user_path(@target), params: {
      user: {
        email: @target.email,
        locale: "nl"
      }
    }

    assert_redirected_to admin_user_path(@target)
    assert_equal "nl", @target.reload.locale
  end
end
