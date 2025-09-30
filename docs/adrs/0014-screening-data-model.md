---
adr: 0014
title: Screening data model
status: Accepted
date: 2025-09-30
deciders: BankEncoRRe team
tags: [schema, screenings]
---

## Context
Each screening must capture inputs, outputs, timestamps, and a durable payload for audit. Different kinds (sanctions, PEP, watchlist, adverse media, IDV) share a core shape.

## Decision
Create `party_screenings` with:
- FK: `party_id` ON DELETE CASCADE.
- Enums: `vendor`, `kind`, `status`.
- Query snapshot: `query_name`, `query_dob`, `query_country`, `query_identifier_type`, `query_identifier_last4`.
- Result: `vendor_ref`, `vendor_score`, `normalized_score`, `match_strength`, `vendor_payload` (JSON), `notes`, `risk_notes`.
- Timestamps: `requested_at`, `completed_at`, `expires_at`.
- Cache on parties: `last_screened_at`.

## Options considered
- Vendor-specific tables.
- Single table with JSON-only schema.
- Hybrid: normalized common fields + JSON details. ✅

## Rationale
- Normalized fields support indexing and UI.
- JSON preserves vendor specifics without schema churn.

## Consequences
- Some duplication between normalized fields and payload.
- Deep JSON queries may require generated columns later.

## Implementation notes
- Index `expires_at`.
- Unique index on `vendor_ref` (allows multiple NULLs).
