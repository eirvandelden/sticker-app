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

  test "viewing the dashboard exposes completed card ids" do
    2.times { @card.stickers.create!(kind: :positive) }
    sign_in_as @child

    get child_dashboard_path

    assert_select "div[data-confetti-completed-card-ids-value=?]", [ @card.id ].to_json
  end

  test "revisiting the dashboard still reports the same completed card ids" do
    2.times { @card.stickers.create!(kind: :positive) }
    sign_in_as @child

    get child_dashboard_path
    get child_dashboard_path

    assert_select "div[data-confetti-completed-card-ids-value=?]", [ @card.id ].to_json
  end

  test "child dashboard shows card goal as read-only text" do
    sign_in_as @child
    get child_dashboard_path

    assert_response :success
    assert_select "##{dom_id(@profile, :card)}" do
      assert_select "p", text: /New bike/
      assert_select "input[name*='goal']", count: 0
    end
  end

  test "child dashboard shows nothing for goal when card goal is blank" do
    @card.update_column(:goal, nil)

    sign_in_as @child
    get child_dashboard_path

    assert_response :success
    assert_select "##{dom_id(@profile, :card)} p", text: /Saving for/, count: 0
  end

  test "a completed card that already received its reward is not offered for confetti" do
    2.times { @card.stickers.create!(kind: :positive) }
    @card.reload.update!(reward_given: true)
    still_open_card = @profile.active_sticker_card
    still_open_card.stickers.create!(kind: :positive)
    sign_in_as @child

    get child_dashboard_path

    assert_select "div[data-confetti-completed-card-ids-value=?]", [ still_open_card.id ].to_json
  end

  test "child dashboard has a single main landmark" do
    sign_in_as @child
    get child_dashboard_path
    assert_response :success
    assert_select "main", count: 1
  end
end
