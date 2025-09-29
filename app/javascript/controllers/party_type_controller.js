// app/javascript/controllers/party_type_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["select","personSection","orgSection","personDestroy","orgDestroy"]

  connect(){ this.sync() }
  change(){ this.sync() }

  sync(){
    const partyType = this.hasSelectTarget ? this.selectTarget.value : "person"
    const isPerson = partyType === "person"

    if (this.hasPersonSectionTarget) this.personSectionTarget.classList.toggle("hidden", !isPerson)
    if (this.hasOrgSectionTarget)    this.orgSectionTarget.classList.toggle("hidden", isPerson)
    if (this.hasPersonDestroyTarget) this.personDestroyTarget.value = isPerson ? "0" : "1"
    if (this.hasOrgDestroyTarget)    this.orgDestroyTarget.value    = isPerson ? "1" : "0"

    // broadcast for identifier rows
    document.dispatchEvent(new CustomEvent("party:type-changed", { detail: { partyType } }))
  }
}
