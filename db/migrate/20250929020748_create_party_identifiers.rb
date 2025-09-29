# db/migrate/20250928_create_party_identifiers.rb
class CreatePartyIdentifiers < ActiveRecord::Migration[8.0]
  def change
    create_table :party_identifiers do |t|
      t.references :party, null: false, foreign_key: { to_table: :parties }
      t.string  :id_type_code, null: false         # ssn, itin, ein, foreign_tin, passport, dl, lei
      t.string  :country_code                      # ISO 3166-1 alpha-2 if applicable
      t.string  :issuing_authority
      t.date    :issued_on
      t.date    :expires_on
      t.string  :status_code                       # pending, verified, expired, revoked
      t.boolean :is_primary, null: false, default: false

      t.string  :value, null: false                # encrypted (deterministic)
      t.binary  :value_bidx, null: false, limit: 32

      t.string    :value_masked
      t.datetime  :verified_at
      t.string    :verification_ref
      t.json      :metadata

      t.timestamps
    end

    add_index :party_identifiers, [:id_type_code, :value_bidx],
      unique: true, name: "idx_unique_identifier_value"

    add_index :party_identifiers, [:party_id, :id_type_code],
      name: "idx_identifier_by_party_and_type"

    add_index :party_identifiers, [:party_id, :id_type_code, :is_primary],
      name: "idx_primary_identifier_by_party"
  end
end
