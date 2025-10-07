
# ADR 0048: Identifier masking and reveal policy
Status: Accepted
Date: 2025-10-07

## Context
Sensitive identifiers require masking by default and selective reveal under authorization.

## Decision
- Persist only encrypted `value` (deterministic).
- Derive and store `value_len` and `value_last4`.
- Render masked via `masked_formatted` using `mask_rule`.
- Add gated `GET /party/parties/:public_id/identifiers/:id/reveal` that returns JSON `{{ value }}`.
- Deny by default; audit every reveal.

## Implementation
- Model `Party::Identifier`: `encrypts :value`, `blind_index :value`, `masked`, `masked_formatted`.
- Controller: `Party::IdentifiersController#reveal` returns `{{ 'value': @identifier.value }}` with `Cache-Control: no-store`.
- Stimulus `reveal` controller: targets `text|button|spinner`; actions `reveal#reveal`, `reveal#copy`.
- Views: default masked; swap to plaintext after fetch.

## Security / Audit
- Policy check on `#reveal`.
- Log `user_id`, `identifier_id`, timestamp, IP/user-agent.

## Consequences
- No persisted masked strings; centralized rules.
- Consistent UX across identifier types.

## Migration
- Populate `ref_identifier_types.mask_rule`.
- Remove persisted masked columns if any.
