# ADR 0030: Identifier masking derives from length + last4, not stored mask

**Status**: Accepted  
**Date**: 2025-10-01

## Context
`party_identifiers.value_masked` stored asterisks. After encryption refactor, masked output drifted and sometimes showed only masks.

## Decision
Do not persist masked strings. Persist only:
- `value_len : integer`
- `value_last4 : varchar(4)`

Render masks at view/model time.

## Consequences
- No decrypt at render for masking.
- Eliminates drift and simplifies key rotation.
- Single callback derives fields on write/update.

## Implementation
- Migration: add `value_len`, `value_last4`; backfill from decrypted `value`.
- Model: `before_validation :derive_len_last4`; helpers `masked`, `masked_formatted`.
- Temporary shim: `def value_masked = masked_formatted`.

## Security
- Less derived PII stored. Logs/exports show only length and last4.

## Rollout
1) Ship migration and backfill.  
2) Deploy model changes.  
3) Update views to `masked_formatted`.  
4) Later: drop `value_masked`.
