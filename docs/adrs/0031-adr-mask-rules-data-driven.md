# ADR 0031: Mask rules are data-driven via `ref_identifier_types.mask_rule`

**Status**: Accepted  
**Date**: 2025-10-01

## Context
Masking logic was hardcoded. Adding new identifier types required code edits.

## Decision
Drive display rules from `ref_identifier_types.mask_rule`.

Allowed values:
- `ssn` → `***-**-last4` when length==9  
- `ein` → last4 only (no prefix disclosure)  
- `last4` → generic last4  
- `first1_last4` → passport/DL policy  
- `pattern:x-y-z` → grouping template  
- `none` → render nothing

## Consequences
- New types configured without deploys.
- Policy centralized and auditable.

## Implementation
- Model validator allows values above.
- `Identifier#masked_formatted` branches on `identifier_type.mask_rule`.
- Data migration sets rules and `sort_order` for existing types.

## Security
- Prevents accidental overexposure; easy to audit/modify.

## Rollout
1) Validator + formatting method.  
2) Data migration to set rules and flags.  
3) Verify views call `masked_formatted`.
