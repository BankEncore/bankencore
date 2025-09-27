// app/javascript/controllers/region_select_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }
  static targets = ["country", "region"]

  connect() { this.refresh() }

  async refresh() {
    const cc = this.countryTarget?.value
    if (!cc) { this.fill([]); return }
    try {
      const res = await fetch(`${this.urlValue}?country=${encodeURIComponent(cc)}`, { headers: { Accept: "application/json" } })
      const opts = await res.json() // [{code,name}]
      this.fill(opts)
    } catch {
      this.fill([])
    }
  }

  fill(opts) {
    const desired = this.regionTarget.dataset.selected || this.regionTarget.value || ""
    this.regionTarget.innerHTML =
      `<option value=""></option>` +
      opts.map(o => `<option value="${o.code}">${o.name}</option>`).join("")
    this.regionTarget.disabled = opts.length === 0

    if (desired && opts.some(o => o.code === desired)) {
      this.regionTarget.value = desired
    } else {
      this.regionTarget.value = ""
    }
    // keep selected for future refreshes
    this.regionTarget.dataset.selected = this.regionTarget.value
  }
}
