// app/javascript/controllers/reveal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }
  static targets = ["text", "button", "spinner"]

  async reveal(event) {
    event?.preventDefault()

    // simple demo fallback if no URL provided
    if (!this.hasUrlValue || !this.urlValue) {
      this.textTarget.textContent = "reveal clicked"
      return
    }

    this.buttonTarget.disabled = true
    this.buttonTarget.classList.add("hidden")
    if (this.hasSpinnerTarget) this.spinnerTarget.classList.remove("hidden")

    try {
      const res = await fetch(this.urlValue, {
        headers: { "Accept": "application/json" },
        credentials: "same-origin"
      })
      if (!res.ok) throw new Error("Reveal failed")
      const { value } = await res.json()
      this.textTarget.textContent = value || ""
    } catch (e) {
      console.error(e)
      this.buttonTarget.disabled = false
      this.buttonTarget.classList.remove("hidden")
      alert("Unable to reveal right now.")
    } finally {
      if (this.hasSpinnerTarget) this.spinnerTarget.classList.add("hidden")
    }
  }
}
