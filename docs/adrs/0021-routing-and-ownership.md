---
adr: 0021
title: Routing and ownership
status: Accepted
date: 2025-09-30
deciders: BankEncoRRe team
tags: [routing, ux]
---

## Context
Screenings belong to a party. We need intuitive URLs for creating and listing, and global IDs for viewing/editing.

## Decision
Routes:
- Nested create/index: `/party/parties/:public_id/screenings` → `new`, `create`, `index`.
- Global: `/party/screenings/:id` for `show`, `edit`, `update`.

## Options considered
- Fully nested.
- Fully global.
- Hybrid. ✅

## Rationale
- Creation always in party context.
- Direct links to screenings by ID.

## Consequences
- Forms must target nested path for create.
- Controllers must read `params[:party_public_id]` in nested actions.

## Implementation notes
- `form_with` for new/create uses `party_party_screenings_path(@screening.party.public_id)`.
- `set_party` reads `params[:party_public_id]`.
