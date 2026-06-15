require "test_helper"

class AuthTest < ActionDispatch::IntegrationTest
  # Scenario 1: Parent logs in successfully
  test "parent logs in with valid credentials and is redirected to children dashboard" do
    post session_path, params: { email_address: users(:parent).email, password: "password" }
    assert_redirected_to parent_children_path
  end

  # Scenario 2: Parent login fails with wrong password
  test "parent login fails with wrong password and re-renders login" do
    post session_path, params: { email_address: users(:parent).email, password: "wrong" }
    assert_response :unauthorized
  end

  # Scenario 3: Child logs in successfully
  test "child logs in with valid credentials and is redirected to dashboard" do
    post session_path, params: { email_address: users(:user).email, password: "password" }
    assert_redirected_to child_dashboard_path
  end

  # Scenario 4: Child login fails with wrong password
  test "child login fails with wrong password and re-renders login" do
    post session_path, params: { email_address: users(:user).email, password: "wrong" }
    assert_response :unauthorized
  end

  # Scenario 5: Admin logs in successfully
  test "admin logs in with valid credentials and is redirected to admin root" do
    post session_path, params: { email_address: users(:admin).email, password: "password" }
    assert_redirected_to admin_root_path
  end
end
