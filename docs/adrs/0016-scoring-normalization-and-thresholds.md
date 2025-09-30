---
adr: 0016
title: Scoring normalization and thresholds
status: Accepted
date: 2025-09-30
deciders: BankEncoRRe team
tags: [risk, scoring, policy]
---

## Context
Vendors return heterogeneous scores. Analysts need consistent decision guidance.

## Decision
Normalize all scores to `0–100`. Define global thresholds:
- `clear < 40`
- `needs_review 40–69`
- `match ≥ 70`

Store both `vendor_score` and `normalized_score`. Keep score separate from disposition.

## Options considered
- Per-vendor bespoke logic in controllers.
- Central normalization with config. ✅

## Rationale
- Comparable across vendors and kinds.
- Policy changes live in config, not code.

## Consequences
- Requires config and a scoring service.
- Analysts may override disposition; audit required.

## Implementation notes
- Config at `config/risk_scoring.yml`.
- Service `ScreeningScorer` computes `normalized_score` and optional `match_strength`.
