# ADR 0009: Map DB uniqueness errors to friendly messages

- Status: Accepted
- Date: 2025-09-29

## Context
DB raises `RecordNotUnique` with binary key fragments.

## Decision
- Rescue DB exception in controller and add model error:
  “Identifier is already in use by another profile.”
- Re-render form with error inline.

## Consequences
- Positive: clear UX; DB remains source of truth.
- Negative: small controller complexity.

## Alternatives
- App-only uniqueness: race-prone.

## Migration/Operational
- Tests for collision paths.

## Security/Privacy
- No sensitive data echoed back.
