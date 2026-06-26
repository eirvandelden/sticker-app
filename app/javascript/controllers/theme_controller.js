import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.applyTheme()
  }

  applyTheme() {
    const html = document.documentElement
    const source = this.element.dataset
    const colorScheme = source.colorScheme || "system"
    const lightTheme = source.lightTheme || "selenized_light"
    const darkTheme = source.darkTheme || "selenized_dark"

    html.dataset.colorScheme = colorScheme
    html.dataset.lightTheme = lightTheme
    html.dataset.darkTheme = darkTheme

    if (colorScheme === "light") {
      html.dataset.theme = this.mapToCSS(lightTheme)
    } else if (colorScheme === "dark") {
      html.dataset.theme = this.mapToCSS(darkTheme)
    } else {
      this.applySystemTheme(lightTheme, darkTheme)
    }
  }

  applySystemTheme(lightTheme, darkTheme) {
    const html = document.documentElement
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches

    html.dataset.theme = this.mapToCSS(prefersDark ? darkTheme : lightTheme)
  }

  mapToCSS(value) {
    const map = {
      selenized_light: "solunized-light",
      white: "solunized-white",
      selenized_dark: "solunized-dark",
      black: "solunized-black"
    }
    return map[value] || value
  }
}
