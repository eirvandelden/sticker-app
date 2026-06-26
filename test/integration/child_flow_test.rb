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
    assert_select "progress[aria-label=?]", I18n.t("child.dashboard.earned", current: 0, total: 2)
  end
end
