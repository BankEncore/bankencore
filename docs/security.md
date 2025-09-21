# Security

## Encryption
- Rails built-in AR Encryption:
  - `encrypts :tax_id, deterministic: true`
  - Keys in credentials under `active_record_encryption`.
- Deterministic encryption enables blind indexing and equality checks.

## Blind Index
- Gem: `blind_index`
- Model:
  ```ruby
  blind_index :tax_id, key: BlindIndex.master_key, encode: false
````

* Column: `tax_id_bidx BINARY(32)`, indexed.
* Key: 32 bytes (64 hex) via credentials or `BLIND_INDEX_MASTER_KEY`.

## Masking / Reveal

* Display masked values in HTML (`tax_id_masked`).
* Reveal endpoints (JSON) gated by authorization if needed:

  * `GET /party/parties/:public_id/reveal_tax_id` → `{ value: decrypted }`

## Edit behavior

* Controller strips blank `:tax_id` from params to preserve existing value.
* Model override `tax_id=(val)` ignores blank.

## Key management

* Dev/test keys separate from production.
* Never commit master keys; use CI secrets/hosted secrets managers.
* Key rotation: Rails supports multiple keys (`deterministic_key` can rotate with previous keys block).

## Transport & Headers

* Force HTTPS in production, secure cookies.
* Consider security headers (CSP) via `secure_headers` or equivalent.