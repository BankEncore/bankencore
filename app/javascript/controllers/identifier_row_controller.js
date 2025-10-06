// app/javascript/controllers/identifier_row_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["valueInput","details","issuerCountry","issuerRegion","typeSelect","current","changeBtn"]

  connect() {
    this.updateVisibility()
    // respond when party type flips person/org
    this._onPartyTypeChanged = this.onPartyTypeChanged.bind(this)
    document.addEventListener("party:type-changed", this._onPartyTypeChanged)
    // adjust region gating when country changes
    this._onCountryChange = this.updateVisibility.bind(this)
    if (this.hasIssuerCountryTarget) this.issuerCountryTarget.addEventListener("change", this._onCountryChange)
  }

  disconnect() {
    document.removeEventListener("party:type-changed", this._onPartyTypeChanged)
    if (this.hasIssuerCountryTarget) this.issuerCountryTarget.removeEventListener("change", this._onCountryChange)
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
    if (!open) {
      // clear the actual input inside the container
      const input = this.valueInputTarget.querySelector("input,textarea")
      if (input) input.value = ""
    }
  }

  toggleDetails(e){ e.preventDefault(); this.detailsTarget.classList.toggle("hidden") }

  updateVisibility(){
    const opt = this.typeSelectTarget.selectedOptions[0]
    const reqCountry = opt?.dataset.requireIssuerCountry === "true"
    const reqRegion  = opt?.dataset.requireIssuerRegion  === "true"

    // containers (support .field or .form-control)
    const countryWrap = this.issuerCountryTarget?.closest(".field, .form-control")
    const regionWrap  = this.issuerRegionTarget?.closest(".field, .form-control")

    const countrySelected = !!(this.issuerCountryTarget?.value)

    // show/hide country
    if (countryWrap) countryWrap.classList.toggle("hidden", !reqCountry)

    // region visible only if the type requires region AND a country is selected
    const showRegion = reqCountry && reqRegion && countrySelected
    if (regionWrap) regionWrap.classList.toggle("hidden", !showRegion)
    if (this.hasIssuerRegionTarget) this.issuerRegionTarget.disabled = !showRegion
  }
}
