// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static values = { id: String }
  open()  { document.getElementById(this.idValue)?.showModal?.() }
  close() { document.getElementById(this.idValue)?.close?.() }
}
