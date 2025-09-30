# BankEncoRRe

BankEncoRRe (BankEncore on Ruby on Rails) is a core banking platform
built with **Ruby on Rails 8**, **Ruby 3.4**, **MariaDB 10.11**,
**Tailwind v4 + daisyUI**, and **Hotwire (Turbo + Stimulus)**.

## Domains

-   **Party**: Core identity and relationships for customers
    (`Party::Party`, `Person`, `Organization`, `Address`, `Email`,
    `Phone`, `Link`, `Group`).
-   **Internal**: Bank employees, authentication, and role-based access
    control.
-   **Products**: Product catalog for accounts (checking, savings,
    etc.).
-   **Account**: Specific financial accounts linked to parties.
-   **Ledger**: Immutable double-entry system for all postings and
    balances.

## Features

-   Encrypted and blind-indexed PII (e.g. tax IDs, emails).
-   Dynamic party subprofiles (person vs. organization).
-   Nested forms with Stimulus controllers (addresses, emails, phones).
-   Dependent country → region selects seeded from ISO 3166.
-   Customer number generator (`NNNNNNNYYX` with Luhn check).
-   Internal user authentication and authorization (Devise + Pundit
    planned).

## Requirements

-   Ruby 3.4\
-   Rails 8\
-   MariaDB 10.11+\
-   Node.js (for Tailwind v4 build)

## Setup

``` bash
# Install Ruby and MariaDB
mise install

# Install gems
bundle install

# Install JS/CSS deps
bin/importmap install
bin/rails tailwindcss:install

# Setup DB
bin/rails db:create
bin/rails db:schema:load
bin/rails db:seed
```

## Environment Configuration

Rails credentials must be set up for encryption. Example:

``` bash
bin/rails credentials:edit --environment development
```

Example `config/credentials/development.yml.enc` (values shown are
placeholders):

``` yaml
active_record_encryption:
  primary_key: 0123456789abcdef0123456789abcdef
  deterministic_key: fedcba9876543210fedcba9876543210
  key_derivation_salt: a1b2c3d4e5f6g7h8i9j0

blind_index:
  master_key: 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
```

Alternatively, you can set environment variables. Example
`.env.example`:

``` dotenv
# --- Rails ---
RAILS_ENV=development
PORT=3000
HOST=localhost

# Rails master key (use only in dev/test if you prefer dotenv over credentials)
RAILS_MASTER_KEY=changeme_dev_only

# --- Encryption / Blind Index ---
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=0123456789abcdef0123456789abcdef
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=fedcba9876543210fedcba9876543210
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=a1b2c3d4e5f6g7h8i9j0
BLIND_INDEX_MASTER_KEY=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef

# --- Database (MariaDB 10.11+) ---
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=bankencorre_development
DB_USER=bankencorre
DB_PASSWORD=changeme

# --- Rails URL options ---
DEFAULT_URL_HOST=localhost
DEFAULT_URL_PORT=3000
DEFAULT_URL_PROTOCOL=http

# --- Mail (dev) ---
SMTP_ADDRESS=localhost
SMTP_PORT=1025
SMTP_DOMAIN=localhost
SMTP_USER=
SMTP_PASSWORD=
SMTP_AUTH=plain
SMTP_ENABLE_STARTTLS_AUTO=false

# --- Logging ---
LOG_LEVEL=info

# --- Feature flags ---
FEATURE_INTERNAL_AUTH=true
FEATURE_SCREENING=false
```

Notes: - Do **not** commit real keys.\
- `blind_index.master_key` must be 64 hex characters (BINARY(32)).\
- Keys must be set per environment (`development`, `test`,
`production`).

## Database

Schema is MariaDB-friendly, with composite FKs and idempotent
migrations. Reference tables include:

-   `ref_countries` and `ref_regions` (ISO data)
-   `ref_address_types`, `ref_email_types`, `ref_phone_types`
-   `ref_identifier_types` (e.g. SSN, EIN, Passport)

## Running the App

``` bash
bin/dev
```

This runs the Rails server with Tailwind watcher.\
Visit <http://localhost:3000>.

## Testing

RSpec is used:

``` bash
bundle exec rspec
```

System specs cover forms, dynamic fields, and validations.

## Roadmap

See [Preliminary Project Plan](Preliminary%20Project%20Plan.md) for
phases:

-   Phase 1: Party Domain
-   Phase 2: Internal & Security
-   Phase 3: Accounts & Products
-   Phase 4: Ledger & Transactions

## Contributing

-   Follow branch naming: `feat/<scope>`, `fix/<scope>`,
    `chore/<scope>`.\
-   Use PR templates in `.github/pull_request_template.md`.\
-   Run `bundle exec rubocop` before committing.\
-   CI/CD runs tests and security checks.

## License

Proprietary -- for internal bank development use.
