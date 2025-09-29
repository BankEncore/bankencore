import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "row", "details",
    "typeName", "primaryBadge",
    "masked", "full",
    "issuer", "issuedOn", "expiresOn",
    "revealBtn", "copyBtn", "spinner"
  ]

  connect() {
    this.selected = null
    this.hideTimer = null
  }

  select(event) {
    const el = event.currentTarget
    this.selected = {
      id: el.dataset.id,
      typeName: el.dataset.typeName || "—",
      isPrimary: el.dataset.isPrimary === "true",
      masked: el.dataset.masked || "—",
      revealUrl: el.dataset.revealUrl,
      issuer: el.dataset.issuer || "—",
      issuedOn: el.dataset.issuedOn || "—",
      expiresOn: el.dataset.expiresOn || "—"
    }

    this._renderDetails()
  }

  async reveal() {
    if (!this.selected?.revealUrl) return
    this._setBusy(true)
    try {
      const res = await fetch(this.selected.revealUrl, { headers: { "Accept": "application/json" }, cache: "no-store" })
      if (!res.ok) throw new Error("Reveal failed")
      const data = await res.json()
      const full = data?.value || "(unavailable)"
      this.fullTarget.textContent = full
      this.copyBtnTarget.disabled = !full || full === "(unavailable)"
      this._armAutoHide()
    } catch (e) {
      this.fullTarget.textContent = "(error)"
    } finally {
      this._setBusy(false)
    }
  }

  async copy() {
    const val = this.fullTarget.textContent?.trim()
    if (!val || val === "—" || val === "(unavailable)" || val === "(error)") return
    try { await navigator.clipboard.writeText(val) } catch {}
  }

  // ----- private -----
  _renderDetails() {
    // show details panel
    this.detailsTarget.hidden = false

    // update labels
    this.typeNameTarget.textContent = this.selected.typeName
    this.primaryBadgeTarget.hidden = !this.selected.isPrimary
    this.maskedTarget.textContent = this.selected.masked
    this.fullTarget.textContent = "—"
    this.issuerTarget.textContent = this.selected.issuer
    this.issuedOnTarget.textContent = this.selected.issuedOn
    this.expiresOnTarget.textContent = this.selected.expiresOn

    // enable buttons
    this.revealBtnTarget.disabled = !this.selected.revealUrl
    this.copyBtnTarget.disabled = true

    // clear any prior hide timer
    if (this.hideTimer) clearTimeout(this.hideTimer)
  }

  _armAutoHide() {
    if (this.hideTimer) clearTimeout(this.hideTimer)
    this.hideTimer = setTimeout(() => {
      this.fullTarget.textContent = "—"
      this.copyBtnTarget.disabled = true
    }, 15000)
  }

  _setBusy(b) {
    this.spinnerTarget.classList.toggle("hidden", !b)
    this.revealBtnTarget.disabled = b
    this.copyBtnTarget.disabled = b || this.fullTarget.textContent === "—"
  }
}
