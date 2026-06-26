import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.systemThemeQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.applySystemThemeChange = this.applySystemThemeChange.bind(this)
    this.systemThemeQuery.addEventListener("change", this.applySystemThemeChange)
    this.applyTheme()
  }

  disconnect() {
    this.systemThemeQuery.removeEventListener("change", this.applySystemThemeChange)
  }

  applyTheme() {
    const html = document.documentElement
    const { colorScheme, lightTheme, darkTheme } = this.themeSettings()

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

  applySystemThemeChange() {
    const { colorScheme, lightTheme, darkTheme } = this.themeSettings()

    if (colorScheme === "system") this.applySystemTheme(lightTheme, darkTheme)
  }

  applySystemTheme(lightTheme, darkTheme) {
    const html = document.documentElement

    html.dataset.theme = this.mapToCSS(this.systemThemeQuery.matches ? darkTheme : lightTheme)
  }

  themeSettings() {
    const source = this.element.dataset

    return {
      colorScheme: source.colorScheme || "system",
      lightTheme: source.lightTheme || "selenized_light",
      darkTheme: source.darkTheme || "selenized_dark"
    }
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
