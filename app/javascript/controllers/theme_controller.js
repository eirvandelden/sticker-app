import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["colorScheme", "lightTheme", "darkTheme"]

  connect() {
    this.updateTheme()
  }

  updateColorScheme() {
    this.updateTheme()
  }

  updateLightTheme() {
    this.updateTheme()
  }

  updateDarkTheme() {
    this.updateTheme()
  }

  updateTheme() {
    const html = document.documentElement
    const colorScheme = this.colorSchemeTarget?.value || "system"
    const lightTheme = this.lightThemeTarget?.value || "selenized_light"
    const darkTheme = this.darkThemeTarget?.value || "selenized_dark"

    html.dataset.colorScheme = colorScheme
    html.dataset.lightTheme = lightTheme
    html.dataset.darkTheme = darkTheme

    if (colorScheme === "light") {
      html.className = `light-${lightTheme}`
    } else if (colorScheme === "dark") {
      html.className = `dark-${darkTheme}`
    } else {
      html.className = ""
    }
  }
}
