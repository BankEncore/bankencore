adr: 0028
title: Tie auditing to current authenticated user
status: Accepted
date: 2025-09-30
deciders: Core team
---

## Context
We require “who did what” across screenings and party CRUD.

## Decision
- Use an `AuditLog` table with `user_id`, `subject_type`, `subject_id`, `action`, `changeset(json)`, `ip`, `ua`, `at`.
- Add an `Auditable` concern:
  - `after_create/update/destroy` write a row using `current_user` (via `Authentication`) or `Current.user`.
- Do not block on full RBAC. All users are effectively admins for now.

## Consequences
- Audits start capturing actor identity immediately.
- Future RBAC strengthens policies without changing audit plumbing.

## Implementation Notes
- Populate IP/UA in a lightweight before_action:
  ```ruby
  before_action do
    Current.ip = request.remote_ip rescue nil
    Current.ua = request.user_agent rescue nil
  end
