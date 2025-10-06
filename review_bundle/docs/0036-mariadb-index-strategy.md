# ADR 0036: MariaDB-safe indexing for temporal links and memberships

## Status
Accepted — 2025-10-04

## Context
Partial/conditional unique indexes are not portable across MariaDB versions. We need performant lookups on temporal ranges without vendor-specific features.

## Decision
- Use covering non-unique indexes:
  - `party_links`: `(source_party_id, party_link_type_code, started_on, ended_on)` and the same for target.
  - `party_group_memberships`: `(group_id, party_id, started_on, ended_on)`.
- Keep overlap and “one active” constraints in application validations.
- Provide a swap migration to replace old `(created_at, updated_at)` indexes with date-bound versions.

## Consequences
- Predictable performance and portability.
- Application enforces integrity.

## Alternatives
- Generated columns with partial unique indexes.
- Triggers enforcing ranges.

## Implementation Notes
- Guard `remove_index/add_index` by name to avoid duplicate key errors.
