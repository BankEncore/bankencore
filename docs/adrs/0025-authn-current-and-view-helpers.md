adr: 0025
title: Use Current.session → Current.user and Authentication helpers in views
status: Accepted
date: 2025-09-30
deciders: Core team
---

## Context
We previously mixed `Current.user=` and `session[:user_id]` with the Rails 8 pattern, causing loops and stale sessions.

## Decision
- Keep `app/models/current.rb`:
  ```ruby
  class Current < ActiveSupport::CurrentAttributes
    attribute :session
    delegate :user, to: :session, allow_nil: true
  end
Do not assign Current.user= anywhere.

In controllers and views, use:

authenticated? and current_user (provided by Authentication).

current_user.display_name for menus/footers.

Consequences
Single source of truth for auth context.

Fewer failure modes.

Implementation Notes
Footer/menu conditions: <% if authenticated? %> … <% end %>.

---

