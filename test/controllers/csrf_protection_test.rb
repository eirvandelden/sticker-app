require "test_helper"

class CsrfProtectionTest < ActionDispatch::IntegrationTest
  setup { ApplicationController.allow_forgery_protection = true }
  teardown { ApplicationController.allow_forgery_protection = false }

  test "POST requests without authenticity token are rejected" do
    sign_in_as(users(:parent))

    post parent_child_sticker_path(child_id: child_profiles(:one)), params: { emoji_mode: "random" }
    assert_response :unprocessable_entity
  end

  test "POST requests with valid authenticity token succeed when authenticated" do
    sign_in_as(users(:parent))

    get parent_children_path
    assert_response :success

    delete session_path, headers: { "X-CSRF-Token" => session[:_csrf_token] }
    assert_response :redirect
  end

  test "magic-link transfer flow survives CSRF protection" do
    transfer_id = users(:user).transfer_id

    get session_transfer_path(transfer_id)
    assert_response :success

    token = css_select("form#session_transfer_form input[name='authenticity_token']").first["value"]
    assert token.present?, "expected the auto-submit form to carry a real CSRF token"

    put session_transfer_path(transfer_id), params: { authenticity_token: token }
    assert_redirected_to child_dashboard_path
  end

  private

  def sign_in_as(user)
    ApplicationController.allow_forgery_protection = false
    post session_path, params: { email: user.email, password: "password" }
    ApplicationController.allow_forgery_protection = true
  end
end
