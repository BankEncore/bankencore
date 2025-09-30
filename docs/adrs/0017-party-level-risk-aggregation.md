---
adr: 0017
title: Party-level risk aggregation
status: Accepted
date: 2025-09-30
deciders: BankEncoRRe team
tags: [risk, aggregation, cache]
---

## Context
UI and policies need a quick view of a party’s risk from latest screenings per kind.

## Decision
Cache `party_risk_score` (0–100) and `risk_band` enum `{low:0, medium:1, high:2}` on `parties`. Compute as weighted sum of latest non-expired screening per kind.

## Options considered
- Compute on the fly.
- Cache and refresh on screening changes. ✅

## Rationale
- Fast UI and policy checks.
- Deterministic and explainable.

## Consequences
- Must refresh cache after screening save/update.
- Background recompute may be added for expiry/decay.

## Implementation notes
- `PartyRiskRefresher.run(party)` after saves.
- Optional exponential time decay configurable later.
