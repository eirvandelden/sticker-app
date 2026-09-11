require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  test "parent sees a Home link as the first nav item leading to the children list" do
    sign_in_as users(:parent)

    get parent_children_path

    assert_response :success
    assert_select "nav ul li:first-child a[href=?]", parent_children_path, text: I18n.t("navigation.home")
  end

  test "child sees a Home link as the first nav item leading to the dashboard" do
    sign_in_as users(:user)

    get child_dashboard_path

    assert_response :success
    assert_select "nav ul li:first-child a[href=?]", child_dashboard_path, text: I18n.t("navigation.home")
  end

  test "admin sees a Home link as the first nav item leading to the children list" do
    sign_in_as users(:admin)

    get parent_children_path

    assert_response :success
    assert_select "nav ul li:first-child a[href=?]", parent_children_path, text: I18n.t("navigation.home")
  end

  test "admin sees extra nav tabs for the admin overview and the user list on every page" do
    sign_in_as users(:admin)

    [ parent_children_path, admin_root_path, admin_users_path ].each do |page|
      get page

      assert_response :success
      assert_select "nav ul li a[href=?]", admin_root_path, count: 1
      assert_select "nav ul li a[href=?]", admin_users_path, count: 1
    end
  end

  test "only the admin overview tab is marked as the current page while on the admin overview" do
    sign_in_as users(:admin)

    get admin_root_path

    assert_select "nav ul li a[href=?][aria-current=?]", admin_root_path, "page"
    assert_select "nav ul li a[aria-current]", count: 1
  end

  test "the user list tab stays marked as the current page while editing one user" do
    sign_in_as users(:admin)

    get edit_admin_user_path(users(:parent))

    assert_select "nav ul li a[href=?][aria-current=?]", admin_users_path, "page"
    assert_select "nav ul li a[aria-current]", count: 1
  end
end
