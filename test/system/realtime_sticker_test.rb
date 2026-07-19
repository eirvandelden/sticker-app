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
    parent_user = create_realtime_parent
    child_user, profile = child_with_progress(goal: 4, stickers: 2)

    using_session(:child) do
      visit session_transfer_path(child_user.transfer_id)
      # Auto-submits via Stimulus (connect -> requestSubmit -> PUT -> redirect),
      # not a user click; give it more time than Capybara's default wait.
      assert_current_path child_dashboard_path, wait: 10
      assert_selector "progress[value='2']", wait: 5
      wait_for_turbo_stream_connection
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
    parent_user = create_realtime_parent
    child_user, profile = child_with_progress(goal: 4, stickers: 2)

    using_session(:child) do
      visit session_transfer_path(child_user.transfer_id)
      # Auto-submits via Stimulus (connect -> requestSubmit -> PUT -> redirect),
      # not a user click; give it more time than Capybara's default wait.
      assert_current_path child_dashboard_path, wait: 10
      assert_selector "progress", wait: 5
      wait_for_turbo_stream_connection
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
    observer_parent = create_realtime_parent
    actor_parent = create_realtime_parent
    child_user, profile = child_with_progress(goal: 4, stickers: 2)

    using_session(:parent) do
      sign_in_parent observer_parent
      visit parent_children_path
      wait_for_turbo_stream_connection
      within_child_article(child_user) do
        assert_selector "progress[value='2']", wait: 5
      end
    end

    using_session(:actor) do
      sign_in_parent actor_parent
      post_sticker_for profile
    end

    using_session(:parent) do
      within_child_article(child_user) do
        assert_selector "progress[value='3']", wait: 10
      end
    end
  end

  # Scenario 14d: Confetti appears on card completion.
  #
  # Waits for turbo-cable-stream-source[connected] to ensure the ActionCable subscription is
  # established before the completion_flag broadcast fires.
  test "confetti container appears when a card completes" do
    parent_user = create_realtime_parent
    child_user, profile = child_ready_for_completion

    using_session(:child) do
      visit session_transfer_path(child_user.transfer_id)
      # Auto-submits via Stimulus (connect -> requestSubmit -> PUT -> redirect),
      # not a user click; give it more time than Capybara's default wait.
      assert_current_path child_dashboard_path, wait: 10
      assert_selector "progress", wait: 5
      wait_for_turbo_stream_connection
    end

    using_session(:parent) do
      sign_in_parent parent_user
      post_sticker_for profile
    end

    using_session(:child) do
      assert_selector "[data-confetti-celebrated='true']", wait: 10
    end
  end

  private

  def child_ready_for_completion
    child_with_progress(goal: 3, stickers: 2)
  end

  def child_with_progress(goal:, stickers:)
    child = create_realtime_child
    profile = child.child_profile
    profile.update!(sticker_goal: goal)
    stickers.times { profile.active_sticker_card.stickers.create!(kind: :positive, giver: users(:parent)) }
    [ child, profile ]
  end

  def create_realtime_child
    token = SecureRandom.hex(4)

    User.create!(
      name: "Realtime Child #{token}",
      email: "realtime-#{token}@example.com",
      password: "password",
      role: :child
    )
  end

  def create_realtime_parent
    token = SecureRandom.hex(4)

    User.create!(
      name: "Realtime Parent #{token}",
      email: "realtime-parent-#{token}@example.com",
      password: "password",
      role: :parent
    )
  end

  def sign_in_parent(user)
    visit new_session_path
    fill_in "Email address", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_current_path parent_children_path
  end

  def post_sticker_for(profile)
    visit parent_children_path
    wait_for_turbo_stream_connection
    within_child_article(profile.user) do
      click_button I18n.t("parent.actions.give_sticker")
    end
  end

  def wait_for_turbo_stream_connection
    connect_turbo_cable_stream_sources
  end

  def within_child_article(child)
    within(:xpath, "//article[.//h2[normalize-space()='#{child.name}']]") do
      yield
    end
  end
end
