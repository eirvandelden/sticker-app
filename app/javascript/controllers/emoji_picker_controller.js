import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  toggle(event) {
    const show = event.target.value === "choose"
    this.selectTarget.hidden = !show
  }
}
