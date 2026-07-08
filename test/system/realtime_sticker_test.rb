require "application_system_test_case"

# Scenario 14: Child's dashboard updates in real time when a parent gives stickers.
#
# Uses Capybara multi-session (using_session) to run a parent session and child session
# concurrently in the same test process. Asserts that visible DOM elements — the sticker
# grid, progress bar value, and notification text — update without a page reload.
class RealtimeStickerTest < ApplicationSystemTestCase
  teardown do
    Capybara.reset_sessions!
  end

  # Scenario 14a: Child dashboard shows new sticker without reload
  test "child dashboard updates live when a parent gives a sticker" do
    parent_user  = users(:parent)
    child_user, profile = child_ready_for_completion

    using_session(:child) do
      visit session_transfer_path(child_user.transfer_id)
      assert_current_path child_dashboard_path
      assert_selector "progress[value='2']", wait: 5
    end

    using_session(:parent) do
      sign_in_parent parent_user
      post_sticker_for profile
    end

    using_session(:child) do
      assert_selector "progress[value='3']", wait: 10
    end
  end

  # Scenario 14b: Child dashboard shows sticker notification live
  test "child dashboard shows sticker notification live when parent gives a sticker" do
    parent_user = users(:parent)
    child_user, profile = child_ready_for_completion

    using_session(:child) do
      visit session_transfer_path(child_user.transfer_id)
      assert_current_path child_dashboard_path
      assert_selector "progress", wait: 5
    end

    using_session(:parent) do
      sign_in_parent parent_user
      post_sticker_for profile
    end

    using_session(:child) do
      assert_selector "article[role='status']", wait: 10
    end
  end

  # Scenario 14c: Parent dashboard updates live when another parent gives a sticker
  test "parent dashboard updates live when a sticker is given" do
    parent_user = users(:parent)
    _child_user, profile = child_ready_for_completion

    using_session(:parent) do
      sign_in_parent parent_user
      visit parent_children_path
      assert_selector "progress[value='2']", wait: 5
    end

    using_session(:actor) do
      sign_in_parent parent_user
      post_sticker_for profile
    end

    using_session(:parent) do
      assert_selector "progress[value='3']", wait: 10
    end
  end

  # Scenario 14d: Confetti appears on card completion.
  #
  # Waits for turbo-cable-stream-source[connected] to ensure the ActionCable subscription is
  # established before the completion_flag broadcast fires.
  test "confetti container appears when a card completes" do
    parent_user = users(:parent)
    child_user, profile = child_ready_for_completion

    using_session(:child) do
      visit session_transfer_path(child_user.transfer_id)
      assert_current_path child_dashboard_path
      assert_selector "progress", wait: 5
      assert_selector "turbo-cable-stream-source[connected]", visible: :all, wait: 5
    end

    using_session(:parent) do
      sign_in_parent parent_user
      post_sticker_for profile
    end

    using_session(:child) do
      assert_selector ".confetti-container", wait: 10
    end
  end

  private

  def child_ready_for_completion
    child = User.create!(
      name: "Realtime Child",
      email: "realtime-#{SecureRandom.hex(4)}@example.com",
      password: "password",
      role: :child
    )
    profile = child.child_profile
    profile.update!(sticker_goal: 3)
    2.times { profile.active_sticker_card.stickers.create!(kind: :positive, giver: users(:parent)) }
    [ child, profile ]
  end

  def sign_in_parent(user)
    visit new_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Login"
    assert_current_path parent_children_path
  end

  def post_sticker_for(profile)
    visit parent_children_path
    find("form[action*='#{parent_child_sticker_path(profile)}'] button").click
  end
end
