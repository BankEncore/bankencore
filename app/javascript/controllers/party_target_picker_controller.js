// app/javascript/controllers/party_target_picker_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { lookupUrl: String, allowedTypes: Array }
  static targets = ["input", "hidden", "menu"]

  connect() { this.timer = null; console.log("party-target-picker connected") }

  search() {
    clearTimeout(this.timer)
    const q = this.inputTarget.value.trim()
    if (!q) { this.menuTarget.innerHTML = ""; this.hiddenTarget.value = ""; return }
    this.timer = setTimeout(async () => {
      try {
        const url = new URL(this.lookupUrlValue, window.location.origin)
        url.searchParams.set("q", q)
        let t = this.hasAllowedTypesValue ? this.allowedTypesValue : []
        if (!Array.isArray(t)) t = String(t || "").replace(/[\[\]\s"]/g, "").split(",").filter(Boolean)
        const csv = t.join(",")
        if (csv) url.searchParams.set("types", csv)
        const res = await fetch(url.toString(), { headers: { Accept: "application/json" } })
        if (!res.ok) { this.menuTarget.innerHTML = ""; return }
        const items = await res.json()
        this.menuTarget.innerHTML = items.map(i =>
          `<button type="button" data-public-id="${i.public_id}" class="btn btn-ghost btn-xs w-full justify-start">${i.label}</button>`
        ).join("")
      } catch { this.menuTarget.innerHTML = "" }
    }, 200)
  }

  pick(e) {
    const btn = e.target.closest("button[data-public-id]")
    if (!btn) return
    this.hiddenTarget.value = btn.dataset.publicId
    this.inputTarget.value = btn.textContent.trim()
    this.menuTarget.innerHTML = ""
  }

  clear() { this.hiddenTarget.value = ""; this.menuTarget.innerHTML = "" }
}
