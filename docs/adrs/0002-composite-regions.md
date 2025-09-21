# ADR 0002: Composite uniqueness for regions

## Context
Region codes (e.g., "MI") collide across countries.

## Decision
- Make `ref_regions` unique on `(country_code, code)` and reference from addresses via composite FK.

## Consequences
- Cleaner data model; no artificial global codes.
- Slightly more complex migrations and queries.