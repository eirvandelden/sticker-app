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

  test "flashes render outside main" do
    sign_in_as(users(:user))

    patch preferences_path, params: { user: { locale: "en" } }
    follow_redirect!

    assert_select "main [data-mvpa-flashes]", count: 0
    assert_select "body > [data-mvpa-flashes]", count: 1
  end
end
