# ADR 0037: Inverse links and symmetric relationships

## Status
Accepted — 2025-10-04

## Context
Pairwise links require consistent inverses for directed types and deduplication for symmetric types (e.g., spouse_of).

## Decision
- For directed types with `inverse_code`, auto-create the inverse on create.
- For `symmetric=true`, treat `(A,B)` and `(B,A)` as one logical pair for overlap checks.
- Disallow self-links unless the type explicitly allows cycles (not used for customer links).

## Consequences
- Data coherence and fewer manual steps.
- Clearer validations.

## Alternatives
- Manual inverse maintenance.
- Database triggers.

## Implementation Notes
- Inverse creation in `after_commit` with same date bounds.
- Interval dedup handles symmetric vs directed branches.
