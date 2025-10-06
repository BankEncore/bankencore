# ADR-0045: Typeahead Lookup Contract

**Status:** Accepted  
**Date:** 2025-10-06

## Context
The linking form needs to search for a related party by name or customer number and return a compact payload suitable for a Stimulus controller.

## Decision
- Endpoint: `GET /party/parties/lookup.json`
  - Params:
    - `q`: search term; numeric queries match `customer_number`; otherwise match person name or organization legal name.
    - `types` (optional): CSV or JSON array of allowed party types (e.g., `person,organization` or `["person"]`).
  - Response: array of `{{ public_id, label }}` where `label` contains zero-padded customer number if present, display name, and party type.
- Controller parses `types` robustly for CSV or JSON formats.

## Consequences
- Stable integration point for the Stimulus picker.
- Reusable for other features that need party selection.
