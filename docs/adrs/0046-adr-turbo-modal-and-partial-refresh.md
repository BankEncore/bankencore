# ADR-0046: Turbo Modal and Partial Refresh

**Status:** Accepted  
**Date:** 2025-10-06

## Context
We want a fast UX with minimal full-page reloads when adding or removing links.

## Decision
- Use a modal host with `<turbo-frame id="comm_modal_frame">` to load the form.
- Wrap the relationships list in a container with id `links_by_type`.
- On successful create/destroy, return Turbo Stream responses that:
  1) `replace` `#links_by_type` with the updated list partial.
  2) `replace` `#comm_modal_frame` with a fresh form (effectively clearing the modal contents).
- Keep an HTML redirect fallback for non-Turbo clients.

## Consequences
- Low-latency interaction with clear visual updates.
- No additional JS framework required beyond Turbo and Stimulus.
