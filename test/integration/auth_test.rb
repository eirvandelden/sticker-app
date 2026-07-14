require "test_helper"

class AuthTest < ActionDispatch::IntegrationTest
  test "parent logs in with valid credentials and is redirected to children dashboard" do
    post session_path, params: { email: users(:parent).email, password: "password" }
    assert_redirected_to parent_children_path
  end

  test "parent login persists the session cookie with a far-future expiry" do
    post session_path, params: { email: users(:parent).email, password: "password" }

    assert session_token_cookie_expires > 10.years.from_now
  end

  test "resuming a parent session renews the cookie expiration" do
    post session_path, params: { email: users(:parent).email, password: "password" }

    get parent_children_path

    assert_match(/expires=/i, session_token_cookie)
    assert session_token_cookie_expires > 10.years.from_now
  end

  test "child login persists the session cookie with a far-future expiry" do
    post session_path, params: { email: users(:user).email, password: "password" }

    assert session_token_cookie_expires > 10.years.from_now
  end

  test "resuming a child session renews the cookie expiration" do
    post session_path, params: { email: users(:user).email, password: "password" }

    get child_dashboard_path

    assert_match(/expires=/i, session_token_cookie)
    assert session_token_cookie_expires > 10.years.from_now
  end

  test "parent login fails with wrong password and redirects to login" do
    post session_path, params: { email: users(:parent).email, password: "wrong" }
    assert_redirected_to new_session_path
  end

  test "rate limit rejection returns too many requests" do
    controller = build_sessions_controller

    controller.send(:render_rejection, :too_many_requests)

    assert_equal 429, controller.response.status
    assert_nil controller.response.redirect_url
  end

  test "child logs in with valid credentials and is redirected to dashboard" do
    post session_path, params: { email: users(:user).email, password: "password" }
    assert_redirected_to child_dashboard_path
  end

  test "child login fails with wrong password and redirects to login" do
    post session_path, params: { email: users(:user).email, password: "wrong" }
    assert_redirected_to new_session_path
  end

  test "admin logs in with valid credentials and is redirected to parent children" do
    post session_path, params: { email: users(:admin).email, password: "password" }
    assert_redirected_to parent_children_path
  end

  test "session transfer page renders auto submit form" do
    transfer_id = users(:user).transfer_id

    get session_transfer_path(transfer_id)

    assert_response :success
    assert_select "form#session_transfer_form[action='#{session_transfer_path(transfer_id)}']"
    assert_select "input[name='_method'][value='put']"
  end

  test "session transfer logs child in and redirects to dashboard" do
    put session_transfer_path(users(:user).transfer_id)

    assert_redirected_to child_dashboard_path
  end

  test "session transfer rejects invalid id" do
    put session_transfer_path("invalid")

    assert_response :bad_request
  end

  test "login page title uses i18n and is not hardcoded in English" do
    original_locale = I18n.default_locale
    I18n.default_locale = :nl
    get new_session_path
    assert_response :success
    assert_select "title", text: /#{I18n.t("sessions.login_title", locale: :nl)}/
    assert_not response.body.include?("<title>Sign in"), "Title is hardcoded English, should use i18n"
  ensure
    I18n.default_locale = original_locale
  end

  private

  def build_sessions_controller
    SessionsController.new.tap do |controller|
      request = ActionDispatch::TestRequest.create
      request.env["action_dispatch.request.path_parameters"] = { controller: "sessions", action: "create" }
      controller.set_request!(request)
      controller.set_response!(ActionDispatch::TestResponse.new)
    end
  end

  def session_token_cookie
    set_cookie = response.headers["Set-Cookie"]
    cookies = set_cookie.is_a?(Array) ? set_cookie : set_cookie.split("\n")
    cookies.find { |cookie| cookie.start_with?("session_token=") }
  end

  def session_token_cookie_expires
    expires_str = session_token_cookie[/expires=([^;]+)/i, 1]
    Time.parse(expires_str)
  end
end
