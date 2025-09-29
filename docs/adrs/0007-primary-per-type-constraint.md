# ADR 0007: Primary-per-type constraint

- Status: Accepted
- Date: 2025-09-29

## Context
One “primary” identifier per type per party is required for downstream systems.

## Decision
- Validation: at most one `is_primary` per `(party_id, id_type_code)`.
- UI: checkbox toggle; server enforces.

## Consequences
- Positive: deterministic “main” ID.
- Negative: multi-primary imports must be resolved.

## Alternatives
- No primary flag: increases ambiguity elsewhere.

## Migration/Operational
- Data clean-up if duplicates exist.

## Security/Privacy
- None specific.
