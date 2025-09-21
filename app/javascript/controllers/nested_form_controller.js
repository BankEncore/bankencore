// app/javascript/controllers/nested_form_controller.js
import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["container", "template"]
  add(e){ e.preventDefault(); this.containerTarget.insertAdjacentHTML("beforeend",
    this.templateTarget.innerHTML.replace(/NEW_RECORD/g, Date.now().toString())
  )}
  remove(e){
    e.preventDefault()
    const wrapper = e.target.closest("[data-address-wrapper]")
    wrapper.querySelector("input[name*='[_destroy]']").value = "1"
    wrapper.classList.add("hidden")
  }

  // app/javascript/controllers/nested_form_controller.js
  add(e){
    e.preventDefault()
    const tmpl = this.templateTarget.content.cloneNode(true)
    const el = tmpl.querySelector("[data-address-wrapper]")
    // default country to US if empty
    const country = el.querySelector('[data-dependent-select-target="country"]')
    if (country && !country.value) {
      country.value = "US"
      country.dispatchEvent(new Event("change"))
    }
    this.containerTarget.appendChild(tmpl)
  }

}
