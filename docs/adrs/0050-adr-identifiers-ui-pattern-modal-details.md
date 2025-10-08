
# ADR 0050: Identifiers UI pattern using modal details
Status: Accepted
Date: 2025-10-07

## Context
Full-page navigations broke flow.

## Decision
- Use shared Turbo frame host `comm_modal_frame` controlled by `modal` Stimulus.
- Identifier Details open in modal; `show` renders frameless for frame requests.

## Implementation
- Host in layout (or page): `turbo-frame#comm_modal_frame` inside shared modal.
- Details links add `data-turbo-frame="comm_modal_frame"`.
- Show view wrapped in `<turbo-frame id="comm_modal_frame">…</turbo-frame>`.

## Consequences
- Predictable modal behavior; reusable pattern.

## Migration
- Update links and views accordingly.
