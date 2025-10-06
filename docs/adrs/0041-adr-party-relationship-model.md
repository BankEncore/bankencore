# ADR-0041: Party↔Party Relationship Model

**Status:** Accepted  
**Date:** 2025-10-06

## Context
We need to represent relationships between parties (people and organizations) such as *spouse_of*, *owned_by*, *employer_of*. Relationships may be symmetric (e.g., spouse_of) or asymmetric with a defined inverse (e.g., employer_of ↔ employee_of). We must support validations on permitted source/target party types and keep the graph consistent for reads and writes.

## Decision
- Use a directed edge table `party_links` with columns `source_party_id`, `target_party_id`, and `party_link_type_code`.
- Use reference table `ref_party_link_types` to encode semantics:
  - `symmetric` ∈ {{0,1}}.
  - `inverse_code` is `NULL` for symmetric types; non-`NULL` for asymmetric types and must point to a peer code.
  - `allowed_from_party_types` and `allowed_to_party_types` are JSON arrays of strings in {{"person","organization"}}.
- On create:
  - If the type is symmetric → write **one** row only.
  - If the type is asymmetric and has `inverse_code` → write the **inverse** row from target→source.
- On delete:
  - If asymmetric → delete the counterpart row as well.
  - If symmetric → delete the single canonical row.

## Consequences
- Simple read model and efficient rendering logic.
- Invariants are centralized in `ref_party_link_types` and seeds.
- Slightly more work on writes due to inverse management.
