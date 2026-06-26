require "test_helper"

class ChildFlowTest < ActionDispatch::IntegrationTest
  setup do
    @child   = users(:user)
    @profile = child_profiles(:one)
    @card    = sticker_cards(:one)
  end

  # Scenario 13: Child views dashboard with sticker card
  test "child views dashboard showing active sticker card and progress" do
    sign_in_as @child
    get child_dashboard_path
    assert_response :success
    assert_select "article.stickers"
    assert_select "progress"
  end

  test "child dashboard renders a link to preferences" do
    sign_in_as @child
    get child_dashboard_path
    assert_response :success
    assert_select "a[href='#{edit_preferences_path}']"
  end
end
