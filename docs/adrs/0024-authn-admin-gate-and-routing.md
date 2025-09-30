adr: 0024
title: Gate admin UI via allowlist and namespaced routes
status: Accepted
date: 2025-09-30
deciders: Core team
---

## Context
We need a hidden user-admin screen. Only specific emails may access it.

## Decision
- Namespace admin routes under `/_internal/admin`.
- Allowlist emails via `ENV["ADMIN_EMAILS"]`.
- Gate with a controller concern `AdminGate` that:
  - Redirects unauthenticated users to sign-in and stores `session[:return_to]`.
  - Compares `current_user.email_address.downcase` against the normalized allowlist.
  - Returns 403 for authenticated but unauthorized users.

## Consequences
- No coupling to future RBAC; low risk.
- Ops must set `ADMIN_EMAILS` in each environment.

## Implementation Notes
- Routes:
  ```ruby
  namespace :admin, path: "/_internal/admin" do
    resources :users, only: %i[index new create edit update destroy]
  end
Link helpers: admin_users_path, new_admin_user_path, etc.