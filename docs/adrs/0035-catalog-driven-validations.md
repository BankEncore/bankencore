# ADR 0035: Catalog-driven validations for links and groups

## Status
Accepted — 2025-10-04

## Context
Staff need consistent enforcement of who can relate to whom and which roles are valid, without scattering rules across forms and models.

## Decision
- Use `Ref::PartyLinkType` to validate `from/to` party types and symmetry/inverse for `party_links`.
- Use `Ref::PartyGroupType` to validate `allowed_party_types` and `allowed_group_roles` for memberships.
- Parse catalog fields robustly (JSON arrays, tolerate legacy strings).

## Consequences
- Fewer invalid records and clearer errors.
- Centralized rule management in reference tables.

## Alternatives
- Hard-coded conditionals in models/controllers.
- DB triggers.

## Implementation Notes
- Nil-safe lookups for party types via `::Party::Party`.
- JSON helpers to coerce arrays from JSON or CSV strings.
