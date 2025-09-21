markdown
# Domain

## Models
### Party::Party
- Columns: `public_id` (uuid), `customer_number` (10), `party_type` (`person|organization`), `tax_id` (encrypted), `tax_id_bidx` (BINARY(32))
- Associations:
  - has_one :person
  - has_one :organization
  - has_many :addresses
  - (emails/phones supported; add CRUD when ready)
- Methods:
  - `display_name` → org.legal_name or "First Last" or customer_number/public_id
  - `tax_id_masked` → masked form (••••1234)
- Callbacks:
  - `ensure_public_id` (UUID)
  - `ensure_customer_number` (service: `CustomerNumber::Generator`)

### Party::Person
- Columns: `first_name`, `last_name`, `date_of_birth`
- belongs_to :party

### Party::Organization
- Columns: `legal_name`, `organization_type_code`
- belongs_to :party; FK to `ref_organization_types.code`

### Party::Address
- Columns: `address_type_code`, `country_code`, `region_code`, `line1`, `line2`, `locality`, `postal_code`, `is_primary`
- belongs_to :party
- Validations: ensure region belongs to selected country.
- FK composite: `[:country_code, :region_code]` → `ref_regions[:country_code, :code]`

### Reference tables
- `ref_countries(code,name)` — ISO 3166-1 alpha-2
- `ref_regions(country_code, code, name)` — composite unique on `(country_code, code)`
- `ref_address_types`, `ref_email_types`, `ref_phone_types`, `ref_organization_types`
