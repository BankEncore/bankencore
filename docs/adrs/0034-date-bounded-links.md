# ADR 0034: Date-bounded party links

## Status
Accepted — 2025-10-04

## Context
`party_links` previously relied on `created_at/updated_at` for temporal reasoning. Bank reporting and audits require as-of correctness and end-dating.

## Decision
- Add `started_on` (required, default today) and `ended_on` (nullable) to `party_links`.
- Define `active(on)` and `between(from,to)` scopes using these bounds.
- Prefer end-dating over deletes for historical traceability.

## Consequences
- Accurate as-of queries and audits.
- Slightly more write logic and validation.

## Alternatives
- Soft delete only.
- Validity flags without dates.

## Implementation Notes
- Columns added with backfill from `created_at` where needed.
- Covering indexes use `(party_id/type, started_on, ended_on)`.
- Overlap prevention enforced at model level.
