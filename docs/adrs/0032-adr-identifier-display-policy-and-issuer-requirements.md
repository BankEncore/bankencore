# ADR 0032: EIN/SSN/TIN/Passport/DL display policy and issuer requirements

**Status**: Accepted  
**Date**: 2025-10-01

## Context
Different identifiers require distinct disclosure and issuer metadata.

## Decision
- **SSN/ITIN/TIN**: show `***-**-last4` when `value_len==9`. Sort 100 (SSN), 140 (TIN/ITIN).
- **EIN**: show last4 only; no prefix. Sort 120.
- **Passport**: `first1_last4`; require issuer country. Sort 200.
- **Driver license**: `first1_last4`; require issuer country and region. Sort 220.

## Consequences
- Consistent UX.  
- Completes compliance metadata capture.

## Implementation
- Data migration updates `mask_rule`, `sort_order`, `require_issuer_country`, `require_issuer_region`.
- Model validation `issuer_requirements` enforces flags at save.

## Security
- Least-disclosure principle for identifiers.

## Rollout
- Apply migration.  
- QA renders per type.  
- Update seeds/fixtures accordingly.
