# ADR 0001: Use Rails built-in encryption + blind index

## Context
We need to store PII (tax_id) securely and query by equality.

## Decision
- Use Rails AR Encryption with deterministic mode.
- Use `blind_index` for searchable hash column.

## Consequences
- Deterministic encryption enables equality but slightly increases risk; acceptable with BIDX & access controls.
- Requires key management in credentials/env.