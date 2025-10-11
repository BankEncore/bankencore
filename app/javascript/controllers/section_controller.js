import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["details"]

  connect() {
    this.open()
    this.element.addEventListener("turbo:frame-load", () => this.open())
    this.element.addEventListener("turbo:submit-end", () => this.open())
  }
  open() { if (this.hasDetailsTarget) this.detailsTarget.open = true }
}
