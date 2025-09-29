# ADR 0012: Issuer country/region fields for identifiers

- Status: Accepted
- Date: 2025-09-29

## Context
Some identifiers require an issuing geography.

## Decision
- Drive requirement from `ref_identifier_types` flags.
- Dynamic UI shows/hides fields; model validates when required.

## Consequences
- Positive: accurate metadata; cleaner forms.
- Negative: more conditional UI logic.

## Alternatives
- Always show fields: noisy forms; low data quality.

## Migration/Operational
- Seed flags per type; keep country/region refs in sync.

## Security/Privacy
- Low sensitivity; standard validation.
