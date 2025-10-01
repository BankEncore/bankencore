adr: 0023
title: Use Rails 8 native Authentication with DB-backed Session model
status: Accepted
date: 2025-09-30
deciders: Core team
---

## Context
We need simple, reliable authentication now. We already use the Rails 8 Auth concern (`Authentication`) which expects a DB-backed `Session` and a signed cookie `session_id`. Devise would add complexity we do not need yet.

## Decision
Adopt the Rails 8 generator pattern:
- Keep `Authentication` concern and `Session` model.
- Set and revoke sessions manually:
  - Create: `s = Session.create!(user:) ; cookies.signed[:session_id] = s.id`
  - Destroy: `Current.session&.destroy ; cookies.delete(:session_id)`
- Use helpers from the concern (`authenticated?`, `current_user`) and do **not** introduce `session[:user_id]`.

## Consequences
- Minimal code, easy to read.
- Migration to Devise/Rodauth remains possible.
- Password reset and 2FA will be separate ADRs.

## Implementation Notes
- `SessionsController#create` authenticates via `user.authenticate(password)` and sets the cookie + row.
- `SessionsController#destroy` revokes both.
- Routes: `resource :session, only: %i[new create destroy]`.