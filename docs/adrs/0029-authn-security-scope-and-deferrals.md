adr: 0024
title: Security baseline now; defer password reset and 2FA
status: Accepted
date: 2025-09-30
deciders: Core team
---

## Context
We need to ship internal auth quickly. Reset links and MFA add scope.

## Decision
- Ship without password reset and 2FA initially.
- Add later behind separate ADRs:
  - **Password reset**: token table, expiring links, email delivery, throttle.
  - **2FA**: TOTP or WebAuthn; enforce for admin-equivalent users.

## Consequences
- Reduced initial complexity.
- Internal-only deployments must use strong manual password hygiene.

## Interim Controls
- Enforce bcrypt (`has_secure_password` via generator).
- Rate-limit auth endpoints (Rack::Attack) before external exposure.
- Use `ADMIN_EMAILS` allowlist for admin UI.