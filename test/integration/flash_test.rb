require "test_helper"

class FlashTest < ActionDispatch::IntegrationTest
  test "application flash container is labelled" do
    sign_in_as(users(:user))

    patch preferences_path, params: { user: { locale: "en" } }
    follow_redirect!

    assert_select %(section[data-mvpa-flashes][aria-label="#{I18n.t("appkit.flash.notifications")}"])
  end

  test "admin flash container is labelled" do
    admin = users(:admin)
    sign_in_as(admin)

    delete admin_user_path(admin)
    follow_redirect!

    assert_select %(section[data-mvpa-flashes][aria-label="#{I18n.t("appkit.flash.notifications")}"])
  end

  test "sign-in page renders flashes outside main" do
    post session_path, params: { email_address: users(:user).email, password: "wrong" }

    assert_response :unauthorized
    assert_select "body > section[data-mvpa-flashes]"
    assert_select "main section[data-mvpa-flashes]", count: 0
  end
end
