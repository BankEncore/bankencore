import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["row","radio","hidden"];

  connect() {
    // If none checked, check the first and set its hidden to 1
    const any = this.radioTargets.some(r => r.checked);
    if (!any && this.radioTargets[0]) {
      this.radioTargets[0].checked = true;
      this._setHidden(this.radioTargets[0], 1);
    }
  }

  pick(e) {
    const picked = e.currentTarget;
    // uncheck all others and zero their hidden fields
    this.radioTargets.forEach(r => {
      if (r !== picked) {
        r.checked = false;
        this._setHidden(r, 0);
      }
    });
    // set picked to 1
    this._setHidden(picked, 1);
  }

  _setHidden(radio, val) {
    // find sibling hidden input inside the same row
    const row = radio.closest("[data-single-primary-target='row']");
    const hid = row?.querySelector("[data-single-primary-target='hidden']");
    if (hid) hid.value = String(val);
  }
}
