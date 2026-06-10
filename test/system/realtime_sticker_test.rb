require "application_system_test_case"

# Scenario 14: Child's browser receives a real-time sticker update via ActionCable
#
# Implementation notes:
# - cable.yml test environment uses the :async adapter so broadcasts reach the
#   in-process headless Chrome session.
# - When a parent gives a sticker, `Sticker#after_create_commit :broadcast_sticker_added`
#   calls `ChildProfileChannel.broadcast_to` with `{ action: "sticker_added", ... }`.
# - The child_dashboard_subscription Stimulus controller's `handleStickerAdded` fires
#   `window.dispatchEvent(new CustomEvent("sticker-added", ...))`.
# - We register a JS listener before the broadcast and assert the event was received.
class RealtimeStickerTest < ApplicationSystemTestCase
  test "child receives sticker-added window event when parent gives a sticker via ActionCable" do
    child  = users(:user_three)
    parent = users(:parent)

    # Child logs in. After clicking Login, the session cookie is set.
    # We then navigate directly to the dashboard (Turbo's redirect handling
    # for form posts may not update the URL bar in all configurations).
    visit root_path
    fill_in "Email", with: child.email
    fill_in "Password", with: "password"
    click_button "Login"
    # Give Turbo time to process the form response, then navigate directly
    sleep 0.5
    visit child_dashboard_path
    assert_text "Your Sticker Card"

    # Verify the Stimulus data attribute is present so the subscription will fire
    assert_selector "[data-child-dashboard-subscription-child-profile-id-value]"

    # Register JS event listener for the ActionCable-triggered window event
    page.execute_script(<<~JS)
      window._stickerEventReceived = false;
      window.addEventListener('sticker-added', function() { window._stickerEventReceived = true; });
    JS

    # Wait for the WebSocket subscription to be established (controller sets data-cable-connected on success)
    assert_selector "[data-cable-connected='true']", wait: 5

    child_session = Capybara.session_name

    # Parent awards the completing sticker in a second browser session
    using_session("parent") do
      visit root_path
      fill_in "Email", with: parent.email
      fill_in "Password", with: "password"
      click_button "Login"
      sleep 0.5
      visit parent_children_path
      assert_text "Parent Dashboard"

      # Give sticker to user_three (child_profiles(:three) — 2/3 stickers,
      # one more completes the card). Scope to the article containing that
      # child's email so we target the right "Give Sticker" button.
      within("article", text: child.email) do
        click_button "🎉 Give Sticker"
      end
      # The broadcast fires server-side even if Turbo doesn't update the flash.
      # Brief pause to let the broadcast reach the cable server before switching sessions.
      sleep 0.5
    end

    # Back in child's session — wait for ActionCable to deliver the message.
    # The sticker_added broadcast dispatches a `sticker-added` window event
    # on the child dashboard. Poll for the JS flag to confirm receipt.
    using_session(child_session) do
      assert_eventually(
        -> { evaluate_script("window._stickerEventReceived") },
        wait: 8,
        message: "Expected child browser to receive the sticker-added window event via ActionCable"
      )
    end
  end

  private

  # Polls a block until truthy or the wait time expires.
  def assert_eventually(condition, wait: 5, message: "condition never became true")
    deadline = Time.now + wait
    loop do
      return if condition.call
      raise Minitest::Assertion, message if Time.now > deadline
      sleep 0.2
    end
  end
end
