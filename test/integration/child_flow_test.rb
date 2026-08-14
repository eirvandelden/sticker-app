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

  test "viewing the dashboard exposes completed card ids without recording anything in the session" do
    2.times { @card.stickers.create!(kind: :positive) }
    sign_in_as @child

    get child_dashboard_path

    assert_select "main[data-confetti-completed-card-ids-value=?]", [ @card.id ].to_json
    assert_nil session[:celebrated_card_ids]
  end

  test "revisiting the dashboard still reports the same completed card ids" do
    2.times { @card.stickers.create!(kind: :positive) }
    sign_in_as @child

    get child_dashboard_path
    get child_dashboard_path

    assert_select "main[data-confetti-completed-card-ids-value=?]", [ @card.id ].to_json
  end

  test "a completed card that already received its reward is not offered for confetti" do
    2.times { @card.stickers.create!(kind: :positive) }
    @card.reload.update!(reward_given: true)
    still_open_card = @profile.active_sticker_card
    still_open_card.stickers.create!(kind: :positive)
    sign_in_as @child

    get child_dashboard_path

    assert_select "main[data-confetti-completed-card-ids-value=?]", [ still_open_card.id ].to_json
  end
end
