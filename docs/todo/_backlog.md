# Project Backlog (Party Domain)

## 🔐 Security & Data

* [ ] **Configure AR Encryption keys**
  *AC:* `Rails.application.credentials.active_record_encryption` present for all envs; app boots.
* [ ] **Configure Blind Index master key**
  *AC:* 64-hex `blind_index.master_key` in credentials or `BLIND_INDEX_MASTER_KEY`; no fallback warning in logs.
* [ ] **Preserve tax\_id on edit**
  *AC:* Leaving tax\_id blank does not change value; entering a new value updates encryption + BIDX.

## 🧱 Migrations & Schema

* [ ] **RefRegions composite uniqueness**
  *AC:* Unique index on `(country_code, code)`; composite FK from `party_addresses(country_code, region_code)`; migration idempotent.
* [ ] **Party indexes**
  *AC:* Unique indexes on `public_id`, `customer_number`; index on `tax_id_bidx`.
* [ ] **Address defaults**
  *AC:* DB default `party_addresses.country_code = 'US'` (optional).

## 🌱 Seeds

* [ ] **Reference seeds idempotent**
  *AC:* Re-running `db:seed` produces no errors/dupes; uses upsert-by keys for email/phone/address/org types.
* [ ] **Countries & Regions loader**
  *AC:* ISO countries + regions loaded; re-runnable; US states present.

## 🧠 Models

* [ ] **Party#display\_name**
  *AC:* Org → `legal_name`; Person → `first_name last_name`; fallback to `customer_number` or `public_id`.
* [ ] **Party::Address validation**
  *AC:* `region_code` must belong to selected `country_code`; friendly error message.
* [ ] **CustomerNumber generator**
  *AC:* Format `NNNNNNNYYX` (7-seq, 2-digit year, Luhn); wraps after 9,999,999; uniqueness held.

## 🧭 Controllers / Endpoints

* [ ] **Parties CRUD HTML**
  *AC:* New/Edit forms work for both subprofiles; successful create/update redirect with flash; failed validations render errors.
* [ ] **Reveal endpoints**
  *AC:* `GET /party/parties/:public_id/reveal_tax_id` returns `{value: ...}` JSON; (optionally) authorization hook.
* [ ] **Ref::Regions API**
  *AC:* `GET /ref/regions?country=US` returns `[{code,name}]`; cache disabled or cache-busted.

## 🎨 Views / Stimulus

* [ ] **Dynamic subprofiles (person/org)**
  *AC:* Switching type toggles sections; corresponding `_destroy` flags set; values persist on re-render.
* [ ] **Dependent region select**
  *AC:* Selecting country loads regions; on edit, current region preselected; new rows auto-populate after “US”.
* [ ] **Nested addresses**
  *AC:* Add/remove rows works; new row defaults `country_code = 'US'` and loads regions.
* [ ] **Mask & reveal sensitive fields**
  *AC:* Tax ID shows masked; reveal via button fetch; input has `autocomplete="off"` + readonly-until-focus.

## 🧪 Tests

* [ ] **Model specs**
  *AC:* Party validations; `display_name`; Address region-country validation; customer number generation & Luhn.
* [ ] **Request specs**
  *AC:* Parties create/update preserves tax\_id blank; reveal endpoint returns decrypted value.
* [ ] **System tests**
  *AC:* Dynamic person/org sections; dependent regions populate; nested addresses add/remove.

## 🛠 Tooling / DX

* [ ] **Docs polish**
  *AC:* README + docs current (keys, seeds, migrations, UI).
* [ ] **Scripts**
  *AC:* `scripts/bootstrap` and `scripts/dev` executable and documented.
* [ ] **CI pipeline**
  *AC:* Lint, tests, brakeman, bundler-audit; green on main.

## 🚀 Nice-to-haves

* [ ] **Pundit/authorization** for reveal endpoints & admin actions.
* [ ] **Phones/Emails HTML CRUD** mirroring Addresses.
* [ ] **Soft delete** for parties/addresses (discard or paranoia).
* [ ] **Audit trail** (audited or paper\_trail) for PII changes.

### Labels & priority (suggested)

* `prio:high` → Encryption/BIDX, dynamic forms, regions FK
* `area:models`, `area:views`, `area:migrations`, `area:security`, `area:stimulus`, `area:seeds`
* `good first issue` → docs, scripts, small tests

---

* [ ] **Extend _Person_ profiles:** Add middle name, courtesy title, and suffix
* [ ] **Extend _Organization_ profiles:** Add operating_name