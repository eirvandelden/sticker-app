require "test_helper"

class AccountTest < ActionDispatch::IntegrationTest
  teardown { ApplicationController.allow_forgery_protection = false }

  test "the Account landing links Voorkeuren and Profiel" do
    sign_in_as users(:dutch_admin)

    get account_path

    assert_response :success
    assert_select "main nav > ul > li > a[href=?]", "#{edit_preferences_path}?from=account", text: "Voorkeuren"
    assert_select "main nav > ul > li > a[href=?]", "#{user_profile_path(users(:dutch_admin))}?from=account",
      text: "Profiel"
  end

  test "Uitloggen is the last tile and sends DELETE to the session" do
    sign_in_as users(:dutch_admin)

    get account_path

    assert_select "main nav > ul > li:last-child a[href=?][data-turbo-method=delete]", session_path,
      text: "Uitloggen"
  end

  test "a child sees the same Account tiles" do
    sign_in_as users(:user)

    get account_path

    assert_response :success
    assert_select "main nav > ul > li", count: 3
    assert_select "main nav > ul > li:last-child a[data-turbo-method=delete]"
  end

  test "both nav layouts render the CSRF token" do
    [ users(:parent), users(:user) ].each do |user|
      sign_in_as user
      ApplicationController.allow_forgery_protection = true
      get account_path

      assert_select "head meta[name=csrf-token]"
      delete session_path, headers: { "X-CSRF-Token" => session[:_csrf_token] }
      ApplicationController.allow_forgery_protection = false
    end
  end

  test "Profiel opened from the Account landing links back to Account" do
    sign_in_as users(:parent)
    get account_path
    profile_link = css_select("main a[href*='profile']").first["href"]

    get profile_link

    assert_response :success
    assert_select "main > header > nav > a:first-child[href=?]", account_path, text: "‹ Account"
  end

  test "a signed-out visitor of the Account landing is sent to sign in" do
    get account_path

    assert_redirected_to new_session_path
  end
end
