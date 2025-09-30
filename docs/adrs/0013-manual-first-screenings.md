---
adr: 0013
title: Manual-first screenings
status: Accepted
date: 2025-09-30
deciders: BankEncoRRe team
tags: [screenings, delivery-strategy]
---

## Context
We need screening records for audit and compliance, but vendor integrations are not ready. Teams still need to log searches and dispositions.

## Decision
Implement screenings with `vendor: :manual` only. Provide full CRUD, query snapshot fields, result fields, notes, and `vendor_payload` JSON for structured hints. No external API calls.

## Options considered
- Full vendor integration first.
- Stub vendors with background jobs.
- Manual-first with identical data model. ✅

## Rationale
- Unblocks audit and operational workflows now.
- Preserves the interface for later adapters.
- Minimizes risk and scope.

## Consequences
- Analysts enter results manually.
- No automated re-screening yet.
- When vendors arrive, adapters can reuse model, routes, and UI with minimal changes.

## Implementation notes
- `party_screenings.vendor` enum includes `manual`.
- Controller defaults `vendor: :manual`.
- Views expose fields; parse `vendor_payload` from a text area into JSON.
