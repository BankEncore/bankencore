# ADR 0003: Global uniqueness of identifier values (by type)

- Status: Accepted
- Date: 2025-09-29

## Context
A given SSN/EIN must not map to multiple parties.

## Decision
- DB unique index on `(id_type_code, value_bidx)`.
- Controller translates duplicates to user error: “Identifier is already in use by another profile.”

## Consequences
- Positive: source-of-truth enforced by DB.
- Negative: collisions block merges; need admin override policy later.

## Alternatives
- App-level validation only: race conditions risk.

## Migration/Operational
- Backfill before enabling unique index.
- Add retry+friendly message mapping.

## Security/Privacy
- No plaintext exposure in errors.
