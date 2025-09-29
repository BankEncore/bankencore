# ADR 0005: Reference table for identifier types

- Status: Accepted
- Date: 2025-09-29

## Context
Display names, sort order, and issuer requirements vary by type.

## Decision
- Add `ref_identifier_types(code, name, sort_order, require_issuer_country, require_issuer_region, mask_rule)`.
- Link `party_identifiers.identifier_type_id`.

## Consequences
- Positive: data-driven UX/validation, no magic strings.
- Negative: seed and admin UI required.

## Alternatives
- Hard-coded enums: rigid and scattered.

## Migration/Operational
- Seed base types; maintain via admin.

## Security/Privacy
- None beyond standard RBAC for ref data edits.
