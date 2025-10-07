import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // called after Turbo form submit
  afterSubmit(e) {
    if (e.detail?.success) {
      this.element.closest("details")?.removeAttribute("open")
      this.element.reset()
    }
  }
}
