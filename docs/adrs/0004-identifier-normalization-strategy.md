# ADR 0004: Identifier normalization strategy

- Status: Accepted
- Date: 2025-09-29

## Context
Normalization must be consistent for blind index and equality.

## Decision
- For tax IDs (SSN/ITIN/EIN/foreign_tin): strip non-digits.
- For docs (passport, DL, LEI): upcase and collapse spaces.
- Keep logic centralized in `Party::Identifier.normalize`.

## Consequences
- Positive: stable matching; predictable dedupe.
- Negative: versions must be immutable to avoid rehash churn.

## Alternatives
- Per-caller normalization: error-prone.

## Migration/Operational
- Document version; re-hash process if rules change.

## Security/Privacy
- Normalization happens server-side only.
