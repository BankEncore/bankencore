# ADR 0038: Non-overlapping memberships and role validation

## Status
Accepted — 2025-10-04

## Context
Households and org groups need accurate composition over time and valid role assignments.

## Decision
- Enforce non-overlapping memberships per `(group, party[, role_code])`.
- Validate `role_code` ∈ `Ref::PartyGroupType.allowed_group_roles` when present.
- Validate member party type ∈ `allowed_party_types`.
- Use `started_on/ended_on`; end-date rather than delete.

## Consequences
- Reliable as-of group composition.
- Stricter write paths.

## Alternatives
- Allow overlaps and resolve at query time.
- No role constraints.

## Implementation Notes
- JSON/CSV-safe parsing for catalog arrays.
- Index `(group_id, party_id, started_on, ended_on)` to support range checks.
