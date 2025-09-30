---
adr: 0020
title: Audit and disposition controls
status: Accepted
date: 2025-09-30
deciders: BankEncoRRe team
tags: [audit, compliance, ux]
---

## Context
Audits require who changed what, when, and why. Score is a signal, not a decision.

## Decision
Track dispositions (`status`) separately from score. Require notes on escalations. Log disposition changes.

## Options considered
- Implicit disposition from score only.
- Explicit disposition with audit. ✅

## Rationale
- Human-in-the-loop is mandatory.
- Preserves intent and rationale.

## Consequences
- Additional UI for notes.
- Minor overhead to log changes.

## Implementation notes
- `risk_notes` on screening.
- `Audit.log!(actor, action, subject, metadata)` or equivalent around status changes.
