# ADR 0011: Default identifier by party type

- Status: Accepted
- Date: 2025-09-29

## Context
New profiles need a sensible first identifier.

## Decision
- Default SSN for people, EIN for organizations.
- Stimulus listens for party-type changes and swaps type on empty rows.

## Consequences
- Positive: faster data entry, fewer mistakes.
- Negative: edge cases (ITIN, foreign TIN) still require manual change.

## Alternatives
- No default: slower, more clicks.

## Migration/Operational
- None.

## Security/Privacy
- None specific.
