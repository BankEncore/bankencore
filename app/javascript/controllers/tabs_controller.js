import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "button"]
  static values = { active: String }

  connect() {
    const key = this.activeValue || this.buttonTargets[0]?.dataset.tab
    this.showByKey(key)
  }

  show(e) { this.showByKey(e.currentTarget.dataset.tab) }

  showByKey(key) {
    if (!key) return
    this.panelTargets.forEach(p => p.classList.toggle("hidden", p.dataset.panel !== key))
    this.buttonTargets.forEach(b => {
      const on = b.dataset.tab === key
      b.classList.toggle("menu-active", on)
      b.ariaSelected = on
    })
    this.activeValue = key
  }
}
