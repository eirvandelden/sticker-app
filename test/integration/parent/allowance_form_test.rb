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
end
