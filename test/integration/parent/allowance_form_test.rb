require "test_helper"

class Parent::AllowanceFormTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent)
    @child  = child_profiles(:two)
  end

  test "due day field allows a day of the month, not just a weekday" do
    sign_in_as @parent
    get edit_parent_child_path(@child)

    assert_response :success
    assert_select "input[name='allowance[due_day]'][max='31']"
  end

  test "turn off is a red DELETE button that removes the allowance" do
    sign_in_as @parent
    profile = child_profiles(:one)
    allowance = allowances(:zakgeld_one)

    get edit_parent_child_path(profile)

    assert_select "form[action=?] input[name=_method][value=delete]", parent_child_allowance_path(profile, allowance)
    assert_select "form[action=?] button.button-danger", parent_child_allowance_path(profile, allowance)

    assert_difference("Allowance.count", -1) do
      delete parent_child_allowance_path(profile, allowance)
    end
  end
end
