import AppkitThemeController from "appkit/controllers/theme_controller"

export default class extends AppkitThemeController {
  connect() {
    super.connect()
    this.applyThemeFromNewBody = this.applyThemeFromNewBody.bind(this)
    document.addEventListener("turbo:before-render", this.applyThemeFromNewBody)
  }

  disconnect() {
    document.removeEventListener("turbo:before-render", this.applyThemeFromNewBody)
    super.disconnect()
  }

  themeSettings() {
    const source = (this.newBody || this.element).dataset

    return {
      colorScheme: source.colorScheme || "system",
      lightTheme: source.lightTheme || "solunized-light",
      darkTheme: source.darkTheme || "solunized-dark"
    }
  }

  applyThemeFromNewBody(event) {
    this.newBody = event.detail.newBody
    this.applyTheme()
    this.newBody = null
  }
}
