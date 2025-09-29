# ADR 0008: Reveal flow and PII safeguards

- Status: Accepted
- Date: 2025-09-29

## Context
Operators need occasional plaintext access with auditability.

## Decision
- Dedicated reveal endpoint per identifier; returns decrypted value.
- Set `Cache-Control: no-store`; UI gate with explicit click.
- Log/audit hook planned.

## Consequences
- Positive: least-privilege by default.
- Negative: more endpoints; need RBAC later.

## Alternatives
- Render plaintext in views: rejected.

## Migration/Operational
- Pen test the endpoint; rate limit if needed.

## Security/Privacy
- Treat as PII event; instrument audits later.
