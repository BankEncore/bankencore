import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }
  static targets = ["btn", "icon"]

  async copy(e) {
    e?.preventDefault()
    const text = this.textValue || this.element?.innerText || ""
    try {
      await navigator.clipboard.writeText(text.trim())
      this.flash()
    } catch {
      this.fallback(text)
      this.flash()
    }
  }

  fallback(text) {
    const ta = document.createElement("textarea")
    ta.value = text
    ta.setAttribute("readonly", "")
    ta.style.position = "absolute"
    ta.style.left = "-9999px"
    document.body.appendChild(ta)
    ta.select()
    document.execCommand("copy")
    document.body.removeChild(ta)
  }

  flash() {
    if (!this.hasBtnTarget) return
    this.btnTarget.classList.add("btn-success")
    setTimeout(() => this.btnTarget.classList.remove("btn-success"), 800)
  }
}
