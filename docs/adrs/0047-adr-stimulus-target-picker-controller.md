# ADR-0047: Stimulus Target Picker Controller

**Status:** Accepted  
**Date:** 2025-10-06

## Context
We need a lightweight, dependency-free widget to search and select a related party and populate a hidden field used by the Rails form.

## Decision
- Implement `party_target_picker_controller.js`:
  - Values: `lookupUrl`, `allowedTypes`.
  - Targets: `input`, `hidden`, `menu`.
  - Debounced `search` fetch to the lookup endpoint; builds a button list of results.
  - `pick` stores the chosen `public_id` in a hidden input and echoes the label in the visible input.
  - Robust parsing of `allowedTypes` when passed as CSV or array.
- Load via importmap and Stimulus lazy-loading.

## Consequences
- Small, testable controller with no new dependencies.
- Clear DOM contract with the Rails form.
