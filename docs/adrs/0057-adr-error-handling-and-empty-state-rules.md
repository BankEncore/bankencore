
# ADR 0057: Error handling and empty-state rules for identifiers
Status: Accepted
Date: 2025-10-07

## Context
Users leave values blank during edit/create.

## Decision
- Existing row + blank value: keep existing.
- New row + blank value: drop.
- UI: alert on reveal failure; copy disabled until revealed.

## Implementation
- Enforced by `scrub_identifier_params` and Stimulus controller guards.
