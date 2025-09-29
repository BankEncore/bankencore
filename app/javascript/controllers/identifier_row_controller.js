import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["valueInput","details","issuerCountry","issuerRegion","typeSelect","current","changeBtn"]
  connect(){ this.updateVisibility() }

  changeType(){ this.updateVisibility() }

  toggleChange(e){
    e.preventDefault()
    const open = !this.valueInputTarget.classList.contains("hidden")
    this.valueInputTarget.classList.toggle("hidden", open)
    this.changeBtnTarget.textContent = open ? "Change" : "Keep existing"
    if (!open) this.valueInputTarget.value = ""
  }

  updateVisibility(){
    // data-* on the selected option carries rules
    const opt = this.typeSelectTarget.selectedOptions[0]
    const reqCountry = opt?.dataset.requireIssuerCountry === "true"
    const reqRegion  = opt?.dataset.requireIssuerRegion  === "true"

    this.issuerCountryTarget.closest(".field").classList.toggle("hidden", !reqCountry)
    this.issuerRegionTarget.closest(".field").classList.toggle("hidden", !reqRegion)

    // Always keep details collapsed by default; user can open if needed
    this.detailsTarget.classList.add("hidden")
  }

  toggleDetails(e){
    e.preventDefault()
    this.detailsTarget.classList.toggle("hidden")
  }
}
