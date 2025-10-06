// app/javascript/controllers/group_picker_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["search","select"]
  connect(){ this.timer=null }
  open(){ this.element.closest("dialog")?.showModal?.() }

  async fetch() {
    const q = this.searchTarget.value.trim()
    const res = await fetch(`/party/groups/lookup.json?q=${encodeURIComponent(q)}`)
    const rows = await res.json()
    this.selectTarget.innerHTML = rows.map(r=>`<option value="${r.id}">${r.name}</option>`).join("")
    this.updateAction()
  }

  updateAction(){
    const id = this.selectTarget.value
    if(!id) return
    this.element.action = `/party/groups/${id}/memberships`
  }

  searchTargetConnected(el){ el.addEventListener("input", ()=>{ clearTimeout(this.timer); this.timer=setTimeout(()=>this.fetch(), 200) }) }
  selectTargetConnected(el){ el.addEventListener("change", ()=>this.updateAction()) }
}
