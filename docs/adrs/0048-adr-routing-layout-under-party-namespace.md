# ADR-0048: Routing Layout Under /party Namespace

**Status:** Accepted  
**Date:** 2025-10-06

## Context
We added links and link suggestions while keeping existing communication resources. Consistent routing improves helper names and discoverability.

## Decision
- Under `namespace :party`:
  - `resources :parties, param: :public_id` with nested:
    - `resources :links, only: [:create, :destroy]`
    - `resources :link_suggestions, only: [:index, :update]`
    - existing `emails`, `phones`, `addresses` with member actions.
  - Collection route `get :lookup` on `:parties` for typeahead JSON.
- Helpers use the `party_party_*` prefix for nested resources.

## Consequences
- Predictable URL and helper scheme.
- Scope clarity for controllers and views.
