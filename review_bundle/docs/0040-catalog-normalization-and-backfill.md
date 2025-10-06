# ADR 0040: Normalize catalog arrays and backfill

## Status
Accepted — 2025-10-04

## Context
Some catalog fields (`allowed_*`) contained strings instead of JSON arrays, breaking validations.

## Decision
- Normalize all `Ref::PartyLinkType.allowed_from_party_types/allowed_to_party_types`
  and `Ref::PartyGroupType.allowed_party_types/allowed_group_roles` to JSON arrays.
- Add parsing guards to accept legacy strings (JSON or CSV) without raising.

## Consequences
- Stable validations across environments.
- Future seeds remain consistent.

## Alternatives
- Strict JSON-only with migration failure on bad rows.

## Implementation Notes
- One-time backfill script updates existing rows to arrays.
- Seeds enforce array types going forward.
