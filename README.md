# Betest — Party Domain (Rails 8 + MariaDB)

A Rails 8 app modeling people & organizations (“Party”) with:
- MariaDB
- Tailwind CSS v4 + daisyUI
- Hotwire (Turbo + Stimulus)
- Rails built-in encryption for PII
- Blind index (searchable encrypted fields)
- Dynamic forms (person vs organization, country → regions)

## Quick start

### Prereqs
- Ruby 3.4+
- MariaDB 10.6+ (or MySQL 8+)
- Node 18+ & npm
- Foreman or Overmind (for `bin/dev`)
- Yarn (optional if npm is present)

### Setup
```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
````

### Secrets & keys

1. **Active Record Encryption** (Rails-built in):

```bash
EDITOR="${VISUAL:-nano}" bin/rails credentials:edit -e development
```

Add static keys (use your own values):

```yaml
active_record_encryption:
  primary_key:  3b34... (32+ bytes base64 or hex)
  deterministic_key:  6a9f... (32+ bytes)
  key_derivation_salt: a1b2...
```

2. **Blind Index key** (exactly 64 hex chars = 32 bytes):

```bash
ruby -e 'require "securerandom"; puts SecureRandom.hex(32)'
EDITOR="${VISUAL:-nano}" bin/rails credentials:edit -e development
```

```yaml
blind_index:
  master_key: 0123abc...<64 hex>...def
```

> Alternatively set env var: `export BLIND_INDEX_MASTER_KEY=$(ruby -e 'require "securerandom"; puts SecureRandom.hex(32)')`

### Run dev

```bash
bin/dev
# web on http://localhost:3000
```

### Tests (if RSpec added later)

```bash
bundle exec rspec
```

## Domains (high level)

* `Party::Party` — root entity (person OR organization), encrypted `tax_id`, `customer_number`, `public_id` (UUID).
* `Party::Person`, `Party::Organization` — 1:1 subprofiles.
* `Party::Address` — typed addresses; country → region dependent select.
* Ref tables: `ref_countries`, `ref_regions` (composite uniqueness), `ref_address_types`, `ref_email_types`, `ref_phone_types`, `ref_organization_types`.

### Notable behaviors

* `display_name` on Party (person: “First Last”, org: legal\_name, fallback to customer\_number/public\_id).
* `tax_id`:

  * Encrypted (deterministic) + blind index (`tax_id_bidx`).
  * Preserved on edit unless changed (controller + model guard).
  * Mask helper `tax_id_masked`.

### Seeds

Idempotent seeds for reference tables (+ optional ISO countries/regions).

```bash
bin/rails db:seed
```

## Troubleshooting

* **Zeitwerk NameError**: ensure `app/models/party/party.rb` defines `module Party; class Party < ApplicationRecord; end; end`.
* **Regions not updating**: make sure country & region selects are under the same `dependent-select` controller; cache bust query `?_=${Date.now()}`.
* **Blind index key errors**: must be 32 bytes (64 hex). Set via credentials or env var; restart app.

## Scripts

* `scripts/bootstrap` — install gems, prepare DB, seed
* `scripts/dev` — wrapper for `bin/dev`

See `docs/` for full details.