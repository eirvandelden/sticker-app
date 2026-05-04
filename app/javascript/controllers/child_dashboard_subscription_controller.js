import { Controller } from "@hotwired/stimulus"
import * as ActionCable from "@rails/actioncable"

export default class extends Controller {
  static values = {
    childProfileId: Number
  }

  connect() {
    if (this.hasChildProfileIdValue) {
      this.consumer = ActionCable.createConsumer()
      this.subscription = this.consumer.subscriptions.create(
        { channel: "ChildProfileChannel", child_profile_id: this.childProfileIdValue },
        {
          received: this.handleMessage.bind(this)
        }
      )
    }
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  handleMessage(data) {
    if (data.action === "sticker_added") {
      this.handleStickerAdded(data)
    } else if (data.action === "card_completed") {
      this.handleCardCompleted(data)
    }
  }

  handleStickerAdded(data) {
    // Dispatch a custom event to trigger updates
    window.dispatchEvent(
      new CustomEvent("sticker-added", { detail: data })
    )
  }

  handleCardCompleted(data) {
    // Trigger confetti animation
    window.dispatchEvent(
      new Event("celebrate")
    )
  }
}
