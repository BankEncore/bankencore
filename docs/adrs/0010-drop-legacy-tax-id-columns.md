# ADR 0010: Drop legacy `tax_id*` columns from `parties`

- Status: Accepted
- Date: 2025-09-29

## Context
After backfill, legacy columns cause split-brain and accidental reads.

## Decision
- Migrate to remove `tax_id`, `tax_id_bidx`, `tax_id_masked`.
- Guard legacy setters to raise if invoked.

## Consequences
- Positive: single source of truth.
- Negative: rollbacks require re-adding columns.

## Alternatives
- Keep columns shadowed: confusing and unsafe.

## Migration/Operational
- Ensure backfill completed and indexes live before drop.

## Security/Privacy
- Reduces accidental PII exposure.
