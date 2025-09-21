// dependent_select_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["country","region"]
  static values = { url: String }
  connect(){ this.refresh() }
  async refresh(){
    const code = this.countryTarget.value
    this.regionTarget.innerHTML = "<option value=''>Select region</option>"
    if (!code) return
    const res = await fetch(`${this.urlValue}?country=${encodeURIComponent(code)}`, { headers: { Accept: "application/json" }})
    if (!res.ok) return
    const list = await res.json()
    this.regionTarget.insertAdjacentHTML("beforeend",
      list.map(r => `<option value="${r.code}">${r.name}</option>`).join("")
    )
    const current = this.regionTarget.getAttribute("data-current")
    if (current) this.regionTarget.value = current
  }
}