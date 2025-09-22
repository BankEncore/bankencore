High-level: solid baseline. A few schema defects and redundancies. Suggested DDL fixes below.

Key findings

* Correct environment targeting MariaDB 10.11.13.&#x20;
* Parties table aligns with plan: unique `public_id`, `customer_number`, and blind index `tax_id_bidx`. Encrypted `tax_id` stored as `varchar(510)`.&#x20;
* Address FK correctly enforces `(country_code, region_code)` to `ref_regions`. Supporting composite index present.&#x20;
* `ref_regions` has duplicate composite unique indexes on the same columns; keep one.&#x20;
* `party_organizations.party_id` and `party_people.party_id` are `AUTO_INCREMENT` yet also FKs to `parties(id)`; this breaks 1:1 integrity. Remove `AUTO_INCREMENT`. &#x20;
* `party_emails` defines the same unique key twice on `(party_id, email_bidx)`; drop one.&#x20;
* `party_phones` looks correct: unique on `(party_id, phone_e164, phone_ext)` and proper FKs.&#x20;
* Reference types seeded with unique codes as expected.&#x20;

Security and data notes

* Consider storing `tax_id` as `VARBINARY(510)` to avoid collation or padding effects on ciphertext. Keep `tax_id_bidx VARBINARY(32)` with a unique index, which you already have.&#x20;
* Add a `CHECK` on `parties.party_type IN ('person','organization')` to enforce the domain rule at DB level. Not present now.&#x20;

DDL patch (apply idempotently)

```sql
-- 1) Refactor 1:1 subprofile tables (remove AUTO_INCREMENT)
ALTER TABLE party_people MODIFY party_id BIGINT NOT NULL;
ALTER TABLE party_organizations MODIFY party_id BIGINT NOT NULL;

-- 2) Drop duplicate unique on ref_regions
ALTER TABLE ref_regions DROP INDEX uniq_ref_regions_country_code; -- keep index_ref_regions_on_country_and_code

-- 3) Deduplicate party_emails unique indexes
ALTER TABLE party_emails DROP INDEX index_party_emails_on_party_and_bidx; -- same cols as the other unique

-- 4) Optional: enforce party_type domain
ALTER TABLE parties
  ADD CONSTRAINT chk_parties_party_type
  CHECK (party_type IN ('person','organization'));

-- 5) Optional: harden ciphertext storage
ALTER TABLE parties MODIFY tax_id VARBINARY(510) NULL;
```

Optional quality improvements

* Add a partial unique on `party_addresses(party_id, address_type_code)` where `is_primary=1` if you want at most one primary of each type per party. Current schema allows multiple primaries.&#x20;
* Add `DEFAULT 'US'` for `party_addresses.country_code` if you want DB-level default as per plan.&#x20;
* Consider `CHECK (region_code IS NULL OR country_code IS NOT NULL)` to reinforce address integrity beyond the composite FK.&#x20;

Net: after removing the `AUTO_INCREMENT`s, the duplicate uniques, and adding the checks, the schema aligns with the project baseline and reduces integrity risk.
