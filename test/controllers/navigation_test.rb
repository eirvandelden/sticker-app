require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  test "parent sees a Home link as the first nav item leading to the children list" do
    sign_in_as users(:parent)

    get parent_children_path

    assert_response :success
    assert_select "nav ul li:first-child a[href=?]", parent_children_path, text: I18n.t("appkit.navigation.home")
  end

  test "child sees a Home link as the first nav item leading to the dashboard" do
    sign_in_as users(:user)

    get child_dashboard_path

    assert_response :success
    assert_select "nav ul li:first-child a[href=?]", child_dashboard_path, text: I18n.t("appkit.navigation.home")
  end

  test "admin sees a Home link as the first nav item leading to the children list" do
    sign_in_as users(:admin)

    get parent_children_path

    assert_response :success
    assert_select "nav ul li:first-child a[href=?]", parent_children_path, text: I18n.t("appkit.navigation.home")
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

  test "Home is marked as the current page on the children list" do
    sign_in_as users(:parent)

    get parent_children_path

    assert_response :success
    assert_select "nav ul li:first-child a[href=?][aria-current=?]", parent_children_path, "page"
  end

  test "Home stays marked on a child's page, edit page and history" do
    sign_in_as users(:parent)
    child = child_profiles(:one)

    [ parent_child_path(child), edit_parent_child_path(child), parent_child_history_path(child) ].each do |page|
      get page

      assert_response :success
      assert_select "nav ul li:first-child a[href=?][aria-current=?]", parent_children_path, "page"
    end
  end

  test "Home is not marked on settings, the admin overview or preferences" do
    sign_in_as users(:admin)

    [ parent_settings_path, admin_root_path, edit_preferences_path ].each do |page|
      get page

      assert_response :success
      assert_select "nav ul li:first-child a[aria-current]", count: 0
    end
  end

  test "Home is not marked on settings or preferences for a parent" do
    sign_in_as users(:parent)

    [ parent_settings_path, edit_preferences_path ].each do |page|
      get page

      assert_response :success
      assert_select "nav ul li:first-child a[aria-current]", count: 0
    end
  end

  test "child sees Home marked as the current page on the dashboard" do
    sign_in_as users(:user)

    get child_dashboard_path

    assert_response :success
    assert_select "nav ul li:first-child a[href=?][aria-current=?]", child_dashboard_path, "page"
  end

  test "the Dutch nav shows appkit's wording" do
    sign_in_as users(:dutch_admin)

    get parent_children_path

    assert_response :success
    assert_select "nav ul li:first-child a", text: "Home"
    assert_select "nav a[href=?]", edit_preferences_path, text: "Voorkeuren"
    assert_select "nav button", text: "Uitloggen"
  end

  test "the nav is headed with the app name" do
    sign_in_as users(:parent)

    get parent_children_path

    assert_response :success
    assert_select "nav h2", text: I18n.t("app.title")
  end

  test "the login page is headed with the app name" do
    get new_session_path

    assert_response :success
    assert_select "h1", text: I18n.t("app.title")
  end
end
