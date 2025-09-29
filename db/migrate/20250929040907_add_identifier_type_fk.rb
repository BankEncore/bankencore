# db/migrate/20250929_add_identifier_type_fk.rb
class AddIdentifierTypeFk < ActiveRecord::Migration[8.0]
  def change
    add_reference :party_identifiers, :identifier_type,
      null: true, foreign_key: { to_table: :ref_identifier_types }

    # backfill by code match (uses existing id_type_code)
    execute <<~SQL
      UPDATE party_identifiers pi
      JOIN ref_identifier_types rit ON rit.code = pi.id_type_code
      SET pi.identifier_type_id = rit.id
    SQL

    # new unique index (keeps global uniqueness per type)
    add_index :party_identifiers, [ :identifier_type_id, :value_bidx ],
      unique: true, name: "idx_unique_identifier_type_value"
  end
end
