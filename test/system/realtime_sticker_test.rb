require "application_system_test_case"

# Scenario 14: Child's dashboard updates in real time when a parent gives stickers.
#
# Uses Capybara multi-session (using_session) to run a parent session and child session
# concurrently in the same test process. Asserts that visible DOM elements — the sticker
# grid, progress bar value, and notification text — update without a page reload.
class RealtimeStickerTest < ApplicationSystemTestCase
  # Scenario 14a: Child dashboard shows new sticker without reload
  test "child dashboard updates live when a parent gives a sticker" do
    child_user   = users(:user_three)
    parent_user  = users(:parent)
    profile      = child_profiles(:three)
    card         = sticker_cards(:three)

    # Sign the child in — card three has sticker_goal:3 with 2 positive stickers already.
    # Progress is 2/3, so the progress bar value should start at 2.
    using_session(:child) do
      visit session_transfer_path(child_user.transfer_id)
      assert_current_path child_dashboard_path
      assert_selector "progress[value='2']", wait: 5
    end

    # Sign the parent in and give a sticker from the parent session.
    using_session(:parent) do
      sign_in_parent parent_user
      post_sticker_for profile
    end

    # Back on the child session: progress bar should now show 3/3 without a reload.
    using_session(:child) do
      assert_selector "progress[value='3']", wait: 10
    end
  end

  # Scenario 14b: Child dashboard shows sticker notification live
  test "child dashboard shows sticker notification live when parent gives a sticker" do
    child_user  = users(:user_three)
    parent_user = users(:parent)
    profile     = child_profiles(:three)

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
    profile     = child_profiles(:three)

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

  # Scenario 14d: Confetti appears on card completion
  test "confetti container appears when a card completes" do
    child_user  = users(:user_three)
    parent_user = users(:parent)
    profile     = child_profiles(:three)

    using_session(:child) do
      visit session_transfer_path(child_user.transfer_id)
      assert_current_path child_dashboard_path
      assert_selector "progress", wait: 5
    end

    # Give the one sticker needed to complete the card (currently at 2/3).
    using_session(:parent) do
      sign_in_parent parent_user
      post_sticker_for profile
    end

    using_session(:child) do
      assert_selector ".confetti-container", wait: 10
    end
  end

  private

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
