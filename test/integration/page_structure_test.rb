require "test_helper"

class PageStructureTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent)
    @admin = users(:admin)
    @child = child_profiles(:one)
  end

  test "every page has one h1 in main > header" do
    pages.each do |user, paths|
      reset!
      sign_in_as user
      paths.each do |path|
        get path

        assert_response :success, path
        assert_select "h1", count: 1, message: "#{path} needs one h1"
        assert_select "main > header > h1", count: 1, message: "#{path} h1 sits in main > header"
        assert_select "main > header ~ header", count: 0
        assert_select "main > section > header > h1", count: 0
        assert_select "main > div > header > h1", count: 0
        assert_select "main main", count: 0
      end
    end
  end

  test "page links sit in the title bar nav" do
    sign_in_as @parent
    get parent_children_path

    assert_select "main > header > nav a[href=?]", parent_settings_path

    get parent_child_path(@child)

    assert_select "main > header > nav a[href=?]", parent_child_history_path(@child)
    assert_select "main > header > nav a[href=?]", parent_children_path

    get edit_parent_child_path(@child)

    assert_select "main > header > nav a[href=?]", parent_children_path

    get parent_child_history_path(@child)

    assert_select "main > header > nav a[href=?]", parent_children_path

    reset!
    sign_in_as @admin
    get admin_users_path

    assert_select "main > header > nav a[href=?]", new_admin_user_path

    get user_profile_path(@admin)

    assert_select "main > header > nav a[href=?]", edit_user_profile_path(@admin)
  end

  test "title bar renders the nav only with links" do
    sign_in_as @admin

    get admin_root_path

    assert_select "main > header > h1", count: 1
    assert_select "main > header > nav", count: 0
  end

  test "title bar sets the heading id when given" do
    sign_in_as @admin

    get admin_users_path

    assert_select "main > header > h1#admin_users_heading", count: 1
  end

  test "no data element sits inside a link" do
    sign_in_as @parent
    get parent_children_path

    assert_select "a data", count: 0

    get parent_child_path(@child)

    assert_select "a data", count: 0

    reset!
    sign_in_as @child.user
    get child_dashboard_path

    assert_select "a data", count: 0
  end

  test "push button sits in a main section with a heading on parent pages" do
    sign_in_as @parent

    [ parent_children_path, parent_child_path(@child), edit_parent_child_path(@child),
      parent_settings_path, parent_child_history_path(@child) ].each do |path|
      get path

      assert_select "main > section[data-controller=push]:last-child", count: 1, message: path do
        assert_select "h2:first-child", text: I18n.t("parent.push.heading"), count: 1
        assert_select "button[data-action='push#subscribe']", count: 1
      end
      assert_select "body > fieldset[data-controller=push]", count: 0
    end
  end

  test "push heading reads in English, Dutch and Italian" do
    { en: "Reminders", nl: "Herinneringen", it: "Promemoria" }.each do |locale, heading|
      @parent.update!(locale: locale)
      reset!
      sign_in_as @parent

      get parent_children_path

      assert_select "main > section[data-controller=push] > h2", text: heading
    end
  end

  test "broadcast targets stay on their partial roots" do
    sign_in_as @parent
    get parent_children_path

    assert_select "article##{dom_id(@child, :dashboard_row)} > div##{dom_id(@child, :dashboard_progress)}"
    assert_select "article##{dom_id(@child, :dashboard_row)} span##{dom_id(@child, :completion_flag)}"

    get parent_child_path(@child)

    assert_select "section##{dom_id(@child, :parent_card)}"

    reset!
    sign_in_as @child.user
    get child_dashboard_path

    assert_select "section##{dom_id(@child, :card)}"
    assert_select "section##{dom_id(@child, :notifications)}"
    assert_select "span##{dom_id(@child, :completion_flag)}"
  end

  private

  def pages
    { users(:parent) => [ parent_children_path, parent_child_path(child_profiles(:one)),
                          edit_parent_child_path(child_profiles(:one)), parent_settings_path,
                          parent_child_history_path(child_profiles(:one)),
                          user_profile_path(users(:parent)), edit_user_profile_path(users(:parent)) ],
      users(:admin) => [ admin_root_path, admin_users_path, admin_user_path(users(:parent)),
                         new_admin_user_path, edit_admin_user_path(users(:parent)) ],
      users(:user) => [ child_dashboard_path ] }
  end
end
