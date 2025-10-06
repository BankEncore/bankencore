# 🏦 BankEncoRRe — Core Banking System

BankEncoRRe (“Bank Encore Reimagined”) is a modular, auditable core-banking platform built with **Ruby on Rails 8**, **MariaDB 10.11**, and **Tailwind v4 + daisyUI**.  
It provides a clean, extensible foundation for customer identity, relationships, financial products, accounts, and ledger transactions.

---

## 📚 Table of Contents
1. [Purpose](#-purpose)
2. [Architecture Overview](#-architecture-overview)
3. [Domain Model](#-domain-model)
   - [Party Domain](#party-domain)
   - [Internal Domain](#internal-domain)
   - [Products & Accounts Domain](#products--accounts-domain)
   - [Ledger Domain](#ledger-domain)
4. [Security Model](#-security-model)
5. [Setup & Requirements](#-setup--requirements)
6. [Running the Application](#-running-the-application)
7. [Testing](#-testing)
8. [Documentation](#-documentation)
9. [License](#-license)

---

## 🎯 Purpose

BankEncoRRe enables banks and credit unions to manage:

- Customer identity (KYC / CDD)
- Linked and grouped relationships (households, corporate hierarchies)
- Product catalogues and financial accounts
- Double-entry ledger operations
- Internal users, roles, and permissions

All personally identifiable data (PII) is encrypted and blind-indexed, providing full traceability and compliance without exposing sensitive values.

---

## 🏗 Architecture Overview

The system follows a **domain-driven** structure:

| Domain | Namespace | Responsibility |
|---------|------------|----------------|
| Identity | `Party` | People, organizations, trusts, estates, and their relationships |
| Internal Access | `Internal` | Bank employees, roles, and permissions |
| Products | `Products` | Product templates, fees, and rates |
| Accounts | `Account` | Customer accounts and ownership roles |
| Ledger | `Ledger` | Immutable postings and balanced entries |

Each domain is independently testable and versioned.  
Frontend components use **Hotwire (Turbo + Stimulus)** with Tailwind v4 styling.

---

## 👥 Party Domain

### Overview
`Party::Party` is the universal entity record for any person or organization.  
Subtype tables store their specific attributes:

- `Party::Person` – demographic data (name, birth date, citizenship)
- `Party::Organization` – legal and trade names, registration, EIN
- `Party::Email`, `Party::Phone`, `Party::Address` – typed contact methods
- `Party::Link` – directed, typed connections between two parties
- `Party::Group` and `Party::GroupMembership` – multi-member entities (households, corporate families)

### Encryption and Identifiers
| Field | Mechanism | Notes |
|-------|------------|-------|
| `tax_id` | Rails Active Record Encryption | Deterministic; never cleared on blank input |
| `tax_id_bidx` | Blind index (`BINARY(32)`) | Enables equality search |
| `customer_number` | Format `NNNNNNNYYX` | Sequential + Luhn checksum |
| `public_id` | UUID | Externally safe identifier |

### Linking Parties
Links model **directed relationships** using a `link_type_code` with an enforced inverse.  
Examples:

| Source → Target | Code | Inverse | Applies To |
|-----------------|------|----------|-------------|
| Parent → Child | `parent_of` | `child_of` | Person ↔ Person |
| Spouse ↔ Spouse | `spouse_of` | `spouse_of` | Person ↔ Person |
| Employer → Employee | `employer_of` | `employee_of` | Org ↔ Person |
| Parent → Subsidiary | `parent_company_of` | `subsidiary_of` | Org ↔ Org |

### Grouping Parties
Groups capture **n-ary relationships** under a common entity.

| Group Type | Allowed Members | Example |
|-------------|----------------|----------|
| `household` | People only | Doe Household: Jane (head), John (spouse), Junior (child) |
| `corporate_family` | Organizations only | Acme Holdings → Beta LLC |
| `org_unit` | Organizations only | “Acme West Division” |

Each membership defines a role (`head`, `member`, `subsidiary`) with optional start / end dates.

**Links vs Groups**

| Concept | Relationship Type | Example |
|----------|------------------|----------|
| Link | Binary, directional | Jane → John (`spouse_of`) |
| Group | Multi-member, role-based | Doe Household (Jane =head) |

Per ADR-0039, groups are **never auto-created** from links; relationships remain logically separate.

---

## 🏢 Internal Domain

Internal users are represented by `Internal::User`, authenticated via **Rails 8 native sessions**.  
Authorization uses **Pundit** policies linked to roles (`Internal::Role`) and permissions (`Internal::Permission`).  
Typical roles: Teller, CSR, Compliance Officer, Admin.

---

## 💳 Products & Accounts Domain

- `Products::Product` defines account templates (e.g., *Gold Checking*).  
- `Account::Account` instances attach products to parties through `Account::Role` (owner, signer).  
- Each account aggregates transactions from the ledger to calculate balance.

---

## 🧾 Ledger Domain

Implements immutable, double-entry accounting.

| Model | Description |
|--------|-------------|
| `Ledger::Entry` | Balanced transaction header |
| `Ledger::Posting` | Individual debit/credit lines referencing an `Account::Account` |

A `Ledger::Transfer` service ensures atomic, balanced writes.

---

## 🔒 Security Model

| Aspect | Mechanism |
|---------|-----------|
| Encryption | Rails Active Record Encryption |
| Searchable identifiers | Blind index (`BINARY(32)`) |
| Masking | Helpers (`tax_id_masked`), reveal endpoint with auth |
| Access Control | Pundit + role-based rules |
| Auditing | Optional `audited` / `paper_trail` |
| Database Integrity | All FKs validated; region ↔ country enforcement |

---

## ⚙️ Setup & Requirements

### Requirements
- Ruby 3.4+
- Rails 8
- MariaDB 10.11+
- Node 20+ (for Tailwind v4 build)
- Yarn or Bun (optional, importmap default)
- Chrome/Chromedriver (for system tests)

### Installation

```bash
# 1) Install dependencies
bundle install
bin/rails tailwindcss:install

# 2) Configure credentials (do NOT use sample keys in production)
bin/rails credentials:edit --environment development

# 3) Setup database
bin/rails db:create db:migrate db:seed
# Seeds load ISO countries/regions and reference types

# 4) Start development server
bin/dev
````

Default timezone: **America/Detroit**

---

## 🧪 Testing

```bash
RAILS_ENV=test bin/rails db:prepare
bundle exec rspec
```

System specs validate:

* Dynamic sub-profiles (person / organization)
* Dependent region selects
* Nested address add/remove
* Tax ID masking and reveal

CI pipeline (GitHub Actions) runs lint, tests, and security scans.

---

## 📖 Documentation

| File                      | Description                                     |
| ------------------------- | ----------------------------------------------- |
| `docs/getting-started.md` | Environment setup and troubleshooting           |
| `docs/data-model.md`      | ERD, table relationships, and validations       |
| `docs/security.md`        | PII, encryption, blind-index rotation           |
| `docs/seeds.md`           | ISO loaders and re-seed rules                   |
| `docs/auth.md`            | Session lifecycle and Pundit policies           |
| `docs/ui.md`              | Tailwind v4 / Stimulus conventions              |
| `adrs/`                   | Architecture Decision Records (e.g., 0023–0039) |

---

## 🚀 Project Roadmap

From the **Preliminary Project Plan**:

| Phase | Focus                             | Duration  |
| ----- | --------------------------------- | --------- |
| 0     | Foundation & CI/CD                | 1–2 weeks |
| 1     | Party Domain (KYC, Links, Groups) | 4–6 weeks |
| 2     | Internal Domain (Auth & RBAC)     | 2–3 weeks |
| 3     | Products & Accounts               | 3–4 weeks |
| 4     | Ledger & Transactions             | 4–5 weeks |

Backlog includes FATCA/CRS extensions, soft deletes, and audit trails.

---

## 📜 License

Proprietary © 2025 BankEncoRRe Project.
Internal use only. No redistribution without written permission.
