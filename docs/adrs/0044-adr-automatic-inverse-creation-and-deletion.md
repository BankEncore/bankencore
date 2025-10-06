# ADR-0044: Automatic Inverse Creation and Deletion

**Status:** Accepted  
**Date:** 2025-10-06

## Context
Asymmetric relationships require two rows to keep navigation simple from either end. Manual maintenance causes drift.

## Decision
- **Create:** When adding a new asymmetric link with `inverse_code`, also create the inverse row from target→source in the same transaction.
- **Delete:** When deleting an asymmetric link, locate and remove the inverse row.
- **Symmetric:** Only a single row exists; no inverse is written.

## Consequences
- Consistent data graph for navigation.
- Slightly more controller logic, but cleaner reads and queries.
