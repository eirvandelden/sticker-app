import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.boundCelebrate = this.celebrate.bind(this)
    window.addEventListener("celebrate", this.boundCelebrate)
  }

  disconnect() {
    window.removeEventListener("celebrate", this.boundCelebrate)
  }

  celebrate() {
    // Create confetti container
    const container = document.createElement("div")
    container.className = "confetti-container"
    document.body.appendChild(container)

    // Create multiple confetti pieces
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

    // Remove after animation completes
    setTimeout(() => container.remove(), 4000)
  }
}
