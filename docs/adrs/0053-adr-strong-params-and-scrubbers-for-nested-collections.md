
# ADR 0053: Strong params and scrubbers for nested collections
Status: Accepted
Date: 2025-10-07

## Context
Nested collections need consistent hygiene.

## Decision
- Centralize scrubbers for emails, addresses, phones, identifiers.
- Identifiers: map `id_type_code` → `identifier_type_id`; drop empty new rows; keep ciphertext on update if blank.

## Implementation
- `create`, `update`, and `add_row_and_render` pass `party_params` through scrubbers.

## Consequences
- Predictable mass-assignment and UX.
