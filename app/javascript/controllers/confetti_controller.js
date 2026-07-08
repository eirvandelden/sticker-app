import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    completionFlagId: String
  }

  connect() {
    this.boundHandleStreamRender = this.handleStreamRender.bind(this)
    document.addEventListener("turbo:before-stream-render", this.boundHandleStreamRender)
  }

  disconnect() {
    document.removeEventListener("turbo:before-stream-render", this.boundHandleStreamRender)
  }

  handleStreamRender(event) {
    if (this.hasCompletionFlagIdValue && event.detail.newStream.target === this.completionFlagIdValue) {
      this.celebrate()
    }
  }

  celebrate() {
    this.element.dataset.confettiCelebrated = "true"

    const container = document.createElement("div")
    container.className = "confetti-container"
    document.body.appendChild(container)

    const emojis = ["🎉", "🎊", "✨", "🌟", "⭐", "🎈", "🎁", "🏆"]
    const count = 30

    for (let i = 0; i < count; i++) {
      const piece = document.createElement("span")
      piece.className = "confetti-piece"
      piece.textContent = emojis[Math.floor(Math.random() * emojis.length)]
      piece.style.left = Math.random() * 100 + "%"
      piece.style.animationDelay = Math.random() * 0.5 + "s"
      piece.style.animationDuration = 2 + Math.random() + "s"
      container.appendChild(piece)
    }

    setTimeout(() => container.remove(), 4000)
  }
}
