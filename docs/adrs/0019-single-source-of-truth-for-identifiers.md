---
adr: 0019
title: Single source of truth for identifiers
status: Accepted
date: 2025-09-30
deciders: BankEncoRRe team
tags: [identifiers, data-model]
---

## Context
Legacy `parties.tax_id` existed. We added `party_identifiers` with encryption and blind index.

## Decision
Use `Party::Identifier` exclusively. Remove legacy `tax_id*` references and columns when all dumps are aligned.

## Options considered
- Keep both in parallel.
- Migrate to identifiers only. ✅

## Rationale
- One model, audited, extensible (SSN/EIN/TIN/etc.).
- Avoids drift and special cases.

## Consequences
- Views/controllers reference identifiers.
- Backfill required for legacy rows.

## Implementation notes
- Helpers for masking and last4.
- Search by blind index on identifiers.
