
# ADR 0056: Audit logging for sensitive reveals
Status: Accepted
Date: 2025-10-07

## Context
Reveals are privileged.

## Decision
- Audit every reveal with user, identifier, timestamp, IP/user-agent.
- Deny without permission.

## Implementation
- Write to audit table/stream in `#reveal`.
