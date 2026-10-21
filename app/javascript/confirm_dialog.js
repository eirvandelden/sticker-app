import { Turbo } from "@hotwired/turbo-rails"

// Turbo asks this for every data-turbo-confirm; answer with the native dialog from shared/_confirm_dialog.
Turbo.config.forms.confirm = (message) => {
  const dialog = document.getElementById("confirm-dialog")
  const abort = new AbortController()
  const { signal } = abort

  dialog.querySelector("#confirm-dialog-message").textContent = message

  return new Promise((resolve) => {
    let accepted = false

    dialog.querySelector("#confirm-dialog-accept").addEventListener("click", () => {
      accepted = true
      dialog.close()
    }, { signal })
    dialog.querySelector("#confirm-dialog-cancel").addEventListener("click", () => dialog.close(), { signal })
    dialog.addEventListener("close", () => {
      abort.abort()
      resolve(accepted)
    }, { signal, once: true })

    dialog.showModal()
  })
}
