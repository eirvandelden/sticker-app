require "application_system_test_case"

class PageStructureSystemTest < ApplicationSystemTestCase
  test "cancel reads plain next to a filled save" do
    sign_in users(:parent)

    visit edit_parent_child_path(child_profiles(:one))

    cancel = first("main > article > section > form > footer > a[role=button]")
    save = first("main > article > section > form > footer > input[type=submit]")
    surface = evaluate_script("getComputedStyle(arguments[0].closest('article')).backgroundColor", cancel)
    cancel_background = background_of(cancel)

    assert_not_equal background_of(save), cancel_background
    assert_equal surface, cancel_background
  end

  test "admin users table stacks with cell labels on a phone" do
    sign_in users(:admin)
    emulate_phone(width: 375, height: 812)

    visit admin_users_path

    cell = first("table[data-stack] tbody td[data-label]")
    label = evaluate_script("getComputedStyle(arguments[0], '::before').content", cell)

    assert_includes label, cell[:"data-label"]
    assert_operator evaluate_script("document.documentElement.scrollWidth"), :<=, 375
  end

  private

  def background_of(element)
    evaluate_script("getComputedStyle(arguments[0]).backgroundColor", element)
  end

  def sign_in(user)
    visit session_transfer_path(user.transfer_id)

    assert_selector "main", wait: 10
  end
end
