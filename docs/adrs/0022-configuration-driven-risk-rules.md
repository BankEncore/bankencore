---
adr: 0022
title: Configuration-driven risk rules
status: Accepted
date: 2025-09-30
deciders: BankEncoRRe team
tags: [config, risk, policy]
---

## Context
Weights, thresholds, and adjustments will change. Hard-coding forces deploys.

## Decision
Store rules in `config/risk_scoring.yml` with per-environment blocks. Load via initializer into `RISK_SCORING`.

## Options considered
- Hard-coded constants.
- ENV vars only.
- YAML config file. ✅

## Rationale
- Central, versioned policy.
- Easy to review in PRs.

## Consequences
- Validate presence at boot.
- Changes require restart to take effect.

## Implementation notes
- `config/initializers/risk_scoring.rb` loads YAML and falls back to `{}` if missing.
- Services read from `RISK_SCORING` and handle missing keys defensively.
- Add a boot-time check to warn when required keys are absent.
