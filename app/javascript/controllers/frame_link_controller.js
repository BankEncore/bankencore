// app/javascript/controllers/frame_link_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static values = { url: String, frame: { type: String, default: "comm_modal_frame" } }
  open(e) {
    e.preventDefault()
    const id = this.frameValue
    if (!document.getElementById(id)) return window.location.assign(this.urlValue)
    window.Turbo.visit(this.urlValue, { frame: id })
  }
}
