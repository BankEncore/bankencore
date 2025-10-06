# db/migrate/20251004120000_create_party_link_suggestions.rb
class CreatePartyLinkSuggestions < ActiveRecord::Migration[8.0]
  def change
    create_table :party_link_suggestions do |t|
      t.references :source_party, null: false, foreign_key: { to_table: :parties }
      t.references :target_party, null: false, foreign_key: { to_table: :parties }
      t.string     :suggested_link_type_code, null: false
      t.decimal    :confidence_score, precision: 5, scale: 4, null: false, default: 0.0
      t.string     :detected_by, null: false                    # rule id or service name
      t.json       :evidence                                    # hashes like {address_match:true,...}
      t.boolean    :reviewed_flag, null: false, default: false
      t.boolean    :accepted_flag                               # null until reviewed
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime   :reviewed_at
      t.timestamps
    end

    add_index :party_link_suggestions, [ :source_party_id, :target_party_id, :suggested_link_type_code ], name: "idx_pls_pair_type"
    add_index :party_link_suggestions, :reviewed_flag
    add_index :party_link_suggestions, :accepted_flag
  end
end
