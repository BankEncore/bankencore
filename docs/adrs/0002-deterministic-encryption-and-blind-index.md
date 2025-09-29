# ADR 0002: Deterministic encryption + blind index for identifiers

- Status: Accepted
- Date: 2025-09-29

## Context
We must support equality queries and global uniqueness without plaintext.

## Decision
- Encrypt `value` deterministically.
- Compute `value_bidx` using BlindIndex with stable normalization.
- Never search on ciphertext; search on blind index.

## Consequences
- Positive: equality lookups, unique constraints, no plaintext in DB.
- Negative: equality pattern leakage; key rotation requires re-encrypt + reindex job.

## Alternatives
- Randomized encryption + external index: more moving parts.
- Hash only: lacks at-rest encryption guarantees.

## Migration/Operational
- Store keys securely (env/secret manager).
- Provide re-encryption rake task for rotation.

## Security/Privacy
- Threat model documents equality leakage.
- `Cache-Control: no-store` for reveal responses.
