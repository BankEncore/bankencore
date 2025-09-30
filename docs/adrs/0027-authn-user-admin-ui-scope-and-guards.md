adr: 0027
title: Minimal internal User Admin UI under admin namespace
status: Accepted
date: 2025-09-30
deciders: Core team
---

## Context
We need to create and update users internally.

## Decision
- Build a small CRUD (`Admin::UsersController`) for `User` with fields:
  `email_address`, `first_name`, `last_name`, `password`, `password_confirmation`.
- Use DaisyUI patterns already in the app.
- Namespaced form: `form_with model: [:admin, @user]`.

## Consequences
- Admin UX is isolated from public surface.
- Future RBAC can reuse the namespace.

## Implementation Notes
- Redirects and links use `admin_*` helpers only.
- Cancel links go to `admin_users_path`.
