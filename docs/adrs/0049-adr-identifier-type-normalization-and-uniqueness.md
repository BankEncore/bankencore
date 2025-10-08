
# ADR 0049: Identifier type normalization and uniqueness
Status: Accepted
Date: 2025-10-07

## Context
Identifiers arrive in varied formats and must be deduplicated.

## Decision
- Normalize on write with `Party::Identifier.normalize(raw, code)`.
- Uniqueness by `(identifier_type_id, value_bidx)`.
- Blind index from normalized plaintext.
- Deterministic encryption for `value` to enable length/last4 derivation.

## Implementation
- Validations: `no_duplicate_identifier`, `single_primary_per_type`, issuer checks.
- Callbacks: `normalize_value`, `derive_len_last4`, `sync_legacy_code`.

## Consequences
- Consistent dedup; safe comparisons.

## Migration
- Backfill `value_len`/`value_last4`.
- Ensure unique index exists on `(identifier_type_id, value_bidx)`.
