require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  test "parent sees a rail with Kinderen, Instellingen and Account and the Kinderen hub column" do
    sign_in_as users(:parent)

    get parent_children_path

    assert_response :success
    assert_equal [ "Children", "Settings", "Account" ], rail_labels
    assert_select "nav.rail a[href=?][aria-current=?]", parent_children_path, "true"
    assert_select "nav.rail + nav a[href=?][aria-current=?]", parent_children_path, "page", text: "Overview"
  end

  test "admin sees Beheer in the rail and its hub column on the user list" do
    sign_in_as users(:admin)

    get admin_users_path

    assert_response :success
    assert_equal [ "Children", "Settings", "Admin", "Account" ], rail_labels
    assert_select "nav.rail a[href=?][aria-current=?]", admin_root_path, "true"
    assert_select "nav.rail + nav a[href=?][aria-current=?]", admin_users_path, "page"
  end

  test "child sees a rail with Dashboard and Account and no hub column" do
    sign_in_as users(:user)

    get child_dashboard_path

    assert_response :success
    assert_equal [ "Dashboard", "Account" ], rail_labels
    assert_select "nav.rail a[href=?][aria-current=?]", child_dashboard_path, "true"
    assert_select "nav.rail + nav", count: 0
  end

  test "every rail link opens its own hub as the current hub" do
    { parent: parent_children_path, admin: admin_users_path, user: child_dashboard_path }.each do |role, start|
      sign_in_as users(role)
      get start
      paths = css_select("nav.rail a").map { |link| link["href"] }

      paths.each do |path|
        get path

        assert_response :success
        assert_select "nav.rail a[href=?][aria-current=?]", path, "true", message: "#{role}: #{path}"
        assert_select "nav.rail a[aria-current]", count: 1
      end
      delete session_path
    end
  end

  test "the rail holds only hub items" do
    sign_in_as users(:admin)

    get parent_children_path

    assert_select "nav.rail > ul > li", count: 4
    assert_select "nav.rail > ul > li > a > span[aria-hidden=true]", count: 4
  end

  test "Account is the current hub on Voorkeuren and Profiel" do
    sign_in_as users(:parent)

    [ edit_preferences_path, user_profile_path(users(:parent)) ].each do |page|
      get page

      assert_response :success
      assert_select "nav.rail a[href=?][aria-current=?]", account_path, "true"
      assert_select "nav.rail + nav a[href=?][aria-current=?]", page, "page"
    end
  end

  test "Kinderen stays the current hub on a child's page, edit page and history" do
    sign_in_as users(:parent)
    child = child_profiles(:one)

    [ parent_child_path(child), edit_parent_child_path(child), parent_child_history_path(child) ].each do |page|
      get page

      assert_response :success
      assert_select "nav.rail a[href=?][aria-current=?]", parent_children_path, "true"
    end
  end

  test "Instellingen is the current hub on the settings page" do
    sign_in_as users(:parent)

    get parent_settings_path

    assert_select "nav.rail a[href=?][aria-current=?]", parent_settings_path, "true"
    assert_select "nav.rail a[aria-current]", count: 1
  end

  test "the back link on a child opened from the Kinderen list returns to the list" do
    sign_in_as users(:parent)
    get parent_children_path
    child_link = css_select("main a[href*='from=children.overview']").first["href"]

    get child_link

    assert_response :success
    assert_select "main > header > nav > a:first-child[href=?]", "#{parent_children_path}?from=children.overview",
      text: "‹ Overview"
  end

  test "a user opened from the user list links back to the list" do
    sign_in_as users(:admin)
    get admin_users_path
    user_link = css_select("main a[href^='#{admin_user_path(users(:parent))}?']").first["href"]

    get user_link

    assert_response :success
    assert_select "main > header > nav > a:first-child[href=?]", "#{admin_users_path}?from=admin.users",
      text: "‹ Users"
  end

  test "the header holds only the nav" do
    sign_in_as users(:parent)

    get parent_children_path

    assert_select "body > header > nav.rail"
    assert_select "nav.rail h2", count: 0
    assert_select "body > header a", text: "Home", count: 0
  end

  test "the Dutch nav shows appkit's wording" do
    sign_in_as users(:dutch_admin)

    get account_path

    assert_response :success
    assert_select "main nav a[href^=?]", edit_preferences_path, text: "Voorkeuren"
    assert_select "nav.rail a[href=?]", account_path, text: /Account/
    assert_select "nav button", count: 0
  end

  test "the login page is headed with the app name" do
    get new_session_path

    assert_response :success
    assert_select "h1", text: I18n.t("app.title")
  end

  private

  def rail_labels
    css_select("nav.rail > ul > li > a").map { |link| link.text.lines.map(&:strip).reject(&:empty?).last }
  end
end
