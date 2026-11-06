require "test_helper"

class ActionRowTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent)
    @child = child_profiles(:one)
  end

  test "every data form ends in an action row with cancel and save" do
    sign_in_as @parent
    get edit_parent_child_path(@child)

    assert_select "main > article > section > form:has(> footer)", count: 5
    assert_select "main > article > section > form > footer:last-child", count: 5
    assert_select "main > article > section > form > footer > a[role=button][href=?]", parent_children_path, count: 5
    assert_select "main > article > section > form > footer > input[type=submit]", count: 5
  end

  test "child card goal form ends in an action row that cancels to the child" do
    sign_in_as @parent
    get parent_child_path(@child)

    assert_select "form[action=?] > footer:last-child > a[role=button][href=?]",
                  parent_child_card_goal_path(@child), parent_child_path(@child)
    assert_select "form[action=?] > footer:last-child > input[type=submit]", parent_child_card_goal_path(@child)
  end

  test "profile form ends in an action row that cancels to the profile" do
    sign_in_as @parent
    get edit_user_profile_path(@parent)

    assert_select "form > footer:last-child > a[role=button][href=?]", user_profile_path(@parent)
    assert_select "form > footer:last-child > input[type=submit]"
  end

  test "admin user form ends in an action row that cancels to the list" do
    sign_in_as users(:admin)
    get new_admin_user_path

    assert_select "form > footer:last-child > a[role=button][href=?]", admin_users_path
    assert_select "form > footer:last-child > input[type=submit]"
  end

  test "persisted allowance footer starts with the red turn off button for the delete form" do
    sign_in_as @parent
    allowance = allowances(:zakgeld_one)

    get edit_parent_child_path(@child)

    delete_form_id = "delete_allowance_#{allowance.id}"
    assert_select "form##{delete_form_id}[action=?]", parent_child_allowance_path(@child, allowance) do
      assert_select "input[name=_method][value=delete]"
    end
    assert_select "form[action=?] > footer > button:first-child.button-danger[form=?]",
                  parent_child_allowance_path(@child, allowance), delete_form_id,
                  text: I18n.t("parent.allowances.turn_off")
  end

  test "orders delete, cancel, save" do
    sign_in_as @parent

    get edit_parent_child_path(@child)

    assert_select "footer > button.button-danger + a[role=button] + input[type=submit]", count: 2
  end

  test "leaves delete out without a delete form id" do
    sign_in_as @parent

    get edit_parent_child_path(child_profiles(:two))

    assert_select "footer > button.button-danger", count: 0
    assert_select "main > article > section > form > footer", count: 5
  end

  test "turn off allowance still deletes through the delete form" do
    sign_in_as @parent
    allowance = allowances(:zakgeld_one)

    assert_difference -> { Allowance.count }, -1 do
      delete parent_child_allowance_path(@child, allowance)
    end
    assert_redirected_to edit_parent_child_path(@child)
  end

  test "cancel is a secondary role=button link before the submit" do
    sign_in_as @parent

    get edit_parent_child_path(@child)

    assert_select "footer > a.button-secondary[role=button] + input[type=submit]", minimum: 5
    assert_select "footer > input[type=submit].button-secondary", count: 0
  end
end
