import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  connect() {
    // Start with first group expanded, others collapsed
    this.contentTargets.forEach((content, index) => {
      if (index > 0) {
        content.style.display = "none"
      }
    })
  }

  toggle(event) {
    event.preventDefault()
    const content = this.contentTarget
    const isHidden = content.style.display === "none"

    if (isHidden) {
      content.style.display = "block"
      event.target.closest("h2").classList.add("expanded")
    } else {
      content.style.display = "none"
      event.target.closest("h2").classList.remove("expanded")
    }
  }
}
