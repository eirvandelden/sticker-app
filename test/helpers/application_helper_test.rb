require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "a section tab is the current tab on its own page" do
    request.path_info = "/admin/users"

    assert_match "aria-current=\"page\"", nav_section_tab("Users", "/admin/users")
  end

  test "a section tab is the current tab on a page nested under it" do
    request.path_info = "/admin/users/5/edit"

    assert_match "aria-current=\"page\"", nav_section_tab("Users", "/admin/users")
  end

  test "a section tab is not the current tab on a page that merely starts with its name" do
    request.path_info = "/admin/users_export"

    assert_no_match "aria-current", nav_section_tab("Users", "/admin/users")
  end
end
