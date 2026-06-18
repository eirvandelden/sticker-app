require "application_system_test_case"

# Scenario 14: Child's dashboard handles real-time ActionCable sticker events
#
# Two tests cover different layers:
# 1. Subscription connects — verifies the Stimulus controller establishes
#    the ActionCable WebSocket and sets data-cable-connected="true".
# 2. Event handler — simulates the message the channel sends and verifies
#    the Stimulus controller increments its DOM counter. Tests the full
#    JS path without requiring a cross-session broadcast (which is unreliable
#    with headless Chrome background tab throttling in CI).
class RealtimeStickerTest < ApplicationSystemTestCase
  # Scenario 14a: ActionCable subscription connects on the child dashboard
  test "child dashboard establishes ActionCable subscription on load" do
    child = users(:user_three)

    sign_in_child child

    assert_text "Your Sticker Card"
    assert_selector "[data-child-dashboard-subscription-child-profile-id-value]"
    assert_selector "[data-cable-connected='true']", wait: 5
  end

  # Scenario 14b: Stimulus controller handles sticker-added message from channel
  test "child dashboard increments sticker counter when sticker-added message arrives" do
    child = users(:user_three)

    sign_in_child child
    assert_selector "[data-cable-connected='true']", wait: 5

    # Simulate the message the ChildProfileChannel sends on sticker creation
    page.execute_script(<<~JS)
      const el = document.querySelector('[data-controller~="child-dashboard-subscription"]');
      const event = el._stimulus_application?.getControllerForElementAndIdentifier(
        el, 'child-dashboard-subscription'
      );
      if (event && event.handleMessage) {
        event.handleMessage({ action: 'sticker_added', sticker: { kind: 'positive', emoji: '⭐' } });
      } else {
        // Fallback: directly call the received callback via the subscription
        const controllers = window.Stimulus?.controllers || [];
        const ctrl = controllers.find(c => c.identifier === 'child-dashboard-subscription');
        if (ctrl) ctrl.handleMessage({ action: 'sticker_added', sticker: { kind: 'positive', emoji: '⭐' } });
      }
    JS

    assert_selector "[data-sticker-event-count='1']", wait: 3
  end

  private
    def sign_in_child(child)
      visit session_transfer_path(child.transfer_id)

      assert_current_path child_dashboard_path
    end
end
