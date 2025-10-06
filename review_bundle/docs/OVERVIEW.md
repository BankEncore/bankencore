# BankEncoRRe — Core Banking System

**BankEncoRRe** (“Bank Encore Reimagined”) is a modular, Ruby on Rails 8 platform for managing customer identity, financial products, accounts, and ledger operations.
It is optimized for regulated financial institutions that require clear separation between identity, relationships, and account ownership.

---

### 🎯 Purpose

BankEncoRRe’s goal is to provide a transparent, auditable, and extensible foundation for all core banking functions:

* Customer identity (KYC/CDD)
* Account ownership and authorization
* Financial products and postings
* Internal user controls and auditing
* Regulatory and reporting alignment

The architecture is domain-driven, separating concerns into distinct namespaces: `Party`, `Account`, `Products`, `Ledger`, and `Internal`.

---

## 🧩 Core Domains

### 1. Party Domain — Identity & Relationships

The **Party domain** models every external entity (person, organization, trust, estate) the bank interacts with. It ensures that data about identity, contact, and relationships are normalized and versioned.

#### Key Models

| Model                                            | Purpose                                                                                     | Example                          |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------- | -------------------------------- |
| `Party::Party`                                   | The universal root record for any entity. Holds encrypted identifiers and general metadata. | “Jane Doe”, “Acme Corp”          |
| `Party::Person`                                  | Stores name, birthdate, demographic info.                                                   | Individual customer              |
| `Party::Organization`                            | Legal and trade names, registration, EIN.                                                   | Business or institution          |
| `Party::Email`, `Party::Phone`, `Party::Address` | Typed contact methods (with primary flags and consent indicators).                          | Email, phone, mailing address    |
| `Party::Link`                                    | Directed, typed relationship between two parties.                                           | Parent → Child, Spouse ↔ Spouse  |
| `Party::Group`                                   | Collection of parties forming an entity like a household or corporate family.               | “Doe Household”, “Acme Holdings” |
| `Party::GroupMembership`                         | Join table defining each party’s role in a group.                                           | Member, Head, Subsidiary         |

#### Identity Management

* `tax_id` fields are **deterministically encrypted** using Rails Active Record Encryption.
* A **blind index** (`tax_id_bidx`) enables equality search without exposing plaintext.
* Identifiers are masked in UI by default and can only be revealed via an authorized endpoint.

---

### 2. Linking Parties — Directed Relationships

**Party Links** represent explicit one-to-one or one-to-many relationships between two `Party` records.

Each link has:

* `source_party_id`
* `target_party_id`
* `link_type_code` (e.g. `spouse_of`, `parent_of`, `employer_of`)

**Inverse relationships** are automatically enforced.
If A is `parent_of` B, the system ensures B is `child_of` A.

This allows:

* Simple queries (e.g. `party.links_as_source`, `party.links_as_target`)
* Directional reasoning (e.g. determining dependents or ultimate beneficial owners)

#### Typical Link Types

| Code            | Inverse             | Description            | Applies To         |
| --------------- | ------------------- | ---------------------- | ------------------ |
| `spouse_of`     | `spouse_of`         | Mutual marital link    | Person ↔ Person    |
| `parent_of`     | `child_of`          | Familial dependency    | Person ↔ Person    |
| `guardian_of`   | `ward_of`           | Legal responsibility   | Person ↔ Person    |
| `employer_of`   | `employee_of`       | Business relationship  | Org ↔ Person       |
| `subsidiary_of` | `parent_company_of` | Corporate structure    | Org ↔ Org          |
| `trustee_of`    | `beneficiary_of`    | Fiduciary relationship | Person/Org ↔ Trust |

The **link system** captures legal or functional relationships without implying shared ownership or residency.

---

### 3. Grouping Parties — Collective Memberships

**Groups** model n-ary associations, where multiple parties belong to a single entity (household, corporate family, organization unit).

Each `Party::Group` record:

* Defines a `group_type_code` (e.g. `household`, `corporate_family`, `org_unit`)
* Has many `Party::GroupMembership` records defining roles (e.g. `head`, `member`, `subsidiary`)

**Rules:**

* `household` groups can only contain `person` parties.
* `corporate_family` and `org_unit` groups can only contain `organization` parties.
* Memberships have start/end dates and optional role codes.

This approach enables:

* Group-based account eligibility (e.g. family accounts, business hierarchies)
* Role-driven communication preferences
* Hierarchical views of multi-entity customers

#### Example

| Group           | Type               | Members                                                |
| --------------- | ------------------ | ------------------------------------------------------ |
| “Doe Household” | `household`        | Jane Doe (head), John Doe (spouse), Junior Doe (child) |
| “Acme Holdings” | `corporate_family` | Acme Corp (parent), Beta LLC (subsidiary)              |

Groups complement links:

* **Links** capture *binary* relationships.
* **Groups** capture *multi-party* relationships.
  They remain independent to avoid auto-generation of households or entities unless explicitly created (ADR-0039).

---

### 4. Internal Domain — Bank Users & Access Control

Internal staff are modeled through `Internal::User`, `Internal::Role`, and `Internal::Permission`.

* Authentication uses **Rails 8 native sessions** (not Devise).
* Authorization is via **Pundit policies**.
* Each user can hold multiple roles (e.g. Teller, CSR, Compliance).

---

### 5. Account & Product Domains — Financial Layer

* `Products::Product` defines account templates (e.g. “Gold Checking”).
* `Account::Account` instances link a product to one or more `Party` records via `Account::Role` (e.g. Owner, Signer).
* `Ledger::Entry` and `Ledger::Posting` implement double-entry accounting.

---

## 🔒 Security Model

| Feature                | Mechanism                                                    |
| ---------------------- | ------------------------------------------------------------ |
| PII encryption         | Rails Active Record Encryption                               |
| Searchable identifiers | Blind index (BINARY(32))                                     |
| Masked UI              | `tax_id_masked` helper; reveal via `/reveal_tax_id` endpoint |
| Access control         | Pundit policies tied to user roles                           |
| Auditing               | optional `audited`/`paper_trail` extension                   |

---

## 🧠 Design Principles

* Deterministic encryption and masked displays for all PII.
* Referential integrity and idempotent seeds.
* Strict model validation (e.g., region must belong to country).
* UI built with Tailwind v4 and daisyUI for responsive admin forms.
* Stimulus controllers for nested, dependent, and masked form behaviors.
* MariaDB-compatible migrations with guards (`index_exists?`, `foreign_key_exists?`).

---

## ⚙️ Example Data Flow

**Creating a Household:**

1. Create `Party::Person` records for each family member.
2. Link relationships via `spouse_of` and `parent_of`.
3. Create `Party::Group` of type `household`.
4. Add each member with a `Party::GroupMembership` (role: head/member/child).

**Opening a Business Account:**

1. Create an `Organization` party (“Acme LLC”).
2. Link officers via `employee_of` or `director_of`.
3. Create an `Account::Account` tied to the “Business Checking” product.
4. Add roles (`owner`, `signer`) through `Account::Role`.

---

## 📚 Future Enhancements

* Soft delete and audit trail for all party records.
* Automatic household suggestion from family links.
* Role-driven group membership templates.
* Enhanced FATCA/CRS data capture.
* Integration with KYC screening APIs.

---

Would you like this converted into a ready-to-commit file (e.g., `docs/overview.md` and/or inserted into your `README.md` under “Project Description”)?
