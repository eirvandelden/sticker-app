require "test_helper"

class LayoutMetaTest < ActionDispatch::IntegrationTest
  test "parent layout lets the page reach the safe area" do
    sign_in_as users(:parent)

    get parent_children_path

    assert_response :success
    assert_select "meta[name=viewport][content*=?]", "viewport-fit=cover"
  end

  test "child layout lets the page reach the safe area" do
    sign_in_as users(:user)

    get child_dashboard_path

    assert_response :success
    assert_select "meta[name=viewport][content*=?]", "viewport-fit=cover"
  end
end
