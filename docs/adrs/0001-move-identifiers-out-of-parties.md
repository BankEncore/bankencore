# ADR 0001: Move identifiers out of `parties` into `party_identifiers`

- Status: Accepted
- Date: 2025-09-29

## Context
A party can have multiple identifiers across types. Storing a single `tax_id` on `parties` blocks 1:N, complicates masking, and widens PII blast radius.

## Decision
- Create `party_identifiers` with 1:N from party.
- Include encrypted `value`, blind index `value_bidx`, `is_primary`, issuer metadata.
- Join for reads; drop legacy `tax_id*` columns.

## Consequences
- Positive: extensible multi-ID model, least-privilege reads, clearer masking/reveal flows.
- Negative: additional joins; migration complexity.
- Ops: ordered migrations; backfill; remove legacy writers.

## Alternatives
- Keep `tax_id` on `parties`: rejected due to 1:1 limit and PII exposure.

## Migration/Operational
- Run backfill then drop columns.
- Reindex for uniqueness on `(id_type_code, value_bidx)`.

## Security/Privacy
- PII isolated; deterministic encryption + blind index only.