**Title:** Configure Rails Active Record Encryption keys
**Body:**

* Add `active_record_encryption` keys to credentials for all envs.
* Verify app boots and can encrypt/decrypt.
  **Acceptance Criteria**
* `Rails.application.credentials.active_record_encryption` present.
* No encryption key errors on boot.
  **How to Test**

```bash
bin/rails r 'Party::Party.new(tax_id:"123").save!'
```

---

**Title:** Configure Blind Index master key (64 hex)
**Body:**

* Add `blind_index.master_key` (64 hex chars) to credentials or env var.
* Remove DEV fallback warnings.
  **Acceptance Criteria**
* No `[blind_index] invalid key length` warnings.
* `Party::Party.new(tax_id: "...").save!` populates `tax_id_bidx`.

---

**Title:** Preserve tax\_id on edit when left blank
**Body:**

* Controller: drop blank `:tax_id` from params on create/update.
* Model: override `tax_id=` to ignore blank.
  **Acceptance Criteria**
* Editing a Party without entering Tax ID keeps prior value.
* Entering a new Tax ID updates encrypted value + BIDX.

---

**Title:** Composite uniqueness on ref\_regions (country\_code, code)
**Body:**

* Drop PK/unique on `ref_regions.code`.
* Add unique index on `[:country_code, :code]`.
* Ensure idempotent migration (MariaDB-safe).
  **Acceptance Criteria**
* Can insert `('MI', 'Michigan', 'US')` and reuse `code` for another country.
  **Notes**
* Guard with `index_exists?`, `rescue nil`.

---

**Title:** Composite FK from party\_addresses → ref\_regions
**Body:**

* Add FK `party_addresses[:country_code, :region_code]` → `ref_regions[:country_code, :code]`.
* Add supporting index on referencing columns.
  **Acceptance Criteria**
* Invalid (country,region) pairs are rejected at DB level.

---

**Title:** Seed reference tables idempotently
**Body:**

* Email/Phone/Address/Organization types via upsert-by-code.
* No errors on repeated `db:seed`.
  **Acceptance Criteria**
* Running `bin/rails db:seed` twice is clean.

---

**Title:** Seed ISO countries & regions (US states)
**Body:**

* Load countries and regions; re-runnable.
* Ensure US states present.
  **Acceptance Criteria**
* `RefCountry.count > 200`, `RefRegion.where(country_code:"US").count >= 50`.

---

**Title:** Party#display\_name method
**Body:**

* For organization → `legal_name`.
* For person → `first_name last_name`.
* Fallback to `customer_number` or `public_id`.
  **Acceptance Criteria**
* Index/show views render a meaningful name.
  **How to Test**

```erb
<%= p.display_name %>
```

---

**Title:** Validate Address region belongs to country
**Body:**

* Model validation in `Party::Address`.
* Friendly error message.
  **Acceptance Criteria**
* Saving `region_code` not in selected `country_code` adds validation error.

---

**Title:** Customer number generator service
**Body:**

* Format `NNNNNNNYYX` (7-digit seq starting at 0001001 with wrap), 2-digit year, Luhn check.
* Unique index on `parties.customer_number`.
  **Acceptance Criteria**
* Sequential generation; passes Luhn; unique.

---

**Title:** Parties HTML CRUD (create/update with nested subprofiles)
**Body:**

* Forms for person/organization with nested attributes.
* Success redirects; failure shows errors.
  **Acceptance Criteria**
* New/Edit work; server-side validation messages displayed.

---

**Title:** Dynamic subprofiles toggle (Stimulus)
**Body:**

* `party_type_controller.js` toggles person/org sections.
* Sets `_destroy` flags accordingly.
  **Acceptance Criteria**
* Switching type hides irrelevant section; only one subprofile persists.

---

**Title:** Dependent region select (country → regions)
**Body:**

* `dependent_select_controller.js` fetches `/ref/regions?country=XX&_=${Date.now()}`.
* Preselect current region on edit.
  **Acceptance Criteria**
* Changing country refreshes regions; edit preselects current region.

---

**Title:** Nested addresses add/remove (Stimulus)
**Body:**

* `nested_form_controller.js` adds rows from `<template>`.
* Default `country_code = 'US'` for new rows and load regions.
  **Acceptance Criteria**
* Adding an address sets country to US and populates regions.

---

**Title:** Tax ID masking & reveal endpoint
**Body:**

* Show masked Tax ID in views.
* Reveal endpoint returns JSON decrypted value (auth hook ready).
  **Acceptance Criteria**
* Reveal button fetches `{ value: "..." }`; masked by default.

---

**Title:** Turn off browser save/autofill for Tax ID input
**Body:**

* Add `autocomplete="off"`, readonly-until-focus Stimulus.
  **Acceptance Criteria**
* Browsers don’t prompt to save Tax ID by default.

---

**Title:** Region API: disable caching
**Body:**

* Add `expires_now` to `Ref::RegionsController#index`.
* Client adds cache-buster query param.
  **Acceptance Criteria**
* Newly added regions appear immediately after fetch.

---

**Title:** Tests: models (Party, Address, CustomerNumber)
**Body:**

* Party validations, display\_name.
* Address region-country validation.
* Customer number Luhn/format/wrap.
  **Acceptance Criteria**
* Specs pass locally.

---

**Title:** Tests: requests (parties create/update, reveal)
**Body:**

* Create/update preserves tax\_id when blank.
* Reveal returns decrypted JSON (authorized).
  **Acceptance Criteria**
* Specs pass locally.

---

**Title:** Tests: system (dynamic forms & regions)
**Body:**

* Toggle person/org fields.
* Country change loads regions.
* Add/remove address rows.
  **Acceptance Criteria**
* System specs pass locally (headless).

---

**Title:** Developer docs & scripts polish
**Body:**

* Ensure README + docs reflect latest setup.
* `scripts/bootstrap` + `scripts/dev` executable.
  **Acceptance Criteria**
* New dev can bootstrap and run in <5 mins.
