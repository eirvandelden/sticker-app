require "test_helper"

class AuthTest < ActionDispatch::IntegrationTest
  test "parent logs in with valid credentials and is redirected to children dashboard" do
    post session_path, params: { email_address: users(:parent).email, password: "password" }
    assert_redirected_to parent_children_path
  end

  test "parent login fails with wrong password and re-renders login" do
    post session_path, params: { email_address: users(:parent).email, password: "wrong" }
    assert_response :unauthorized
  end

  test "child logs in with valid credentials and is redirected to dashboard" do
    post session_path, params: { email_address: users(:user).email, password: "password" }
    assert_redirected_to child_dashboard_path
  end

  test "child login fails with wrong password and re-renders login" do
    post session_path, params: { email_address: users(:user).email, password: "wrong" }
    assert_response :unauthorized
  end

  test "admin logs in with valid credentials and is redirected to admin root" do
    post session_path, params: { email_address: users(:admin).email, password: "password" }
    assert_redirected_to admin_root_path
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
end
