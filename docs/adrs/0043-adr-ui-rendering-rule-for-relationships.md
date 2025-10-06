# ADR-0043: UI Rendering Rule for Relationships

**Status:** Accepted  
**Date:** 2025-10-06

## Context
Showing both directions for asymmetric relationships created duplicate rows and user confusion.

## Decision
- Rendering rules in the list:
  - For **asymmetric** types: show only links where `source_party_id == viewer.id`.
  - For **symmetric** types: show a single row by canonicalizing on the lower of `(source_party_id, target_party_id)` being the viewer, or any deterministic rule.
- Preload `:party_link_type, :source_party, :target_party` to avoid N+1 queries.
- Group rows by `party_link_type_code` for stable ordering.

## Consequences
- Eliminates duplicate rows and clarifies directionality.
- Lower query count in the view path.
