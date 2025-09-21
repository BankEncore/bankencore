// app/javascript/controllers/toggle_input_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["field"]
  enable() {
    if (this.fieldTarget.hasAttribute("readonly")) {
      this.fieldTarget.removeAttribute("readonly")
    }
  }
}
