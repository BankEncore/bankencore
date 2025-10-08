
# ADR 0052: Routes nesting for identifiers under parties
Status: Accepted
Date: 2025-10-07

## Context
Legacy `reveal_tax_id` was party-level. We need per-identifier endpoints.

## Decision
- Nest identifiers: `/party/parties/:public_id/identifiers/:id` with `show` and `reveal`.
- Keep legacy `reveal_tax_id` only as a proxy to the primary tax id if needed.

## Implementation
- Helpers: `party_party_identifier_path`, `reveal_party_party_identifier_path`.
- Controller: `Party::IdentifiersController` owns actions.
