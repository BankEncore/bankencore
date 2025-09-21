class CreatePartyLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :party_links do |t|
      t.references :source_party, null: false, foreign_key: { to_table: :parties, on_delete: :cascade }
      t.references :target_party, null: false, foreign_key: { to_table: :parties, on_delete: :cascade }

      t.string :party_link_type_code, null: false

      t.timestamps
    end

    add_foreign_key :party_links, :ref_party_link_types, column: :party_link_type_code, primary_key: :code

    add_index :party_links, [:source_party_id, :target_party_id, :party_link_type_code], unique: true, name: "index_party_links_on_parties_and_type"
  end
end
