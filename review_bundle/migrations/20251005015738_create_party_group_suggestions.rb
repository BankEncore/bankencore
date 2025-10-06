# db/migrate/20251004120100_create_party_group_suggestions.rb
class CreatePartyGroupSuggestions < ActiveRecord::Migration[8.0]
  def change
    create_table :party_group_suggestions do |t|
      t.string   :group_type_code, null: false
      t.string   :name                                 # optional proposed group name
      t.json     :members, null: false                 # [{party_id:1, role_code:"head"}, ...]
      t.decimal  :confidence_score, precision: 5, scale: 4, null: false, default: 0.0
      t.string   :detected_by, null: false
      t.json     :evidence
      t.boolean  :reviewed_flag, null: false, default: false
      t.boolean  :accepted_flag
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :reviewed_at
      t.timestamps
    end

    add_index :party_group_suggestions, :group_type_code
    add_index :party_group_suggestions, :reviewed_flag
    add_index :party_group_suggestions, :accepted_flag
  end
end
