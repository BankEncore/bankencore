---
adr: 0015
title: MySQL JSON, not JSONB
status: Accepted
date: 2025-09-30
deciders: BankEncoRRe team
tags: [database, mysql, json]
---

## Context
The app runs on MySQL. Initial migrations used `jsonb` which is PostgreSQL-only.

## Decision
Use MySQL `json` for `party_screenings.vendor_payload`. Avoid Postgres-specific operators.

## Options considered
- Switch to PostgreSQL.
- Use MySQL `json` with app-side logic. ✅

## Rationale
- Matches current infrastructure.
- Keeps payload flexible.

## Consequences
- No JSONB/GiN indexes.
- Complex JSON queries should be denormalized or backed by generated columns.

## Implementation notes
- Migration: `t.json :vendor_payload, null: false` (omit DB default if version disallows).
- Model default to `{}` when DB default is not supported.
