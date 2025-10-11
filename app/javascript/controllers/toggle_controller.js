import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() { this.refresh(); }

  refresh() {
    // name Rails generates for nested attr: party_party[person][citizenship]
    const form = this.element.closest("form");
    const input = form?.querySelector('input[name="party_party[person][citizenship]"]:checked');
    const value = input?.value; // "domestic" or "foreign"
    const hide = (value === "domestic"); // hide nationality when domestic
    this.element.classList.toggle("hidden", hide);
  }
}
