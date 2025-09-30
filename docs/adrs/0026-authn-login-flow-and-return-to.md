adr: 0026
title: Preserve destination via session return_to during login
status: Accepted
date: 2025-09-30
deciders: Core team
---

## Context
Users hitting gated pages should return there after login.

## Decision
- In `AdminGate` (and any future gates), store `session[:return_to] = request.fullpath` before redirecting.
- In `SessionsController#create`, after successful auth:
  ```ruby
  redirect_to(session.delete(:return_to) || root_path)
Consequences
Predictable UX across gated routes.

Risks
Ensure return_to is cleared with delete to prevent open redirect loops.