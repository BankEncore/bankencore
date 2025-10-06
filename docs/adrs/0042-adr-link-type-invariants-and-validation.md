# ADR-0042: Link-Type Invariants and Validation

**Status:** Accepted  
**Date:** 2025-10-06

## Context
Seed data previously had missing or contradictory fields (empty allowed types, mismatched inverse pairs). We rely on link-type metadata for correctness.

## Decision
- Enforce at seed-time and runtime:
  - `symmetric` ∈ {{0,1}} only.
  - If `symmetric=1` → `inverse_code` MUST be `NULL`.
  - If `symmetric=0` → `inverse_code` MUST reference a valid reciprocal code, and the reciprocal must point back.
  - `allowed_from_party_types` and `allowed_to_party_types` MUST be JSON arrays (not strings) of allowed values in {{"person","organization"}}.
- Controllers validate source/target `party_type` against `allowed_*` before insert.
- Seeds include defaults for `default_from_role` and `default_to_role` when applicable.

## Consequences
- Prevents illegal edges at creation time.
- Makes the seed dataset a contract that application logic can depend on.
- CI friendly: invalid seeds fail fast.
