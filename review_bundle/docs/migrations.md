# Migrations Notes

## Regions composite uniqueness & FK

Goal: allow same region `code` in different countries.

1. Drop PK/unique on `ref_regions.code`.
2. Add unique index on `[:country_code, :code]`.
3. Ensure referencing index on `party_addresses[:country_code, :region_code]`.
4. Add composite FK:
   ```ruby
   add_foreign_key :party_addresses, :ref_regions,
     column: [:country_code, :region_code],
     primary_key: [:country_code, :code],
     name: "fk_pa_ref_regions_ccode_rcode",
     on_delete: :restrict
````

Make migrations idempotent on MariaDB:

* Guard with `index_exists?`, `foreign_key_exists?`.
* Wrap DDL with `rescue nil` if needed; MariaDB DDL is not fully transactional.