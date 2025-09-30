---
adr: 0018
title: “Open screening” uniqueness strategy
status: Accepted
date: 2025-09-30
deciders: BankEncoRRe team
tags: [consistency, validation]
---

## Context
Allow at most one open screening per `(party, vendor, kind)`. MySQL lacks partial unique indexes.

## Decision
Enforce at application layer:
- Validation: prevent more than one where `status IN (pending, needs_review)`.
- Service idempotency: return existing open screening unless forced.

## Options considered
- Generated column + unique index by status.
- App-level validation. ✅

## Rationale
- Simple now.
- Keeps DB portable.

## Consequences
- Small race window; acceptable for manual-first flow.
- Revisit with generated columns if concurrency increases.

## Implementation notes
- Scope `.open`.
- Validation in `Party::Screening` before create/update.
