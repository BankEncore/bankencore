# ADR 0006: Masking rules owned by reference data

- Status: Accepted
- Date: 2025-09-29

## Context
Masking formats differ by type and change over time.

## Decision
- Use `mask_rule` on `ref_identifier_types` (e.g., `ssn`, `ein`, `last4`).
- Compute and store `value_masked` on save.

## Consequences
- Positive: consistent display; change masks without code.
- Negative: historical rows keep prior masks unless recomputed.

## Alternatives
- Case logic in model: harder to extend.

## Migration/Operational
- Backfill `value_masked` after rule changes if desired.

## Security/Privacy
- Masking never reveals full value.
