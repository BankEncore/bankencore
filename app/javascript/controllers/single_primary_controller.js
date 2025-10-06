// app/javascript/controllers/single_primary_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row","radio","hidden"]

  connect() {
    // Don’t override existing choices. If none is checked, respect any hidden=1.
    const anyChecked = this.radioTargets.some(r => r.checked)
    if (!anyChecked) {
      const idx = this.hiddenTargets.findIndex(h => h.value === "1")
      if (idx >= 0 && this.radioTargets[idx]) this.radioTargets[idx].checked = true
    }
  }

  pick(e) {
    const picked = e.currentTarget
    // zero all, uncheck all
    this.hiddenTargets.forEach(h => { h.value = "0" })
    this.radioTargets.forEach(r => { r.checked = false })
    // set picked to 1
    picked.checked = true
    const row = picked.closest("[data-single-primary-target='row']")
    const hid = row?.querySelector("[data-single-primary-target='hidden']")
    if (hid) hid.value = "1"
  }
}
