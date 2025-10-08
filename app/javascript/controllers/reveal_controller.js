import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["text","button","spinner"]
  static values = { url: String }

  async reveal(e) {
    e?.preventDefault()
    const url = this.urlValue || this.element.dataset.url
    if (!url) { console.error("reveal: missing url"); return }
    this.#loading(true)
    try {
      const res = await fetch(url, { headers: { "Accept":"application/json" }, credentials:"same-origin" })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const { value } = await res.json()
      this.textTarget.textContent = value || "(empty)"
    } catch (err) {
      console.error("reveal failed:", err)
      alert("Unable to reveal identifier.")
    } finally {
      this.#loading(false)
    }
  }

  async copy(e) {
    e?.preventDefault()
    const t = this.textTarget.textContent?.trim()
    if (!t || t.includes("•")) return
    await navigator.clipboard.writeText(t)
  }

  #loading(on) {
    if (this.hasSpinnerTarget) this.spinnerTarget.classList.toggle("hidden", !on)
    if (this.hasButtonTarget)  this.buttonTarget.disabled = on
  }
}
