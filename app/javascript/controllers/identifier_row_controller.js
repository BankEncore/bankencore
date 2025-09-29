// app/javascript/controllers/identifier_row_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["valueInput","details","issuerCountry","issuerRegion","typeSelect","current","changeBtn"]

  connect() {
    this.updateVisibility()
    this._onPartyTypeChanged = this.onPartyTypeChanged.bind(this)
    document.addEventListener("party:type-changed", this._onPartyTypeChanged)
  }
  disconnect() {
    document.removeEventListener("party:type-changed", this._onPartyTypeChanged)
  }

  changeType(){ this.updateVisibility() }

  onPartyTypeChanged(e){
    const cur = this.typeSelectTarget.selectedOptions[0]?.dataset.code
    if (cur === "ssn" || cur === "ein") {
      const want = e.detail.partyType === "organization" ? "ein" : "ssn"
      const opt = Array.from(this.typeSelectTarget.options).find(o => o.dataset.code === want)
      if (opt) this.typeSelectTarget.value = opt.value
    }
    this.updateVisibility()
  }

  toggleChange(e){
    e.preventDefault()
    const open = !this.valueInputTarget.classList.contains("hidden")
    this.valueInputTarget.classList.toggle("hidden", open)
    this.changeBtnTarget.textContent = open ? "Change" : "Keep existing"
    if (!open) this.valueInputTarget.value = ""
  }

  toggleDetails(e){ e.preventDefault(); this.detailsTarget.classList.toggle("hidden") }

  updateVisibility(){
    const opt = this.typeSelectTarget.selectedOptions[0]
    const reqCountry = opt?.dataset.requireIssuerCountry === "true"
    const reqRegion  = opt?.dataset.requireIssuerRegion  === "true"
    this.issuerCountryTarget.closest(".field").classList.toggle("hidden", !reqCountry)
    this.issuerRegionTarget.closest(".field").classList.toggle("hidden", !reqRegion)
  }
}
