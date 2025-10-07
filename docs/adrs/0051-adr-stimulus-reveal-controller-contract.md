
# ADR 0051: Stimulus reveal controller contract
Status: Accepted
Date: 2025-10-07

## Context
Multiple reveal widgets drifted.

## Decision
- Controller name: `reveal`.
- Targets: `text`, `button`, `spinner`.
- Value: `reveal-url-value`.
- Actions: `reveal#reveal` fetches JSON `{{ value }}`; `reveal#copy` copies plaintext.

## Implementation
- Fetch with JSON Accept header and same-origin credentials.
- Swap masked → plaintext; enable copy after reveal.
