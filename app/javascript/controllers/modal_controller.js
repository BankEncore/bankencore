import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.dialog = this.element // the <dialog>
    document.addEventListener("turbo:before-cache", () => this.forceClose())
  }

  open() {
    if (!this.dialog.open) this.dialog.showModal()
  }

  close() {
    this.forceClose()
  }

  maybeClose(event) {
    // Close on successful submit (2xx) and clear frame content
    if (event.detail?.success) this.forceClose()
  }

  forceClose() {
    try { this.dialog.close() } catch (_) {}
    const frame = this.dialog.querySelector("#comm_modal_frame")
    if (frame) frame.innerHTML = "" // clear stale content so next load re-opens
  }
}
