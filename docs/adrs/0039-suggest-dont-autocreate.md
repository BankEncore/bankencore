# ADR 0039: Suggest, do not auto-create, group changes from links

## Status
Accepted — 2025-10-04

## Context
Auto side-effects (e.g., creating a household on spouse link) can surprise staff and complicate audits.

## Decision
- After creating `spouse_of` or `parent_of`, show a “Suggest household” prompt with prefilled roles.
- After `employee_of`, suggest adding the person to an org workforce group.
- User confirmation required; changes are explicit and auditable.

## Consequences
- Predictable UX and cleaner audit trails.
- One extra click when suggestions apply.

## Alternatives
- Automatic group creation on link save.
- No suggestions.

## Implementation Notes
- Service objects emit suggestion payloads; controllers render a confirm modal.
