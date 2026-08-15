require "test_helper"

class Parent::SettingsTest < ActionDispatch::IntegrationTest
  setup do
    @parent  = users(:parent)
    @child   = users(:user)
    @profile_one = child_profiles(:one)
    @profile_two = child_profiles(:two)
  end

  test "parent can view settings index with links to each child's settings page" do
    sign_in_as @parent
    get parent_settings_path

    assert_response :success
    assert_select "h1", text: I18n.t("parent.settings.index.title")
    assert_select "a[href='#{edit_parent_child_path(@profile_one)}']"
    assert_select "a[href='#{edit_parent_child_path(@profile_two)}']"
  end

  test "child is redirected away from settings index" do
    sign_in_as @child
    get parent_settings_path

    assert_redirected_to root_path
  end

  test "parent dashboard has no per-child edit link and has one Settings link" do
    sign_in_as @parent
    get parent_children_path

    assert_response :success
    assert_select "a[href='#{parent_settings_path}']", count: 1
    assert_select "a[href='#{edit_parent_child_path(@profile_one)}']", count: 0
    assert_select "a[href='#{edit_parent_child_path(@profile_two)}']", count: 0
  end
end
