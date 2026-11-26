require "application_system_test_case"

class AccountHubTest < ApplicationSystemTestCase
  setup { ApplicationController.allow_forgery_protection = true }
  teardown { ApplicationController.allow_forgery_protection = false }

  test "parent signs out from the Account hub" do
    sign_in users(:parent), lands_on: parent_children_path

    sign_out_from_account_hub

    assert_current_path root_path
    assert_button "Sign in"
    assert_no_text "InvalidAuthenticityToken"
  end

  test "child signs out from the Account hub" do
    sign_in users(:user), lands_on: child_dashboard_path

    sign_out_from_account_hub

    assert_current_path root_path
    assert_button "Sign in"
    assert_no_text "InvalidAuthenticityToken"
  end

  private

  def sign_in(user, lands_on:)
    visit session_transfer_path(user.transfer_id)

    assert_current_path lands_on, wait: 10
  end

  def sign_out_from_account_hub
    within("nav.rail") { click_link I18n.t("menu.hubs.account") }

    assert_current_path account_path
    within("main") { click_link I18n.t("appkit.navigation.logout") }
  end
end
