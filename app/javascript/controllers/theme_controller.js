import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["colorScheme", "lightTheme", "darkTheme"]

  #mediaQuery = null
  #mediaListener = null

  connect() {
    this.#applyTheme()
  }

  disconnect() {
    this.#removeMediaListener()
  }

  update() {
    this.#applyTheme()
  }

  #applyTheme() {
    const html = document.documentElement
    const colorScheme = this.hasColorSchemeTarget ? this.colorSchemeTarget.value : html.dataset.colorScheme
    const lightTheme = this.hasLightThemeTarget ? this.lightThemeTarget.value : html.dataset.lightTheme
    const darkTheme = this.hasDarkThemeTarget ? this.darkThemeTarget.value : html.dataset.darkTheme

    this.#removeMediaListener()

    if (colorScheme === "light") {
      html.dataset.theme = this.#mapToCSS(lightTheme)
    } else if (colorScheme === "dark") {
      html.dataset.theme = this.#mapToCSS(darkTheme)
    } else {
      this.#applySystemTheme(lightTheme, darkTheme)
    }
  }

  #applySystemTheme(lightTheme, darkTheme) {
    const html = document.documentElement
    const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    const listener = (e) => {
      html.dataset.theme = this.#mapToCSS(e.matches ? darkTheme : lightTheme)
    }

    listener(mediaQuery)
    mediaQuery.addEventListener("change", listener)
    this.#mediaQuery = mediaQuery
    this.#mediaListener = listener
  }

  #removeMediaListener() {
    if (this.#mediaQuery) {
      this.#mediaQuery.removeEventListener("change", this.#mediaListener)
      this.#mediaQuery = null
      this.#mediaListener = null
    }
  }

  #mapToCSS(value) {
    const map = {
      selenized_light: "solunized-light",
      white: "solunized-white",
      selenized_dark: "solunized-dark",
      black: "solunized-black"
    }
    return map[value] || value
  }
}
